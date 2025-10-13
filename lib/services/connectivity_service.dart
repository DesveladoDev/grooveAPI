import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Servicio para manejar la conectividad de red y evitar errores de conexión
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  bool _isConnected = true;
  bool get isConnected => _isConnected;
  
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  /// Inicializa el servicio de conectividad
  Future<void> initialize() async {
    try {
      // Verificar conectividad inicial
      await _checkConnectivity();
      
      // Escuchar cambios de conectividad
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (error) {
          debugPrint('Error en conectividad: $error');
        },
      );
    } catch (e) {
      debugPrint('Error al inicializar ConnectivityService: $e');
    }
  }

  /// Verifica si hay conexión a internet
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      
      // Si no hay conectividad, retornar false
      if (connectivityResults.contains(ConnectivityResult.none)) {
        return false;
      }
      
      // Verificar conexión real haciendo ping a un servidor confiable
      return await _pingServer();
    } catch (e) {
      debugPrint('Error al verificar conexión a internet: $e');
      return false;
    }
  }

  /// Hace ping a un servidor para verificar conectividad real
  Future<bool> _pingServer() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (e) {
      debugPrint('Error en ping: $e');
      return false;
    }
  }

  /// Maneja cambios en la conectividad
  void _onConnectivityChanged(List<ConnectivityResult> results) async {
    await _checkConnectivity();
  }

  /// Verifica el estado actual de conectividad
  Future<void> _checkConnectivity() async {
    try {
      final hasConnection = await hasInternetConnection();
      
      if (_isConnected != hasConnection) {
        _isConnected = hasConnection;
        _connectionController.add(_isConnected);
        
        debugPrint('Estado de conectividad: ${_isConnected ? "Conectado" : "Desconectado"}');
      }
    } catch (e) {
      debugPrint('Error al verificar conectividad: $e');
    }
  }

  /// Espera hasta que haya conexión disponible
  Future<void> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    if (_isConnected) return;
    
    final completer = Completer<void>();
    late StreamSubscription subscription;
    
    subscription = connectionStream.listen((isConnected) {
      if (isConnected) {
        subscription.cancel();
        completer.complete();
      }
    });
    
    // Timeout para evitar esperas infinitas
    Timer(timeout, () {
      if (!completer.isCompleted) {
        subscription.cancel();
        completer.completeError(TimeoutException('Timeout esperando conexión', timeout));
      }
    });
    
    return completer.future;
  }

  /// Ejecuta una función solo si hay conexión
  Future<T?> executeWithConnection<T>(
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      if (!_isConnected) {
        await waitForConnection(timeout: timeout);
      }
      
      return await operation();
    } catch (e) {
      debugPrint('Error al ejecutar operación con conexión: $e');
      rethrow;
    }
  }

  /// Reintenta una operación con backoff exponencial
  Future<T?> retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    Duration delay = initialDelay;
    
    while (attempts < maxRetries) {
      try {
        return await executeWithConnection(operation);
      } catch (e) {
        attempts++;
        
        if (attempts >= maxRetries) {
          rethrow;
        }
        
        debugPrint('Intento $attempts falló, reintentando en ${delay.inSeconds}s: $e');
        await Future.delayed(delay);
        delay *= 2; // Backoff exponencial
      }
    }
    
    throw Exception('Máximo número de reintentos alcanzado');
  }

  /// Libera recursos
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionController.close();
  }
}

/// Extensión para facilitar el uso del servicio de conectividad
extension ConnectivityExtension on Future {
  /// Ejecuta el Future solo si hay conexión
  Future<T?> withConnection<T>() async {
    final connectivityService = ConnectivityService();
    return await connectivityService.executeWithConnection(() => this as Future<T>);
  }
}