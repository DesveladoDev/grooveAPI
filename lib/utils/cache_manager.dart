import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:salas_beats/config/constants.dart';
import 'package:salas_beats/utils/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheEntry<T> {
  
  const CacheEntry({
    required this.data,
    required this.createdAt,
    required this.expiresAt,
    required this.key,
    this.metadata,
  });
  
  factory CacheEntry.fromJson(Map<String, dynamic> json, T Function() fromJsonData) => CacheEntry(
      data: fromJsonData(json['data']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      key: json['key'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  final T data;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String key;
  final Map<String, dynamic>? metadata;
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isExpired;
  
  Duration get age => DateTime.now().difference(createdAt);
  Duration get timeToExpiry => expiresAt.difference(DateTime.now());
  
  Map<String, dynamic> toJson() => {
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'key': key,
      'metadata': metadata,
    };
}

enum CacheStrategy {
  cacheFirst,    // Use cache if available, fallback to network
  networkFirst,  // Use network first, fallback to cache
  cacheOnly,     // Only use cache
  networkOnly,   // Only use network
  staleWhileRevalidate, // Return cache immediately, update in background
}

class CacheConfig {
  
  const CacheConfig({
    this.defaultTtl = const Duration(hours: 1),
    this.maxMemoryEntries = 100,
    this.maxDiskSizeBytes = 50 * 1024 * 1024, // 50MB
    this.enableCompression = true,
    this.enableEncryption = false,
    this.defaultStrategy = CacheStrategy.cacheFirst,
  });
  final Duration defaultTtl;
  final int maxMemoryEntries;
  final int maxDiskSizeBytes;
  final bool enableCompression;
  final bool enableEncryption;
  final CacheStrategy defaultStrategy;
}

class CacheManager {
  
  CacheManager._();
  static CacheManager? _instance;
  static CacheManager get instance => _instance ??= CacheManager._();
  
  final Map<String, CacheEntry> _memoryCache = {};
  SharedPreferences? _prefs;
  Directory? _cacheDir;
  CacheConfig _config = const CacheConfig();
  
  // Initialize cache manager
  Future<void> initialize({CacheConfig? config}) async {
    _config = config ?? _config;
    _prefs = await SharedPreferences.getInstance();
    _cacheDir = await getTemporaryDirectory();
    
    // Clean expired entries on startup
    await _cleanExpiredEntries();
    
    // Ensure cache directory exists
    final cacheSubDir = Directory('${_cacheDir!.path}/app_cache');
    if (!await cacheSubDir.exists()) {
      await cacheSubDir.create(recursive: true);
    }
    _cacheDir = cacheSubDir;
  }
  
  // Generate cache key
  String _generateKey(String key) {
    final bytes = utf8.encode(key);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Get file path for cache key
  String _getFilePath(String key) {
    final hashedKey = _generateKey(key);
    return '${_cacheDir!.path}/$hashedKey.cache';
  }
  
  // Store data in memory cache
  void _storeInMemory<T>(String key, CacheEntry<T> entry) {
    // Remove oldest entries if memory cache is full
    if (_memoryCache.length >= _config.maxMemoryEntries) {
      final oldestKey = _memoryCache.keys.first;
      _memoryCache.remove(oldestKey);
    }
    
    _memoryCache[key] = entry;
  }
  
  // Store data in disk cache
  Future<void> _storeToDisk<T>(String key, CacheEntry<T> entry) async {
    try {
      final filePath = _getFilePath(key);
      final file = File(filePath);
      
      final jsonData = entry.toJson();
      final jsonString = jsonEncode(jsonData);
      
      var data = utf8.encode(jsonString);
      
      // Apply compression if enabled
      if (_config.enableCompression) {
        data = Uint8List.fromList(gzip.encode(data));
      }
      
      // Apply encryption if enabled
      if (_config.enableEncryption) {
        // Simple XOR encryption (for demo purposes)
        // In production, use proper encryption
        data = _xorEncrypt(data, 'cache_key_${AppConstants.appName}');
      }
      
      await file.writeAsBytes(data);
      
      // Update disk cache size tracking
      await _updateDiskCacheSize();
    } catch (e) {
      debugPrint('Error storing to disk cache: $e');
    }
  }
  
  // Load data from disk cache
  Future<CacheEntry<T>?> _loadFromDisk<T>(String key, T Function() fromJson) async {
    try {
      final filePath = _getFilePath(key);
      final file = File(filePath);
      
      if (!await file.exists()) return null;
      
      var data = await file.readAsBytes();
      
      // Apply decryption if enabled
      if (_config.enableEncryption) {
        data = _xorEncrypt(data, 'cache_key_${AppConstants.appName}');
      }
      
      // Apply decompression if enabled
      if (_config.enableCompression) {
        data = Uint8List.fromList(gzip.decode(data));
      }
      
      final jsonString = utf8.decode(data);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      return CacheEntry.fromJson(jsonData, fromJson);
    } catch (e) {
      debugPrint('Error loading from disk cache: $e');
      return null;
    }
  }
  
  // Simple XOR encryption/decryption
  Uint8List _xorEncrypt(Uint8List data, String key) {
    final keyBytes = utf8.encode(key);
    final result = Uint8List(data.length);
    
    for (var i = 0; i < data.length; i++) {
      result[i] = data[i] ^ keyBytes[i % keyBytes.length];
    }
    
    return result;
  }
  
  // Store data with TTL
  Future<void> store<T>(
    String key,
    T data, {
    Duration? ttl,
    Map<String, dynamic>? metadata,
    bool memoryOnly = false,
  }) async {
    final now = DateTime.now();
    final expiresAt = now.add(ttl ?? _config.defaultTtl);
    
    final entry = CacheEntry<T>(
      data: data,
      createdAt: now,
      expiresAt: expiresAt,
      key: key,
      metadata: metadata,
    );
    
    // Store in memory
    _storeInMemory(key, entry);
    
    // Store to disk if not memory-only
    if (!memoryOnly) {
      await _storeToDisk(key, entry);
    }
  }
  
  // Get data from cache
  Future<T?> get<T>(String key, T Function() fromJson) async {
    // Check memory cache first
    final memoryEntry = _memoryCache[key] as CacheEntry<T>?;
    if (memoryEntry != null) {
      if (memoryEntry.isValid) {
        return memoryEntry.data;
      } else {
        _memoryCache.remove(key);
      }
    }
    
    // Check disk cache
    final diskEntry = await _loadFromDisk<T>(key, fromJson);
    if (diskEntry != null) {
      if (diskEntry.isValid) {
        // Store back in memory for faster access
        _storeInMemory(key, diskEntry);
        return diskEntry.data;
      } else {
        // Remove expired entry from disk
        await remove(key);
      }
    }
    
    return null;
  }
  
  // Get cache entry with metadata
  Future<CacheEntry<T>?> getEntry<T>(String key, T Function() fromJson) async {
    // Check memory cache first
    final memoryEntry = _memoryCache[key] as CacheEntry<T>?;
    if (memoryEntry != null) {
      if (memoryEntry.isValid) {
        return memoryEntry;
      } else {
        _memoryCache.remove(key);
      }
    }
    
    // Check disk cache
    final diskEntry = await _loadFromDisk<T>(key, fromJson);
    if (diskEntry != null) {
      if (diskEntry.isValid) {
        _storeInMemory(key, diskEntry);
        return diskEntry;
      } else {
        await remove(key);
      }
    }
    
    return null;
  }
  
  // Check if key exists and is valid
  Future<bool> contains(String key) async {
    // Check memory cache
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && memoryEntry.isValid) {
      return true;
    }
    
    // Check disk cache
    final filePath = _getFilePath(key);
    final file = File(filePath);
    return file.exists();
  }
  
  // Remove specific key
  Future<void> remove(String key) async {
    // Remove from memory
    _memoryCache.remove(key);
    
    // Remove from disk
    try {
      final filePath = _getFilePath(key);
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error removing cache file: $e');
    }
  }
  
  // Clear all cache
  Future<void> clear() async {
    // Clear memory cache
    _memoryCache.clear();
    
    // Clear disk cache
    try {
      if (_cacheDir != null && await _cacheDir!.exists()) {
        await for (final entity in _cacheDir!.list()) {
          if (entity is File && entity.path.endsWith('.cache')) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error clearing disk cache: $e');
    }
  }
  
  // Clear expired entries
  Future<void> _cleanExpiredEntries() async {
    // Clean memory cache
    final expiredKeys = _memoryCache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      _memoryCache.remove(key);
    }
    
    // Clean disk cache
    try {
      if (_cacheDir != null && await _cacheDir!.exists()) {
        await for (final entity in _cacheDir!.list()) {
          if (entity is File && entity.path.endsWith('.cache')) {
            try {
              final stat = await entity.stat();
              final lastModified = stat.modified;
              final age = DateTime.now().difference(lastModified);
              
              // Remove files older than max TTL
              if (age > const Duration(days: 7)) {
                await entity.delete();
              }
            } catch (e) {
              // If we can't read the file, delete it
              await entity.delete();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning expired disk cache: $e');
    }
  }
  
  // Update disk cache size tracking
  Future<void> _updateDiskCacheSize() async {
    try {
      var totalSize = 0;
      final files = <File>[];
      
      if (_cacheDir != null && await _cacheDir!.exists()) {
        await for (final entity in _cacheDir!.list()) {
          if (entity is File && entity.path.endsWith('.cache')) {
            final stat = await entity.stat();
            totalSize += stat.size;
            files.add(entity);
          }
        }
      }
      
      // If cache size exceeds limit, remove oldest files
      if (totalSize > _config.maxDiskSizeBytes) {
        files.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
        
        for (final file in files) {
          if (totalSize <= _config.maxDiskSizeBytes) break;
          
          final stat = await file.stat();
          totalSize -= stat.size;
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error updating disk cache size: $e');
    }
  }
  
  // Get cache statistics
  Future<CacheStats> getStats() async {
    final var memoryEntries = _memoryCache.length;
    var diskEntries = 0;
    var diskSizeBytes = 0;
    
    try {
      if (_cacheDir != null && await _cacheDir!.exists()) {
        await for (final entity in _cacheDir!.list()) {
          if (entity is File && entity.path.endsWith('.cache')) {
            diskEntries++;
            final stat = await entity.stat();
            diskSizeBytes += stat.size;
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting cache stats: $e');
    }
    
    return CacheStats(
      memoryEntries: memoryEntries,
      diskEntries: diskEntries,
      diskSizeBytes: diskSizeBytes,
      maxMemoryEntries: _config.maxMemoryEntries,
      maxDiskSizeBytes: _config.maxDiskSizeBytes,
    );
  }
  
  // Preload cache entries
  Future<void> preload<T>(
    Map<String, Future<T>> futures, {
    Duration? ttl,
    bool memoryOnly = false,
  }) async {
    final results = await Future.wait(
      futures.entries.map((entry) async {
        try {
          final data = await entry.value;
          await store(
            entry.key,
            data,
            ttl: ttl,
            memoryOnly: memoryOnly,
          );
          return true;
        } catch (e) {
          debugPrint('Error preloading cache entry ${entry.key}: $e');
          return false;
        }
      }),
    );
    
    final successCount = results.where((success) => success).length;
    debugPrint('Preloaded $successCount/${futures.length} cache entries');
  }
  
  // Cache with strategy
  Future<T?> getWithStrategy<T>(
    String key,
    Future<T> Function() networkCall,
    T Function() fromJson, {
    CacheStrategy? strategy,
    Duration? ttl,
  }) async {
    final cacheStrategy = strategy ?? _config.defaultStrategy;
    
    switch (cacheStrategy) {
      case CacheStrategy.cacheFirst:
        final cached = await get<T>(key, fromJson);
        if (cached != null) return cached;
        
        try {
          final networkData = await networkCall();
          await store(key, networkData, ttl: ttl);
          return networkData;
        } catch (e) {
          throw NetworkException.serverError();
        }
        
      case CacheStrategy.networkFirst:
        try {
          final networkData = await networkCall();
          await store(key, networkData, ttl: ttl);
          return networkData;
        } catch (e) {
          final cached = await get<T>(key, fromJson);
          if (cached != null) return cached;
          throw NetworkException.serverError();
        }
        
      case CacheStrategy.cacheOnly:
        return get<T>(key, fromJson);
        
      case CacheStrategy.networkOnly:
        final networkData = await networkCall();
        await store(key, networkData, ttl: ttl);
        return networkData;
        
      case CacheStrategy.staleWhileRevalidate:
        final cached = await get<T>(key, fromJson);
        
        // Update in background
        networkCall().then((networkData) {
          store(key, networkData, ttl: ttl);
        }).catchError((e) {
          debugPrint('Background cache update failed: $e');
        });
        
        return cached;
    }
  }
}

class CacheStats {
  
  const CacheStats({
    required this.memoryEntries,
    required this.diskEntries,
    required this.diskSizeBytes,
    required this.maxMemoryEntries,
    required this.maxDiskSizeBytes,
  });
  final int memoryEntries;
  final int diskEntries;
  final int diskSizeBytes;
  final int maxMemoryEntries;
  final int maxDiskSizeBytes;
  
  double get memoryUsagePercent => memoryEntries / maxMemoryEntries;
  double get diskUsagePercent => diskSizeBytes / maxDiskSizeBytes;
  
  String get diskSizeFormatted {
    if (diskSizeBytes < 1024) {
      return '${diskSizeBytes}B';
    } else if (diskSizeBytes < 1024 * 1024) {
      return '${(diskSizeBytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(diskSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
  
  @override
  String toString() => 'CacheStats(memory: $memoryEntries/$maxMemoryEntries, '
           'disk: $diskEntries entries, $diskSizeFormatted)';
}

// Specialized cache managers for different data types
class ListingCacheManager {
  static const String _keyPrefix = 'listing_';
  static const Duration _defaultTtl = Duration(minutes: 30);
  
  static Future<void> storeListing(String listingId, Map<String, dynamic> listing) async {
    await CacheManager.instance.store(
      '$_keyPrefix$listingId',
      listing,
      ttl: _defaultTtl,
    );
  }
  
  static Future<Map<String, dynamic>?> getListing(String listingId) async => CacheManager.instance.get<Map<String, dynamic>>(
      '$_keyPrefix$listingId',
      (data) => data as Map<String, dynamic>,
    );
  
  static Future<void> storeListings(List<Map<String, dynamic>> listings) async {
    const key = '${_keyPrefix}all';
    await CacheManager.instance.store(key, listings, ttl: _defaultTtl);
  }
  
  static Future<List<Map<String, dynamic>>?> getListings() async {
    const key = '${_keyPrefix}all';
    return CacheManager.instance.get<List<Map<String, dynamic>>>(
      key,
      (data) => (data as List).cast<Map<String, dynamic>>(),
    );
  }
}

class UserCacheManager {
  static const String _keyPrefix = 'user_';
  static const Duration _defaultTtl = Duration(hours: 2);
  
  static Future<void> storeUser(String userId, Map<String, dynamic> user) async {
    await CacheManager.instance.store(
      '$_keyPrefix$userId',
      user,
      ttl: _defaultTtl,
    );
  }
  
  static Future<Map<String, dynamic>?> getUser(String userId) async => CacheManager.instance.get<Map<String, dynamic>>(
      '$_keyPrefix$userId',
      (data) => data as Map<String, dynamic>,
    );
  
  static Future<void> storeCurrentUser(Map<String, dynamic> user) async {
    const key = '${_keyPrefix}current';
    await CacheManager.instance.store(key, user, ttl: _defaultTtl);
  }
  
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    const key = '${_keyPrefix}current';
    return CacheManager.instance.get<Map<String, dynamic>>(
      key,
      (data) => data as Map<String, dynamic>,
    );
  }
}

class SearchCacheManager {
  static const String _keyPrefix = 'search_';
  static const Duration _defaultTtl = Duration(minutes: 15);
  
  static String _generateSearchKey(String query, Map<String, dynamic>? filters) {
    final key = '$query${filters?.toString() ?? ""}';
    return '$_keyPrefix${key.hashCode}';
  }
  
  static Future<void> storeSearchResults(
    String query,
    Map<String, dynamic>? filters,
    List<Map<String, dynamic>> results,
  ) async {
    final key = _generateSearchKey(query, filters);
    await CacheManager.instance.store(key, results, ttl: _defaultTtl);
  }
  
  static Future<List<Map<String, dynamic>>?> getSearchResults(
    String query,
    Map<String, dynamic>? filters,
  ) async {
    final key = _generateSearchKey(query, filters);
    return CacheManager.instance.get<List<Map<String, dynamic>>>(
      key,
      (data) => (data as List).cast<Map<String, dynamic>>(),
    );
  }
}