import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'logging_service.dart';
import 'observability_service.dart';

/// Configuración del caché de imágenes
class ImageCacheConfig {
  final int maxCacheSize; // en MB
  final Duration maxAge;
  final int maxCacheObjects;
  final bool enableMemoryCache;
  final bool enableDiskCache;
  final double compressionQuality;

  const ImageCacheConfig({
    this.maxCacheSize = 100, // 100 MB por defecto
    this.maxAge = const Duration(days: 7),
    this.maxCacheObjects = 1000,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.compressionQuality = 0.8,
  });
}

/// Información de una imagen en caché
class CachedImageInfo {
  final String key;
  final String url;
  final int sizeBytes;
  final DateTime cachedAt;
  final DateTime lastAccessed;
  final int accessCount;

  CachedImageInfo({
    required this.key,
    required this.url,
    required this.sizeBytes,
    required this.cachedAt,
    required this.lastAccessed,
    required this.accessCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'url': url,
      'size_bytes': sizeBytes,
      'cached_at': cachedAt.toIso8601String(),
      'last_accessed': lastAccessed.toIso8601String(),
      'access_count': accessCount,
    };
  }
}

/// Servicio optimizado de caché de imágenes
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  static ImageCacheConfig _config = const ImageCacheConfig();
  static final Map<String, CachedImageInfo> _cacheInfo = {};
  static Directory? _cacheDirectory;
  static bool _isInitialized = false;

  /// Inicializa el servicio de caché
  static Future<void> initialize({ImageCacheConfig? config}) async {
    if (_isInitialized) return;

    try {
      await ObservabilityService.startTrace('image_cache_init');

      _config = config ?? const ImageCacheConfig();

      // Configurar directorio de caché
      await _setupCacheDirectory();

      // Configurar caché de Flutter
      _configureFlutterImageCache();

      // Limpiar caché expirado
      await _cleanExpiredCache();

      _isInitialized = true;

      LoggingService.info(
        'Image cache service initialized',
        category: LogCategory.performance,
        context: LogContext(
          feature: 'image_cache',
          metadata: {
            'max_cache_size_mb': _config.maxCacheSize,
            'max_age_days': _config.maxAge.inDays,
            'memory_cache_enabled': _config.enableMemoryCache,
            'disk_cache_enabled': _config.enableDiskCache,
          },
        ),
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to initialize image cache service',
        category: LogCategory.performance,
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      await ObservabilityService.stopTrace('image_cache_init');
    }
  }

  /// Configura el directorio de caché
  static Future<void> _setupCacheDirectory() async {
    if (!_config.enableDiskCache) return;

    try {
      final tempDir = await getTemporaryDirectory();
      _cacheDirectory = Directory('${tempDir.path}/image_cache');

      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }

      LoggingService.debug(
        'Cache directory setup: ${_cacheDirectory!.path}',
        category: LogCategory.performance,
      );
    } catch (e) {
      LoggingService.warning(
        'Failed to setup cache directory',
        category: LogCategory.performance,
        error: e,
      );
    }
  }

  /// Configura el caché de imágenes de Flutter
  static void _configureFlutterImageCache() {
    if (!_config.enableMemoryCache) return;

    try {
      // Configurar tamaño máximo del caché en memoria
      PaintingBinding.instance.imageCache.maximumSizeBytes = 
          _config.maxCacheSize * 1024 * 1024; // Convertir MB a bytes

      PaintingBinding.instance.imageCache.maximumSize = _config.maxCacheObjects;

      LoggingService.debug(
        'Flutter image cache configured',
        category: LogCategory.performance,
        context: LogContext(
          feature: 'image_cache',
          metadata: {
            'max_size_bytes': PaintingBinding.instance.imageCache.maximumSizeBytes,
            'max_objects': PaintingBinding.instance.imageCache.maximumSize,
          },
        ),
      );
    } catch (e) {
      LoggingService.warning(
        'Failed to configure Flutter image cache',
        category: LogCategory.performance,
        error: e,
      );
    }
  }

  /// Limpia el caché expirado
  static Future<void> _cleanExpiredCache() async {
    if (!_config.enableDiskCache || _cacheDirectory == null) return;

    try {
      await ObservabilityService.startTrace('cache_cleanup');

      final now = DateTime.now();
      final expiredKeys = <String>[];
      int cleanedBytes = 0;

      for (final entry in _cacheInfo.entries) {
        final info = entry.value;
        if (now.difference(info.cachedAt) > _config.maxAge) {
          expiredKeys.add(entry.key);
          cleanedBytes += info.sizeBytes;

          // Eliminar archivo del disco
          final file = File('${_cacheDirectory!.path}/${entry.key}');
          if (await file.exists()) {
            await file.delete();
          }
        }
      }

      // Remover de la información de caché
      for (final key in expiredKeys) {
        _cacheInfo.remove(key);
      }

      LoggingService.info(
        'Cache cleanup completed',
        category: LogCategory.performance,
        context: LogContext(
          feature: 'image_cache',
          metadata: {
            'expired_items': expiredKeys.length,
            'cleaned_bytes': cleanedBytes,
            'remaining_items': _cacheInfo.length,
          },
        ),
      );
    } catch (e) {
      LoggingService.warning(
        'Cache cleanup failed',
        category: LogCategory.performance,
        error: e,
      );
    } finally {
      await ObservabilityService.stopTrace('cache_cleanup');
    }
  }

  /// Genera una clave única para la URL
  static String _generateCacheKey(String url, {int? width, int? height}) {
    final keyData = '$url${width ?? ''}${height ?? ''}';
    final bytes = utf8.encode(keyData);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Widget optimizado para mostrar imágenes con caché
  static Widget buildCachedImage(
    String imageUrl, {
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
    bool enableLazyLoading = true,
    String? heroTag,
  }) {
    if (!_isInitialized) {
      LoggingService.warning(
        'Image cache service not initialized',
        category: LogCategory.performance,
      );
    }

    final cacheKey = _generateCacheKey(
      imageUrl,
      width: width?.toInt(),
      height: height?.toInt(),
    );

    // Actualizar información de acceso
    _updateAccessInfo(cacheKey, imageUrl);

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      placeholder: placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: (context, url, error) {
        LoggingService.warning(
          'Failed to load image',
          category: LogCategory.performance,
          context: LogContext(
            feature: 'image_loading',
            metadata: {
              'url': url,
              'error': error.toString(),
            },
          ),
        );

        return errorWidget ?? _buildDefaultErrorWidget();
      },
      cacheKey: cacheKey,
      maxWidthDiskCache: width?.toInt(),
      maxHeightDiskCache: height?.toInt(),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
    );

    // Envolver en Hero si se proporciona tag
    if (heroTag != null) {
      imageWidget = Hero(
        tag: heroTag,
        child: imageWidget,
      );
    }

    // Lazy loading si está habilitado
    if (enableLazyLoading) {
      return _LazyImageLoader(
        child: imageWidget,
        onImageVisible: () {
          ObservabilityService.recordPerformanceEvent(
            'image_lazy_loaded',
            metadata: {
              'url': imageUrl,
              'cache_key': cacheKey,
            },
          );
        },
      );
    }

    return imageWidget;
  }

  /// Actualiza la información de acceso de una imagen
  static void _updateAccessInfo(String cacheKey, String url) {
    final now = DateTime.now();
    final existing = _cacheInfo[cacheKey];

    if (existing != null) {
      _cacheInfo[cacheKey] = CachedImageInfo(
        key: cacheKey,
        url: url,
        sizeBytes: existing.sizeBytes,
        cachedAt: existing.cachedAt,
        lastAccessed: now,
        accessCount: existing.accessCount + 1,
      );
    } else {
      _cacheInfo[cacheKey] = CachedImageInfo(
        key: cacheKey,
        url: url,
        sizeBytes: 0, // Se actualizará cuando se cargue
        cachedAt: now,
        lastAccessed: now,
        accessCount: 1,
      );
    }
  }

  /// Placeholder por defecto
  static Widget _buildDefaultPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    );
  }

  /// Widget de error por defecto
  static Widget _buildDefaultErrorWidget() {
    return Container(
      color: Colors.grey[100],
      child: const Icon(
        Icons.broken_image,
        color: Colors.grey,
        size: 32,
      ),
    );
  }

  /// Precarga una imagen
  static Future<void> preloadImage(String imageUrl, {int? width, int? height}) async {
    if (!_isInitialized) return;

    try {
      await ObservabilityService.startTrace('image_preload');

      final cacheKey = _generateCacheKey(
        imageUrl,
        width: width,
        height: height,
      );

      // Verificar si ya está en caché
      if (_cacheInfo.containsKey(cacheKey)) {
        LoggingService.debug(
          'Image already cached, skipping preload',
          category: LogCategory.performance,
          context: LogContext(
            feature: 'image_preload',
            metadata: {'url': imageUrl, 'cache_key': cacheKey},
          ),
        );
        return;
      }

      // Precargar usando CachedNetworkImage
      final imageProvider = CachedNetworkImageProvider(
        imageUrl,
        cacheKey: cacheKey,
        maxWidth: width,
        maxHeight: height,
      );

      await precacheImage(imageProvider, NavigationService.navigatorKey.currentContext!);

      LoggingService.debug(
        'Image preloaded successfully',
        category: LogCategory.performance,
        context: LogContext(
          feature: 'image_preload',
          metadata: {'url': imageUrl},
        ),
      );
    } catch (e) {
      LoggingService.warning(
        'Failed to preload image',
        category: LogCategory.performance,
        error: e,
        context: LogContext(
          feature: 'image_preload',
          metadata: {'url': imageUrl},
        ),
      );
    } finally {
      await ObservabilityService.stopTrace('image_preload');
    }
  }

  /// Precarga múltiples imágenes
  static Future<void> preloadImages(List<String> imageUrls) async {
    if (!_isInitialized || imageUrls.isEmpty) return;

    try {
      await ObservabilityService.startTrace('batch_image_preload');

      final futures = imageUrls.map((url) => preloadImage(url));
      await Future.wait(futures);

      LoggingService.info(
        'Batch image preload completed',
        category: LogCategory.performance,
        context: LogContext(
          feature: 'image_preload',
          metadata: {
            'image_count': imageUrls.length,
          },
        ),
      );
    } catch (e) {
      LoggingService.warning(
        'Batch image preload failed',
        category: LogCategory.performance,
        error: e,
      );
    } finally {
      await ObservabilityService.stopTrace('batch_image_preload');
    }
  }

  /// Limpia todo el caché
  static Future<void> clearCache() async {
    try {
      await ObservabilityService.startTrace('cache_clear');

      // Limpiar caché en memoria
      PaintingBinding.instance.imageCache.clear();

      // Limpiar caché en disco
      if (_config.enableDiskCache && _cacheDirectory != null) {
        if (await _cacheDirectory!.exists()) {
          await _cacheDirectory!.delete(recursive: true);
          await _cacheDirectory!.create(recursive: true);
        }
      }

      // Limpiar información de caché
      final clearedItems = _cacheInfo.length;
      _cacheInfo.clear();

      LoggingService.info(
        'Cache cleared successfully',
        category: LogCategory.performance,
        context: LogContext(
          feature: 'image_cache',
          metadata: {
            'cleared_items': clearedItems,
          },
        ),
      );
    } catch (e) {
      LoggingService.error(
        'Failed to clear cache',
        category: LogCategory.performance,
        error: e,
      );
    } finally {
      await ObservabilityService.stopTrace('cache_clear');
    }
  }

  /// Obtiene estadísticas del caché
  static Map<String, dynamic> getCacheStats() {
    final totalSize = _cacheInfo.values.fold<int>(
      0,
      (sum, info) => sum + info.sizeBytes,
    );

    final memoryCache = PaintingBinding.instance.imageCache;

    return {
      'disk_cache': {
        'items': _cacheInfo.length,
        'total_size_bytes': totalSize,
        'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'max_size_mb': _config.maxCacheSize,
      },
      'memory_cache': {
        'current_size_bytes': memoryCache.currentSizeBytes,
        'current_size_mb': (memoryCache.currentSizeBytes / (1024 * 1024)).toStringAsFixed(2),
        'max_size_bytes': memoryCache.maximumSizeBytes,
        'max_size_mb': (memoryCache.maximumSizeBytes / (1024 * 1024)).toStringAsFixed(2),
        'current_objects': memoryCache.currentSize,
        'max_objects': memoryCache.maximumSize,
      },
      'config': {
        'max_age_days': _config.maxAge.inDays,
        'compression_quality': _config.compressionQuality,
        'memory_cache_enabled': _config.enableMemoryCache,
        'disk_cache_enabled': _config.enableDiskCache,
      },
    };
  }

  /// Obtiene las imágenes más accedidas
  static List<CachedImageInfo> getMostAccessedImages({int limit = 10}) {
    final sortedImages = _cacheInfo.values.toList()
      ..sort((a, b) => b.accessCount.compareTo(a.accessCount));

    return sortedImages.take(limit).toList();
  }

  /// Optimiza el caché eliminando imágenes menos usadas
  static Future<void> optimizeCache() async {
    if (!_config.enableDiskCache) return;

    try {
      await ObservabilityService.startTrace('cache_optimization');

      final stats = getCacheStats();
      final currentSizeMB = double.parse(stats['disk_cache']['total_size_mb']);

      if (currentSizeMB <= _config.maxCacheSize) {
        LoggingService.debug(
          'Cache size within limits, no optimization needed',
          category: LogCategory.performance,
        );
        return;
      }

      // Ordenar por último acceso (menos recientes primero)
      final sortedImages = _cacheInfo.values.toList()
        ..sort((a, b) => a.lastAccessed.compareTo(b.lastAccessed));

      int removedItems = 0;
      int removedBytes = 0;

      // Eliminar imágenes hasta estar dentro del límite
      for (final info in sortedImages) {
        if (currentSizeMB - (removedBytes / (1024 * 1024)) <= _config.maxCacheSize * 0.8) {
          break; // Dejar un 20% de margen
        }

        // Eliminar archivo
        final file = File('${_cacheDirectory!.path}/${info.key}');
        if (await file.exists()) {
          await file.delete();
        }

        _cacheInfo.remove(info.key);
        removedItems++;
        removedBytes += info.sizeBytes;
      }

      LoggingService.info(
        'Cache optimization completed',
        category: LogCategory.performance,
        context: LogContext(
          feature: 'image_cache',
          metadata: {
            'removed_items': removedItems,
            'removed_bytes': removedBytes,
            'remaining_items': _cacheInfo.length,
          },
        ),
      );
    } catch (e) {
      LoggingService.error(
        'Cache optimization failed',
        category: LogCategory.performance,
        error: e,
      );
    } finally {
      await ObservabilityService.stopTrace('cache_optimization');
    }
  }
}

/// Widget para lazy loading de imágenes
class _LazyImageLoader extends StatefulWidget {
  final Widget child;
  final VoidCallback? onImageVisible;

  const _LazyImageLoader({
    required this.child,
    this.onImageVisible,
  });

  @override
  State<_LazyImageLoader> createState() => _LazyImageLoaderState();
}

class _LazyImageLoaderState extends State<_LazyImageLoader> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (info) {
        if (!_isVisible && info.visibleFraction > 0.1) {
          _isVisible = true;
          widget.onImageVisible?.call();
        }
      },
      child: widget.child,
    );
  }
}

/// Servicio de navegación para obtener el contexto
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

/// Extensión para facilitar el uso del caché de imágenes
extension ImageCacheExtension on String {
  Widget toCachedImage({
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
    bool enableLazyLoading = true,
    String? heroTag,
  }) {
    return ImageCacheService.buildCachedImage(
      this,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      enableLazyLoading: enableLazyLoading,
      heroTag: heroTag,
    );
  }

  Future<void> preload({int? width, int? height}) {
    return ImageCacheService.preloadImage(this, width: width, height: height);
  }
}