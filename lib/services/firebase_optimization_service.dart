import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:salas_beats/services/connectivity_service.dart';

/// Servicio para optimizar las conexiones de Firebase y reducir errores de red
class FirebaseOptimizationService {
  static final FirebaseOptimizationService _instance = FirebaseOptimizationService._internal();
  factory FirebaseOptimizationService() => _instance;
  FirebaseOptimizationService._internal();

  final ConnectivityService _connectivityService = ConnectivityService();
  
  // Cache para reducir consultas repetidas
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(minutes: 5);

  /// Inicializa las configuraciones optimizadas de Firebase
  Future<void> initialize() async {
    try {
      await _configureFirestore();
      await _configureAuth();
      await _configureStorage();
      
      debugPrint('Firebase optimization service initialized');
    } catch (e) {
      debugPrint('Error initializing Firebase optimization: $e');
    }
  }

  /// Configura Firestore con configuraciones optimizadas
  Future<void> _configureFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Configurar settings para optimizar rendimiento
      await firestore.enableNetwork();
      
      // Configurar cache persistente solo en release
      if (!kDebugMode) {
        firestore.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      } else {
        // En debug, usar cache limitado para evitar problemas
        firestore.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: 50 * 1024 * 1024, // 50MB
        );
      }
      
      debugPrint('Firestore configured with optimized settings');
    } catch (e) {
      debugPrint('Error configuring Firestore: $e');
    }
  }

  /// Configura Auth con configuraciones optimizadas
  Future<void> _configureAuth() async {
    try {
      final auth = FirebaseAuth.instance;
      
      // Configurar persistencia de auth
      await auth.setPersistence(Persistence.LOCAL);
      
      // Configurar timeout para operaciones de auth
      auth.setSettings(
        appVerificationDisabledForTesting: kDebugMode,
        forceRecaptchaFlow: false,
      );
      
      debugPrint('Firebase Auth configured with optimized settings');
    } catch (e) {
      debugPrint('Error configuring Firebase Auth: $e');
    }
  }

  /// Configura Storage con configuraciones optimizadas
  Future<void> _configureStorage() async {
    try {
      final storage = FirebaseStorage.instance;
      
      // Configurar timeouts para Storage
      storage.setMaxDownloadRetryTime(const Duration(seconds: 30));
      storage.setMaxUploadRetryTime(const Duration(seconds: 60));
      storage.setMaxOperationRetryTime(const Duration(seconds: 30));
      
      debugPrint('Firebase Storage configured with optimized settings');
    } catch (e) {
      debugPrint('Error configuring Firebase Storage: $e');
    }
  }

  /// Ejecuta una consulta de Firestore con cache y manejo de conectividad
  Future<T> executeFirestoreQuery<T>(
    String cacheKey,
    Future<T> Function() query, {
    Duration? cacheExpiration,
  }) async {
    // Verificar cache primero
    if (_isCacheValid(cacheKey, cacheExpiration)) {
      debugPrint('Returning cached result for: $cacheKey');
      return _cache[cacheKey] as T;
    }

    // Verificar conectividad antes de hacer la consulta
    if (!_connectivityService.isConnected) {
      // Si no hay conexión, intentar devolver cache expirado si existe
      if (_cache.containsKey(cacheKey)) {
        debugPrint('No connection, returning stale cache for: $cacheKey');
        return _cache[cacheKey] as T;
      }
      
      // Si no hay cache, esperar conexión
      await _connectivityService.waitForConnection(
        timeout: const Duration(seconds: 10),
      );
    }

    try {
      // Ejecutar consulta con reintentos
      final result = await _connectivityService.retryWithBackoff(query);
      
      if (result == null) {
        throw Exception('Query returned null result');
      }
      
      // Guardar en cache
      _cache[cacheKey] = result;
      _cacheTimestamps[cacheKey] = DateTime.now();
      
      return result;
    } catch (e) {
      // Si falla y hay cache, devolver cache expirado
      if (_cache.containsKey(cacheKey)) {
        debugPrint('Query failed, returning stale cache for: $cacheKey');
        return _cache[cacheKey] as T;
      }
      
      rethrow;
    }
  }

  /// Verifica si el cache es válido
  bool _isCacheValid(String key, Duration? expiration) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }
    
    final timestamp = _cacheTimestamps[key]!;
    final expirationDuration = expiration ?? _cacheExpiration;
    
    return DateTime.now().difference(timestamp) < expirationDuration;
  }

  /// Limpia el cache
  void clearCache([String? key]) {
    if (key != null) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    } else {
      _cache.clear();
      _cacheTimestamps.clear();
    }
  }

  /// Limpia cache expirado
  void cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) > _cacheExpiration) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
    
    if (expiredKeys.isNotEmpty) {
      debugPrint('Cleaned ${expiredKeys.length} expired cache entries');
    }
  }

  /// Obtiene un documento de Firestore con cache
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
    String path, {
    Duration? cacheExpiration,
    Source source = Source.server,
  }) async {
    final cacheKey = 'doc_$path';
    
    return await executeFirestoreQuery(
      cacheKey,
      () async {
        // Si no hay conexión, usar cache primero
        final actualSource = _connectivityService.isConnected ? source : Source.cache;
        
        return await FirebaseFirestore.instance
            .doc(path)
            .get(GetOptions(source: actualSource));
      },
      cacheExpiration: cacheExpiration,
    );
  }

  /// Obtiene una colección de Firestore con cache
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(
   String collectionPath, {
      Duration? cacheExpiration,
      Source source = Source.server,
    Query<Map<String, dynamic>>? Function(CollectionReference<Map<String, dynamic>>)? queryBuilder,
  }) async {
    final cacheKey = 'collection_$collectionPath${queryBuilder != null ? '_filtered' : ''}';
    
    return await executeFirestoreQuery(
      cacheKey,
      () async {
        // Si no hay conexión, usar cache primero
        final actualSource = _connectivityService.isConnected ? source : Source.cache;
        
        var query = FirebaseFirestore.instance.collection(collectionPath);
        
        if (queryBuilder != null) {
          query = queryBuilder(query) as CollectionReference<Map<String, dynamic>>;
        }
        
        return await query.get(GetOptions(source: actualSource));
      },
      cacheExpiration: cacheExpiration,
    );
  }

  /// Configura listeners de Firestore con manejo de errores mejorado
  StreamSubscription<T> listenToDocument<T>(
    String path,
    void Function(T) onData,
    T Function(DocumentSnapshot<Map<String, dynamic>>) converter, {
    void Function(Object)? onError,
  }) {
    return FirebaseFirestore.instance
        .doc(path)
        .snapshots(includeMetadataChanges: false)
        .map(converter)
        .listen(
          onData,
          onError: (error) {
            debugPrint('Firestore listener error for $path: $error');
            onError?.call(error);
          },
        );
  }

  /// Configura listeners de colecciones con manejo de errores mejorado
  StreamSubscription<List<T>> listenToCollection<T>(
    String path,
    void Function(List<T>) onData,
    T Function(DocumentSnapshot<Map<String, dynamic>>) converter, {
    void Function(Object)? onError,
    Query<Map<String, dynamic>>? Function(CollectionReference<Map<String, dynamic>>)? queryBuilder,
  }) {
    var query = FirebaseFirestore.instance.collection(path);
    
    if (queryBuilder != null) {
      query = queryBuilder(query) as CollectionReference<Map<String, dynamic>>;
    }
    
    return query
        .snapshots(includeMetadataChanges: false)
        .map((snapshot) => snapshot.docs.map(converter).toList())
        .listen(
          onData,
          onError: (error) {
            debugPrint('Firestore collection listener error for $path: $error');
            onError?.call(error);
          },
        );
  }

  /// Maneja la desconexión de red de forma elegante
  Future<void> handleNetworkDisconnection() async {
    try {
      await FirebaseFirestore.instance.disableNetwork();
      debugPrint('Firestore network disabled due to connectivity issues');
    } catch (e) {
      debugPrint('Error disabling Firestore network: $e');
    }
  }

  /// Maneja la reconexión de red
  Future<void> handleNetworkReconnection() async {
    try {
      await FirebaseFirestore.instance.enableNetwork();
      debugPrint('Firestore network re-enabled');
    } catch (e) {
      debugPrint('Error enabling Firestore network: $e');
    }
  }
}