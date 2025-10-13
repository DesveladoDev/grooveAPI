import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'logging_service.dart';
import 'observability_service.dart';

/// Eventos predefinidos de la aplicación
class AppEvents {
  // Eventos de autenticación
  static const String signUp = 'sign_up';
  static const String signIn = 'sign_in';
  static const String signOut = 'sign_out';
  static const String passwordReset = 'password_reset';

  // Eventos de navegación
  static const String screenView = 'screen_view';
  static const String buttonTap = 'button_tap';
  static const String linkTap = 'link_tap';

  // Eventos de booking
  static const String bookingStarted = 'booking_started';
  static const String bookingCompleted = 'booking_completed';
  static const String bookingCancelled = 'booking_cancelled';
  static const String bookingModified = 'booking_modified';

  // Eventos de búsqueda
  static const String search = 'search';
  static const String searchResultTap = 'search_result_tap';
  static const String filterApplied = 'filter_applied';

  // Eventos de perfil
  static const String profileUpdated = 'profile_updated';
  static const String avatarChanged = 'avatar_changed';
  static const String preferencesChanged = 'preferences_changed';

  // Eventos de error
  static const String error = 'error';
  static const String crashReport = 'crash_report';

  // Eventos de performance
  static const String performanceIssue = 'performance_issue';
  static const String slowOperation = 'slow_operation';

  // Eventos de engagement
  static const String sessionStart = 'session_start';
  static const String sessionEnd = 'session_end';
  static const String featureUsed = 'feature_used';
  static const String tutorialCompleted = 'tutorial_completed';
}

/// Propiedades personalizadas de eventos
class EventProperties {
  // Propiedades de usuario
  static const String userId = 'user_id';
  static const String userType = 'user_type';
  static const String userTier = 'user_tier';

  // Propiedades de contenido
  static const String contentType = 'content_type';
  static const String contentId = 'content_id';
  static const String category = 'category';

  // Propiedades de booking
  static const String bookingId = 'booking_id';
  static const String roomType = 'room_type';
  static const String duration = 'duration';
  static const String price = 'price';

  // Propiedades técnicas
  static const String platform = 'platform';
  static const String appVersion = 'app_version';
  static const String errorCode = 'error_code';
  static const String errorMessage = 'error_message';

  // Propiedades de performance
  static const String loadTime = 'load_time_ms';
  static const String memoryUsage = 'memory_usage_mb';
  static const String networkLatency = 'network_latency_ms';
}

/// Métricas de conversión y funnel
class ConversionFunnel {
  final String name;
  final List<String> steps;
  final Map<String, DateTime> stepTimestamps;
  final Map<String, Map<String, dynamic>> stepProperties;

  ConversionFunnel(this.name, this.steps)
      : stepTimestamps = {},
        stepProperties = {};

  void recordStep(String step, {Map<String, dynamic>? properties}) {
    if (!steps.contains(step)) {
      LoggingService.warning(
        'Step $step not found in funnel $name',
        category: LogCategory.analytics,
      );
      return;
    }

    stepTimestamps[step] = DateTime.now();
    if (properties != null) {
      stepProperties[step] = properties;
    }

    AnalyticsService.trackEvent(
      'funnel_step',
      properties: {
        'funnel_name': name,
        'step': step,
        'step_index': steps.indexOf(step),
        ...?properties,
      },
    );
  }

  bool isCompleted() {
    return steps.every((step) => stepTimestamps.containsKey(step));
  }

  Duration? getStepDuration(String step) {
    final stepIndex = steps.indexOf(step);
    if (stepIndex <= 0) return null;

    final currentStepTime = stepTimestamps[step];
    final previousStepTime = stepTimestamps[steps[stepIndex - 1]];

    if (currentStepTime != null && previousStepTime != null) {
      return currentStepTime.difference(previousStepTime);
    }

    return null;
  }

  Duration? getTotalDuration() {
    if (steps.isEmpty) return null;

    final firstStepTime = stepTimestamps[steps.first];
    final lastStepTime = stepTimestamps[steps.last];

    if (firstStepTime != null && lastStepTime != null) {
      return lastStepTime.difference(firstStepTime);
    }

    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'steps': steps,
      'completed_steps': stepTimestamps.keys.toList(),
      'is_completed': isCompleted(),
      'total_duration_ms': getTotalDuration()?.inMilliseconds,
      'step_durations': Map.fromEntries(
        steps.map((step) => MapEntry(
          step,
          getStepDuration(step)?.inMilliseconds,
        )).where((entry) => entry.value != null),
      ),
    };
  }
}

/// Servicio de Analytics personalizado
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static FirebaseAnalytics? _analytics;
  static final Map<String, ConversionFunnel> _activeFunnels = {};
  static final Map<String, dynamic> _userProperties = {};
  static bool _isInitialized = false;

  /// Inicializa el servicio de Analytics
  static Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      
      // Configurar propiedades por defecto
      await _setDefaultProperties();
      
      _isInitialized = true;

      LoggingService.info(
        'Analytics service initialized',
        category: LogCategory.analytics,
      );

      // Registrar inicio de sesión
      await trackEvent(AppEvents.sessionStart);
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to initialize analytics service',
        category: LogCategory.analytics,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Configura propiedades por defecto
  static Future<void> _setDefaultProperties() async {
    if (_analytics == null) return;

    try {
      final deviceInfo = ObservabilityService.deviceInfo;
      if (deviceInfo != null) {
        await _analytics!.setUserProperty(
          name: EventProperties.platform,
          value: deviceInfo.platform,
        );
        await _analytics!.setUserProperty(
          name: EventProperties.appVersion,
          value: deviceInfo.appVersion,
        );
      }
    } catch (e) {
      LoggingService.warning(
        'Failed to set default analytics properties',
        category: LogCategory.analytics,
        error: e,
      );
    }
  }

  /// Rastrea un evento personalizado
  static Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized || _analytics == null) {
      LoggingService.warning(
        'Analytics not initialized, queuing event: $eventName',
        category: LogCategory.analytics,
      );
      return;
    }

    try {
      // Agregar propiedades del usuario a todos los eventos
      final eventProperties = <String, dynamic>{
        ..._userProperties,
        ...?properties,
      };

      // Convertir valores a tipos compatibles con Firebase Analytics
      final sanitizedProperties = _sanitizeProperties(eventProperties);

      await _analytics!.logEvent(
        name: eventName,
        parameters: sanitizedProperties,
      );

      LoggingService.debug(
        'Analytics event tracked: $eventName',
        category: LogCategory.analytics,
        context: LogContext(
          feature: 'analytics',
          metadata: {
            'event': eventName,
            'properties': sanitizedProperties,
          },
        ),
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to track analytics event: $eventName',
        category: LogCategory.analytics,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Sanitiza propiedades para Firebase Analytics
  static Map<String, Object> _sanitizeProperties(Map<String, dynamic> properties) {
    final sanitized = <String, Object>{};

    for (final entry in properties.entries) {
      final key = entry.key;
      final value = entry.value;

      // Firebase Analytics solo acepta ciertos tipos
      if (value is String) {
        sanitized[key] = value;
      } else if (value is int) {
        sanitized[key] = value;
      } else if (value is double) {
        sanitized[key] = value;
      } else if (value is bool) {
        sanitized[key] = value;
      } else if (value != null) {
        sanitized[key] = value.toString();
      }
    }

    return sanitized;
  }

  /// Establece propiedades del usuario
  static Future<void> setUserProperties(Map<String, dynamic> properties) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      _userProperties.addAll(properties);

      for (final entry in properties.entries) {
        if (entry.value is String) {
          await _analytics!.setUserProperty(
            name: entry.key,
            value: entry.value as String,
          );
        }
      }

      LoggingService.debug(
        'User properties updated',
        category: LogCategory.analytics,
        context: LogContext(
          feature: 'analytics',
          metadata: properties,
        ),
      );
    } catch (e) {
      LoggingService.error(
        'Failed to set user properties',
        category: LogCategory.analytics,
        error: e,
      );
    }
  }

  /// Establece el ID del usuario
  static Future<void> setUserId(String? userId) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.setUserId(id: userId);
      
      if (userId != null) {
        _userProperties[EventProperties.userId] = userId;
      } else {
        _userProperties.remove(EventProperties.userId);
      }

      LoggingService.debug(
        'User ID set: $userId',
        category: LogCategory.analytics,
      );
    } catch (e) {
      LoggingService.error(
        'Failed to set user ID',
        category: LogCategory.analytics,
        error: e,
      );
    }
  }

  /// Rastrea una vista de pantalla
  static Future<void> trackScreenView(
    String screenName, {
    String? screenClass,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      AppEvents.screenView,
      properties: {
        'screen_name': screenName,
        if (screenClass != null) 'screen_class': screenClass,
        ...?properties,
      },
    );

    // También usar el método específico de Firebase
    if (_analytics != null) {
      try {
        await _analytics!.logScreenView(
          screenName: screenName,
          screenClass: screenClass,
        );
      } catch (e) {
        LoggingService.warning(
          'Failed to log screen view to Firebase',
          category: LogCategory.analytics,
          error: e,
        );
      }
    }
  }

  /// Rastrea eventos de autenticación
  static Future<void> trackAuthEvent(
    String eventType, {
    String? method,
    bool? success,
    String? errorCode,
  }) async {
    await trackEvent(
      eventType,
      properties: {
        if (method != null) 'method': method,
        if (success != null) 'success': success,
        if (errorCode != null) EventProperties.errorCode: errorCode,
      },
    );
  }

  /// Rastrea eventos de booking
  static Future<void> trackBookingEvent(
    String eventType, {
    String? bookingId,
    String? roomType,
    int? duration,
    double? price,
    Map<String, dynamic>? additionalProperties,
  }) async {
    await trackEvent(
      eventType,
      properties: {
        if (bookingId != null) EventProperties.bookingId: bookingId,
        if (roomType != null) EventProperties.roomType: roomType,
        if (duration != null) EventProperties.duration: duration,
        if (price != null) EventProperties.price: price,
        ...?additionalProperties,
      },
    );
  }

  /// Rastrea eventos de búsqueda
  static Future<void> trackSearchEvent(
    String query, {
    int? resultCount,
    String? category,
    Map<String, dynamic>? filters,
  }) async {
    await trackEvent(
      AppEvents.search,
      properties: {
        'search_term': query,
        if (resultCount != null) 'result_count': resultCount,
        if (category != null) EventProperties.category: category,
        if (filters != null) 'filters': filters.toString(),
      },
    );
  }

  /// Rastrea eventos de error
  static Future<void> trackError(
    String errorType, {
    String? errorMessage,
    String? errorCode,
    String? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    await trackEvent(
      AppEvents.error,
      properties: {
        'error_type': errorType,
        if (errorMessage != null) EventProperties.errorMessage: errorMessage,
        if (errorCode != null) EventProperties.errorCode: errorCode,
        if (stackTrace != null) 'stack_trace': stackTrace.substring(0, 500), // Limitar longitud
        ...?context,
      },
    );
  }

  /// Rastrea eventos de performance
  static Future<void> trackPerformanceEvent(
    String eventType, {
    int? loadTime,
    int? memoryUsage,
    int? networkLatency,
    Map<String, dynamic>? additionalMetrics,
  }) async {
    await trackEvent(
      eventType,
      properties: {
        if (loadTime != null) EventProperties.loadTime: loadTime,
        if (memoryUsage != null) EventProperties.memoryUsage: memoryUsage,
        if (networkLatency != null) EventProperties.networkLatency: networkLatency,
        ...?additionalMetrics,
      },
    );
  }

  /// Inicia un funnel de conversión
  static void startConversionFunnel(String funnelName, List<String> steps) {
    _activeFunnels[funnelName] = ConversionFunnel(funnelName, steps);
    
    LoggingService.debug(
      'Started conversion funnel: $funnelName',
      category: LogCategory.analytics,
      context: LogContext(
        feature: 'conversion_funnel',
        metadata: {'funnel_name': funnelName, 'steps': steps},
      ),
    );
  }

  /// Registra un paso en un funnel de conversión
  static void recordFunnelStep(
    String funnelName,
    String step, {
    Map<String, dynamic>? properties,
  }) {
    final funnel = _activeFunnels[funnelName];
    if (funnel != null) {
      funnel.recordStep(step, properties: properties);
    } else {
      LoggingService.warning(
        'Funnel $funnelName not found',
        category: LogCategory.analytics,
      );
    }
  }

  /// Completa un funnel de conversión
  static void completeFunnel(String funnelName) {
    final funnel = _activeFunnels.remove(funnelName);
    if (funnel != null) {
      trackEvent(
        'funnel_completed',
        properties: funnel.toMap(),
      );

      LoggingService.info(
        'Conversion funnel completed: $funnelName',
        category: LogCategory.analytics,
        context: LogContext(
          feature: 'conversion_funnel',
          metadata: funnel.toMap(),
        ),
      );
    }
  }

  /// Abandona un funnel de conversión
  static void abandonFunnel(String funnelName, {String? reason}) {
    final funnel = _activeFunnels.remove(funnelName);
    if (funnel != null) {
      final funnelData = funnel.toMap();
      if (reason != null) {
        funnelData['abandon_reason'] = reason;
      }

      trackEvent(
        'funnel_abandoned',
        properties: funnelData,
      );

      LoggingService.info(
        'Conversion funnel abandoned: $funnelName',
        category: LogCategory.analytics,
        context: LogContext(
          feature: 'conversion_funnel',
          metadata: funnelData,
        ),
      );
    }
  }

  /// Obtiene funnels activos
  static List<String> get activeFunnels => _activeFunnels.keys.toList();

  /// Obtiene información de un funnel específico
  static ConversionFunnel? getFunnel(String funnelName) => _activeFunnels[funnelName];

  /// Habilita/deshabilita la colección de analytics
  static Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    if (_analytics != null) {
      try {
        await _analytics!.setAnalyticsCollectionEnabled(enabled);
        
        LoggingService.info(
          'Analytics collection ${enabled ? 'enabled' : 'disabled'}',
          category: LogCategory.analytics,
        );
      } catch (e) {
        LoggingService.error(
          'Failed to set analytics collection enabled',
          category: LogCategory.analytics,
          error: e,
        );
      }
    }
  }

  /// Limpia datos de analytics
  static Future<void> cleanup() async {
    try {
      // Completar funnels pendientes
      final activeFunnelNames = _activeFunnels.keys.toList();
      for (final funnelName in activeFunnelNames) {
        abandonFunnel(funnelName, reason: 'app_cleanup');
      }

      // Registrar fin de sesión
      await trackEvent(AppEvents.sessionEnd);

      _userProperties.clear();

      LoggingService.info(
        'Analytics service cleaned up',
        category: LogCategory.analytics,
      );
    } catch (e) {
      LoggingService.error(
        'Failed to cleanup analytics service',
        category: LogCategory.analytics,
        error: e,
      );
    }
  }

  /// Obtiene el observer para navegación
  static FirebaseAnalyticsObserver? getNavigatorObserver() {
    try {
      // Verificar si Firebase está inicializado
      if (Firebase.apps.isEmpty) {
        LoggingService.warning(
          'Firebase not initialized yet, returning null observer',
          category: LogCategory.analytics,
        );
        return null;
      }
      
      // Si _analytics no está inicializado, inicializarlo de forma síncrona
      if (_analytics == null) {
        _analytics = FirebaseAnalytics.instance;
      }
      return FirebaseAnalyticsObserver(analytics: _analytics!);
    } catch (e) {
      LoggingService.error(
        'Error creating FirebaseAnalyticsObserver',
        category: LogCategory.analytics,
        error: e,
      );
      return null;
    }
  }
}