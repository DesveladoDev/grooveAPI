import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'logging_service.dart';

/// Métricas personalizadas de la aplicación
class AppMetrics {
  final String name;
  final Map<String, int> counters;
  final Map<String, double> gauges;
  final DateTime startTime;

  AppMetrics(this.name)
      : counters = {},
        gauges = {},
        startTime = DateTime.now();

  void incrementCounter(String key, [int value = 1]) {
    counters[key] = (counters[key] ?? 0) + value;
  }

  void setGauge(String key, double value) {
    gauges[key] = value;
  }

  Duration get duration => DateTime.now().difference(startTime);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'duration_ms': duration.inMilliseconds,
      'counters': counters,
      'gauges': gauges,
      'start_time': startTime.toIso8601String(),
    };
  }
}

/// Información del dispositivo y aplicación
class DeviceInfo {
  final String platform;
  final String model;
  final String osVersion;
  final String appVersion;
  final String buildNumber;
  final bool isPhysicalDevice;

  const DeviceInfo({
    required this.platform,
    required this.model,
    required this.osVersion,
    required this.appVersion,
    required this.buildNumber,
    required this.isPhysicalDevice,
  });

  Map<String, dynamic> toMap() {
    return {
      'platform': platform,
      'model': model,
      'os_version': osVersion,
      'app_version': appVersion,
      'build_number': buildNumber,
      'is_physical_device': isPhysicalDevice,
    };
  }
}

/// Servicio de observabilidad y monitoreo
class ObservabilityService {
  static final ObservabilityService _instance = ObservabilityService._internal();
  factory ObservabilityService() => _instance;
  ObservabilityService._internal();

  static DeviceInfo? _deviceInfo;
  static final Map<String, Trace> _activeTraces = {};
  static final Map<String, AppMetrics> _activeMetrics = {};
  static final List<String> _performanceEvents = [];

  /// Inicializa el servicio de observabilidad
  static Future<void> initialize() async {
    try {
      await _collectDeviceInfo();
      await _setupPerformanceMonitoring();
      
      LoggingService.info(
        'Observability service initialized',
        category: LogCategory.performance,
        context: LogContext(
          feature: 'observability',
          metadata: _deviceInfo?.toMap(),
        ),
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to initialize observability service',
        category: LogCategory.performance,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Recopila información del dispositivo
  static Future<void> _collectDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      String platform = 'unknown';
      String model = 'unknown';
      String osVersion = 'unknown';
      bool isPhysicalDevice = true;

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        platform = 'android';
        model = '${androidInfo.brand} ${androidInfo.model}';
        osVersion = 'Android ${androidInfo.version.release}';
        isPhysicalDevice = androidInfo.isPhysicalDevice;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        platform = 'ios';
        model = iosInfo.model;
        osVersion = '${iosInfo.systemName} ${iosInfo.systemVersion}';
        isPhysicalDevice = iosInfo.isPhysicalDevice;
      } else if (kIsWeb) {
        final webInfo = await deviceInfoPlugin.webBrowserInfo;
        platform = 'web';
        model = webInfo.browserName.name;
        osVersion = webInfo.platform ?? 'unknown';
        isPhysicalDevice = false;
      }

      _deviceInfo = DeviceInfo(
        platform: platform,
        model: model,
        osVersion: osVersion,
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        isPhysicalDevice: isPhysicalDevice,
      );
    } catch (e) {
      LoggingService.warning(
        'Failed to collect device info',
        category: LogCategory.performance,
        error: e,
      );
    }
  }

  /// Configura el monitoreo de performance
  static Future<void> _setupPerformanceMonitoring() async {
    try {
      // Habilitar colección automática de datos de performance
      await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

      // Configurar traces automáticos
      await _setupAutomaticTraces();
    } catch (e) {
      LoggingService.warning(
        'Failed to setup performance monitoring',
        category: LogCategory.performance,
        error: e,
      );
    }
  }

  /// Configura traces automáticos para operaciones comunes
  static Future<void> _setupAutomaticTraces() async {
    // Los traces automáticos de HTTP ya están habilitados por defecto
    // Aquí podemos agregar configuración adicional si es necesaria
  }

  /// Inicia un trace de performance personalizado
  static Future<void> startTrace(String name) async {
    try {
      if (_activeTraces.containsKey(name)) {
        LoggingService.warning(
          'Trace $name already active, stopping previous trace',
          category: LogCategory.performance,
        );
        await stopTrace(name);
      }

      final trace = FirebasePerformance.instance.newTrace(name);
      await trace.start();
      _activeTraces[name] = trace;

      LoggingService.debug(
        'Started trace: $name',
        category: LogCategory.performance,
        context: LogContext(
          feature: 'performance_trace',
          metadata: {'trace_name': name},
        ),
      );
    } catch (e) {
      LoggingService.error(
        'Failed to start trace: $name',
        category: LogCategory.performance,
        error: e,
      );
    }
  }

  /// Detiene un trace de performance
  static Future<void> stopTrace(String name) async {
    try {
      final trace = _activeTraces.remove(name);
      if (trace != null) {
        await trace.stop();
        
        LoggingService.debug(
          'Stopped trace: $name',
          category: LogCategory.performance,
          context: LogContext(
            feature: 'performance_trace',
            metadata: {'trace_name': name},
          ),
        );
      } else {
        LoggingService.warning(
          'Attempted to stop non-existent trace: $name',
          category: LogCategory.performance,
        );
      }
    } catch (e) {
      LoggingService.error(
        'Failed to stop trace: $name',
        category: LogCategory.performance,
        error: e,
      );
    }
  }

  /// Agrega una métrica a un trace activo
  static void setTraceMetric(String traceName, String metricName, int value) {
    try {
      final trace = _activeTraces[traceName];
      if (trace != null) {
        trace.setMetric(metricName, value);
        
        LoggingService.debug(
          'Set trace metric: $traceName.$metricName = $value',
          category: LogCategory.performance,
        );
      } else {
        LoggingService.warning(
          'Attempted to set metric on non-existent trace: $traceName',
          category: LogCategory.performance,
        );
      }
    } catch (e) {
      LoggingService.error(
        'Failed to set trace metric: $traceName.$metricName',
        category: LogCategory.performance,
        error: e,
      );
    }
  }

  /// Incrementa una métrica en un trace activo
  static void incrementTraceMetric(String traceName, String metricName, [int value = 1]) {
    try {
      final trace = _activeTraces[traceName];
      if (trace != null) {
        trace.incrementMetric(metricName, value);
        
        LoggingService.debug(
          'Incremented trace metric: $traceName.$metricName by $value',
          category: LogCategory.performance,
        );
      }
    } catch (e) {
      LoggingService.error(
        'Failed to increment trace metric: $traceName.$metricName',
        category: LogCategory.performance,
        error: e,
      );
    }
  }

  /// Inicia métricas personalizadas de la aplicación
  static void startAppMetrics(String name) {
    if (_activeMetrics.containsKey(name)) {
      LoggingService.warning(
        'App metrics $name already active',
        category: LogCategory.performance,
      );
      return;
    }

    _activeMetrics[name] = AppMetrics(name);
    
    LoggingService.debug(
      'Started app metrics: $name',
      category: LogCategory.performance,
    );
  }

  /// Detiene y reporta métricas personalizadas
  static void stopAppMetrics(String name) {
    final metrics = _activeMetrics.remove(name);
    if (metrics != null) {
      LoggingService.logPerformance(
        'App metrics: $name',
        metrics.duration,
        metadata: metrics.toMap(),
      );
    }
  }

  /// Incrementa un contador en métricas activas
  static void incrementAppCounter(String metricsName, String counterName, [int value = 1]) {
    final metrics = _activeMetrics[metricsName];
    if (metrics != null) {
      metrics.incrementCounter(counterName, value);
    }
  }

  /// Establece un gauge en métricas activas
  static void setAppGauge(String metricsName, String gaugeName, double value) {
    final metrics = _activeMetrics[metricsName];
    if (metrics != null) {
      metrics.setGauge(gaugeName, value);
    }
  }

  /// Registra un evento de performance
  static void recordPerformanceEvent(String event, {Map<String, dynamic>? metadata}) {
    _performanceEvents.add(event);
    
    LoggingService.info(
      'Performance event: $event',
      category: LogCategory.performance,
      context: LogContext(
        feature: 'performance_event',
        metadata: metadata,
      ),
    );

    // Mantener solo los últimos 100 eventos
    if (_performanceEvents.length > 100) {
      _performanceEvents.removeAt(0);
    }
  }

  /// Monitorea el uso de memoria
  static Future<void> recordMemoryUsage() async {
    try {
      // En Flutter, no hay una API directa para obtener el uso de memoria
      // Pero podemos usar el canal de plataforma para obtenerlo
      const platform = MethodChannel('com.developeros.salasandbeats/memory');
      
      try {
        final memoryUsage = await platform.invokeMethod('getMemoryUsage');
        
        recordPerformanceEvent('memory_usage', metadata: {
          'memory_mb': memoryUsage,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } on PlatformException {
        // Si no está implementado el canal, usar un placeholder
        recordPerformanceEvent('memory_usage_unavailable');
      }
    } catch (e) {
      LoggingService.warning(
        'Failed to record memory usage',
        category: LogCategory.performance,
        error: e,
      );
    }
  }

  /// Monitorea el tiempo de carga de pantallas
  static void recordScreenLoadTime(String screenName, Duration loadTime) {
    recordPerformanceEvent('screen_load', metadata: {
      'screen': screenName,
      'load_time_ms': loadTime.inMilliseconds,
    });

    // También crear un trace específico para la pantalla
    final traceName = 'screen_load_$screenName';
    FirebasePerformance.instance.newTrace(traceName)
      ..start()
      ..setMetric('load_time_ms', loadTime.inMilliseconds)
      ..stop();
  }

  /// Wrapper para ejecutar código con monitoreo automático
  static Future<T> withTrace<T>(
    String traceName,
    Future<T> Function() operation, {
    Map<String, int>? metrics,
  }) async {
    await startTrace(traceName);
    
    try {
      final result = await operation();
      
      // Agregar métricas si se proporcionan
      if (metrics != null) {
        for (final entry in metrics.entries) {
          setTraceMetric(traceName, entry.key, entry.value);
        }
      }
      
      return result;
    } finally {
      await stopTrace(traceName);
    }
  }

  /// Wrapper para ejecutar código con métricas de aplicación
  static T withAppMetrics<T>(
    String metricsName,
    T Function() operation,
  ) {
    startAppMetrics(metricsName);
    
    try {
      return operation();
    } finally {
      stopAppMetrics(metricsName);
    }
  }

  /// Obtiene información del dispositivo
  static DeviceInfo? get deviceInfo => _deviceInfo;

  /// Obtiene traces activos
  static List<String> get activeTraces => _activeTraces.keys.toList();

  /// Obtiene métricas activas
  static List<String> get activeMetrics => _activeMetrics.keys.toList();

  /// Obtiene eventos de performance recientes
  static List<String> get recentPerformanceEvents => 
      List.unmodifiable(_performanceEvents);

  /// Limpia todos los traces y métricas activos
  static Future<void> cleanup() async {
    // Detener todos los traces activos
    final traceNames = _activeTraces.keys.toList();
    for (final traceName in traceNames) {
      await stopTrace(traceName);
    }

    // Detener todas las métricas activas
    final metricsNames = _activeMetrics.keys.toList();
    for (final metricsName in metricsNames) {
      stopAppMetrics(metricsName);
    }

    LoggingService.info(
      'Observability service cleaned up',
      category: LogCategory.performance,
    );
  }
}