import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:salas_beats/utils/exceptions.dart';

enum NetworkStatus {
  connected,
  disconnected,
  connecting,
  unknown,
}

enum ConnectionType {
  wifi,
  mobile,
  ethernet,
  bluetooth,
  vpn,
  other,
  none,
}

class NetworkInfo {
  
  const NetworkInfo({
    required this.status,
    required this.type,
    required this.isMetered,
    required this.lastChecked, this.signalStrength,
    this.ssid,
    this.bssid,
    this.ipAddress,
    this.speed,
  });
  final NetworkStatus status;
  final ConnectionType type;
  final bool isMetered;
  final int? signalStrength;
  final String? ssid;
  final String? bssid;
  final String? ipAddress;
  final double? speed; // Mbps
  final DateTime lastChecked;
  
  bool get isConnected => status == NetworkStatus.connected;
  bool get isDisconnected => status == NetworkStatus.disconnected;
  bool get isWifi => type == ConnectionType.wifi;
  bool get isMobile => type == ConnectionType.mobile;
  bool get hasStrongSignal => signalStrength != null && signalStrength! > 70;
  bool get hasWeakSignal => signalStrength != null && signalStrength! < 30;
  
  NetworkInfo copyWith({
    NetworkStatus? status,
    ConnectionType? type,
    bool? isMetered,
    int? signalStrength,
    String? ssid,
    String? bssid,
    String? ipAddress,
    double? speed,
    DateTime? lastChecked,
  }) => NetworkInfo(
      status: status ?? this.status,
      type: type ?? this.type,
      isMetered: isMetered ?? this.isMetered,
      signalStrength: signalStrength ?? this.signalStrength,
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      ipAddress: ipAddress ?? this.ipAddress,
      speed: speed ?? this.speed,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  
  @override
  String toString() => 'NetworkInfo(status: $status, type: $type, isMetered: $isMetered, '
           'signalStrength: $signalStrength, speed: $speed)';
}

class ConnectivityManager {
  
  ConnectivityManager._();
  static ConnectivityManager? _instance;
  static ConnectivityManager get instance => _instance ??= ConnectivityManager._();
  
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  final StreamController<NetworkInfo> _networkInfoController = 
      StreamController<NetworkInfo>.broadcast();
  
  NetworkInfo _currentNetworkInfo = NetworkInfo(
    status: NetworkStatus.unknown,
    type: ConnectionType.none,
    isMetered: false,
    lastChecked: DateTime.now(),
  );
  
  Timer? _speedTestTimer;
  Timer? _pingTimer;
  final List<double> _speedHistory = [];
  final List<int> _pingHistory = [];
  
  // Getters
  Stream<NetworkInfo> get networkInfoStream => _networkInfoController.stream;
  NetworkInfo get currentNetworkInfo => _currentNetworkInfo;
  bool get isConnected => _currentNetworkInfo.isConnected;
  bool get isDisconnected => _currentNetworkInfo.isDisconnected;
  ConnectionType get connectionType => _currentNetworkInfo.type;
  bool get isMetered => _currentNetworkInfo.isMetered;
  
  // Initialize connectivity monitoring
  Future<void> initialize() async {
    try {
      // Check initial connectivity
      await _updateNetworkInfo();
      
      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (error) {
          debugPrint('Connectivity stream error: $error');
        },
      );
      
      // Start periodic network monitoring
      _startPeriodicMonitoring();
      
      debugPrint('ConnectivityManager initialized');
    } catch (e) {
      debugPrint('Error initializing ConnectivityManager: $e');
      throw NetworkException.noConnection();
    }
  }
  
  // Handle connectivity changes
  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    debugPrint('Connectivity changed: $results');
    await _updateNetworkInfo();
  }
  
  // Update network information
  Future<void> _updateNetworkInfo() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final primaryResult = connectivityResults.isNotEmpty 
          ? connectivityResults.first 
          : ConnectivityResult.none;
      
      final connectionType = _mapConnectivityResult(primaryResult);
      final isConnected = connectionType != ConnectionType.none;
      
      NetworkStatus status;
      if (isConnected) {
        // Verify actual internet connectivity
        final hasInternet = await _checkInternetConnectivity();
        status = hasInternet ? NetworkStatus.connected : NetworkStatus.disconnected;
      } else {
        status = NetworkStatus.disconnected;
      }
      
      final networkInfo = NetworkInfo(
        status: status,
        type: connectionType,
        isMetered: await _isMeteredConnection(connectionType),
        signalStrength: await _getSignalStrength(connectionType),
        ssid: await _getWifiSSID(connectionType),
        bssid: await _getWifiBSSID(connectionType),
        ipAddress: await _getIPAddress(),
        speed: _getAverageSpeed(),
        lastChecked: DateTime.now(),
      );
      
      _currentNetworkInfo = networkInfo;
      _networkInfoController.add(networkInfo);
      
      debugPrint('Network info updated: $networkInfo');
    } catch (e) {
      debugPrint('Error updating network info: $e');
    }
  }
  
  // Map ConnectivityResult to ConnectionType
  ConnectionType _mapConnectivityResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectionType.wifi;
      case ConnectivityResult.mobile:
        return ConnectionType.mobile;
      case ConnectivityResult.ethernet:
        return ConnectionType.ethernet;
      case ConnectivityResult.bluetooth:
        return ConnectionType.bluetooth;
      case ConnectivityResult.vpn:
        return ConnectionType.vpn;
      case ConnectivityResult.other:
        return ConnectionType.other;
      case ConnectivityResult.none:
      default:
        return ConnectionType.none;
    }
  }
  
  // Check actual internet connectivity
  Future<bool> _checkInternetConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // Check if connection is metered
  Future<bool> _isMeteredConnection(ConnectionType type) async {
    // Mobile connections are typically metered
    if (type == ConnectionType.mobile) {
      return true;
    }
    
    // For other connection types, we'd need platform-specific code
    // This is a simplified implementation
    return false;
  }
  
  // Get signal strength (simplified)
  Future<int?> _getSignalStrength(ConnectionType type) async {
    // This would require platform-specific implementation
    // For now, return a mock value based on connection type
    switch (type) {
      case ConnectionType.wifi:
        return 80; // Mock strong WiFi signal
      case ConnectionType.mobile:
        return 60; // Mock moderate mobile signal
      default:
        return null;
    }
  }
  
  // Get WiFi SSID
  Future<String?> _getWifiSSID(ConnectionType type) async {
    if (type != ConnectionType.wifi) return null;
    
    try {
      // This would require platform-specific implementation
      // For now, return null
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Get WiFi BSSID
  Future<String?> _getWifiBSSID(ConnectionType type) async {
    if (type != ConnectionType.wifi) return null;
    
    try {
      // This would require platform-specific implementation
      // For now, return null
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Get IP address
  Future<String?> _getIPAddress() async {
    try {
      // Get local IP address
      for (final interface in await NetworkInterface.list()) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Start periodic network monitoring
  void _startPeriodicMonitoring() {
    // Update network info every 30 seconds
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateNetworkInfo();
    });
    
    // Run speed test every 5 minutes if connected
    _speedTestTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (isConnected && !isMetered) {
        _runSpeedTest();
      }
    });
  }
  
  // Run network speed test
  Future<void> _runSpeedTest() async {
    try {
      final stopwatch = Stopwatch()..start();
      
      // Download a small file to test speed
      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://httpbin.org/bytes/1024'), // 1KB test file
      );
      request.headers.set('Cache-Control', 'no-cache');
      
      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        await response.drain();
        stopwatch.stop();
        
        // Calculate speed in Mbps
        const bytes = 1024; // 1KB
        final seconds = stopwatch.elapsedMilliseconds / 1000;
        final bitsPerSecond = (bytes * 8) / seconds;
        final mbps = bitsPerSecond / (1024 * 1024);
        
        _speedHistory.add(mbps);
        if (_speedHistory.length > 10) {
          _speedHistory.removeAt(0);
        }
        
        debugPrint('Speed test result: ${mbps.toStringAsFixed(2)} Mbps');
      }
      
      client.close();
    } catch (e) {
      debugPrint('Speed test failed: $e');
    }
  }
  
  // Get average speed from history
  double? _getAverageSpeed() {
    if (_speedHistory.isEmpty) return null;
    
    final sum = _speedHistory.reduce((a, b) => a + b);
    return sum / _speedHistory.length;
  }
  
  // Ping a host to measure latency
  Future<int?> ping(String host) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      final result = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 5));
      
      stopwatch.stop();
      
      if (result.isNotEmpty) {
        final latency = stopwatch.elapsedMilliseconds;
        _pingHistory.add(latency);
        if (_pingHistory.length > 10) {
          _pingHistory.removeAt(0);
        }
        return latency;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Get average ping from history
  double? getAveragePing() {
    if (_pingHistory.isEmpty) return null;
    
    final sum = _pingHistory.reduce((a, b) => a + b);
    return sum / _pingHistory.length;
  }
  
  // Check if a specific host is reachable
  Future<bool> isHostReachable(String host, {int port = 80}) async {
    try {
      final socket = await Socket.connect(host, port)
          .timeout(const Duration(seconds: 5));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Wait for connection
  Future<void> waitForConnection({Duration? timeout}) async {
    if (isConnected) return;
    
    final completer = Completer<void>();
    late StreamSubscription subscription;
    
    subscription = networkInfoStream.listen((networkInfo) {
      if (networkInfo.isConnected) {
        subscription.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });
    
    if (timeout != null) {
      Timer(timeout, () {
        subscription.cancel();
        if (!completer.isCompleted) {
          completer.completeError(
            NetworkException.timeout(),
          );
        }
      });
    }
    
    return completer.future;
  }
  
  // Execute a function when connected
  Future<T> executeWhenConnected<T>(
    Future<T> Function() function, {
    Duration? timeout,
    bool retryOnFailure = true,
    int maxRetries = 3,
  }) async {
    await waitForConnection(timeout: timeout);
    
    var attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await function();
      } catch (e) {
        attempts++;
        if (!retryOnFailure || attempts >= maxRetries) {
          rethrow;
        }
        
        // Wait before retry
        await Future.delayed(Duration(seconds: attempts * 2));
        
        // Check if still connected
        if (!isConnected) {
          await waitForConnection(timeout: timeout);
        }
      }
    }
    
    throw NetworkException.serverError();
  }
  
  // Get network quality score (0-100)
  int getNetworkQualityScore() {
    if (!isConnected) return 0;
    
    var score = 50; // Base score for being connected
    
    // Connection type bonus
    switch (connectionType) {
      case ConnectionType.ethernet:
        score += 30;
        break;
      case ConnectionType.wifi:
        score += 25;
        break;
      case ConnectionType.mobile:
        score += 15;
        break;
      default:
        score += 10;
    }
    
    // Signal strength bonus
    final signalStrength = _currentNetworkInfo.signalStrength;
    if (signalStrength != null) {
      score += (signalStrength * 0.2).round();
    }
    
    // Speed bonus
    final speed = _currentNetworkInfo.speed;
    if (speed != null) {
      if (speed > 10) {
        score += 20;
      } else if (speed > 5) {
        score += 15;
      } else if (speed > 1) {
        score += 10;
      }
    }
    
    // Ping penalty
    final avgPing = getAveragePing();
    if (avgPing != null) {
      if (avgPing < 50) {
        score += 10;
      } else if (avgPing > 200) {
        score -= 10;
      }
    }
    
    return score.clamp(0, 100);
  }
  
  // Get network recommendations
  List<String> getNetworkRecommendations() {
    final recommendations = <String>[];
    
    if (!isConnected) {
      recommendations.add('Check your internet connection');
      recommendations.add('Try switching between WiFi and mobile data');
      return recommendations;
    }
    
    final qualityScore = getNetworkQualityScore();
    
    if (qualityScore < 30) {
      recommendations.add('Poor network quality detected');
      recommendations.add('Consider switching to a different network');
    }
    
    if (isMetered) {
      recommendations.add('You are on a metered connection');
      recommendations.add('Large downloads may incur charges');
    }
    
    final signalStrength = _currentNetworkInfo.signalStrength;
    if (signalStrength != null && signalStrength < 30) {
      recommendations.add('Weak signal detected');
      recommendations.add('Move closer to your router or cell tower');
    }
    
    final avgPing = getAveragePing();
    if (avgPing != null && avgPing > 200) {
      recommendations.add('High latency detected');
      recommendations.add('Network may feel slow for real-time activities');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Network connection is good');
    }
    
    return recommendations;
  }
  
  // Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _speedTestTimer?.cancel();
    _pingTimer?.cancel();
    _networkInfoController.close();
  }
}

// Network-aware widget mixin
mixin NetworkAware {
  StreamSubscription<NetworkInfo>? _networkSubscription;
  
  void startNetworkMonitoring({
    required void Function(NetworkInfo) onNetworkChanged,
    void Function()? onConnected,
    void Function()? onDisconnected,
  }) {
    _networkSubscription = ConnectivityManager.instance.networkInfoStream.listen(
      (networkInfo) {
        onNetworkChanged(networkInfo);
        
        if (networkInfo.isConnected && onConnected != null) {
          onConnected();
        } else if (networkInfo.isDisconnected && onDisconnected != null) {
          onDisconnected();
        }
      },
    );
  }
  
  void stopNetworkMonitoring() {
    _networkSubscription?.cancel();
    _networkSubscription = null;
  }
}

// Network utilities
class NetworkUtils {
  // Check if URL is reachable
  static Future<bool> isUrlReachable(String url) async {
    try {
      final uri = Uri.parse(url);
      final client = HttpClient();
      final request = await client.headUrl(uri)
          .timeout(const Duration(seconds: 10));
      final response = await request.close();
      client.close();
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (e) {
      return false;
    }
  }
  
  // Get public IP address
  static Future<String?> getPublicIPAddress() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://api.ipify.org'),
      ).timeout(const Duration(seconds: 10));
      
      final response = await request.close();
      if (response.statusCode == 200) {
        final ip = await response.transform(utf8.decoder).join();
        client.close();
        return ip.trim();
      }
      
      client.close();
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Download file with progress
  static Future<void> downloadFile(
    String url,
    String filePath, {
    void Function(int received, int total)? onProgress,
    Map<String, String>? headers,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.set(key, value);
        });
      }
      
      final response = await request.close();
      
      if (response.statusCode != 200) {
        throw NetworkException.serverError();
      }
      
      final file = File(filePath);
      final sink = file.openWrite();
      
      final contentLength = response.contentLength;
      var received = 0;
      
      await response.listen(
        (chunk) {
          sink.add(chunk);
          received += chunk.length;
          onProgress?.call(received, contentLength);
        },
        onDone: sink.close,
        onError: (error) => sink.close(),
      ).asFuture();
      
    } finally {
      client.close();
    }
  }
  
  // Check if device is online
  static Future<bool> isOnline() async => ConnectivityManager.instance.isConnected;
  
  // Get connection type
  static ConnectionType getConnectionType() => ConnectivityManager.instance.connectionType;
  
  // Check if connection is metered
  static bool isMeteredConnection() => ConnectivityManager.instance.isMetered;
}