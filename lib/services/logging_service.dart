import 'dart:convert';
import 'dart:developer' as developer;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

/// Niveles de logging disponibles
enum LogLevel {
  debug(0, '🔍', 'DEBUG'),
  info(1, 'ℹ️', 'INFO'),
  warning(2, '⚠️', 'WARNING'),
  error(3, '❌', 'ERROR'),
  critical(4, '🚨', 'CRITICAL');

  const LogLevel(this.priority, this.emoji, this.name);
  
  final int priority;
  final String emoji;
  final String name;
}

/// Categorías de logging para mejor organización
enum LogCategory {
  auth('AUTH'),
  booking('BOOKING'),
  payment('PAYMENT'),
  chat('CHAT'),
  notification('NOTIFICATION'),
  performance('PERFORMANCE'),
  security('SECURITY'),
  ui('UI'),
  api('API'),
  database('DATABASE'),
  analytics('ANALYTICS'),
  general('GENERAL');

  const LogCategory(this.name);
  final String name;
}

/// Contexto adicional para logs
class LogContext {
  final String? userId;
  final String? sessionId;
  final String? feature;
  final Map<String, dynamic>? metadata;
  final String? stackTrace;

  const LogContext({
    this.userId,
    this.sessionId,
    this.feature,
    this.metadata,
    this.stackTrace,
  });

  Map<String, dynamic> toMap() {
    return {
      if (userId != null) 'userId': userId,
      if (sessionId != null) 'sessionId': sessionId,
      if (feature != null) 'feature': feature,
      if (metadata != null) 'metadata': metadata,
      if (stackTrace != null) 'stackTrace': stackTrace,
    };
  }
}

/// Servicio centralizado de logging estructurado
class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  static LogLevel _minLogLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  static String? _currentUserId;
  static String? _currentSessionId;

  /// Configura el nivel mínimo de logging
  static void setMinLogLevel(LogLevel level) {
    _minLogLevel = level;
  }

  /// Establece el contexto del usuario actual
  static void setUserContext(String? userId, String? sessionId) {
    _currentUserId = userId;
    _currentSessionId = sessionId;
  }

  /// Log de debug - solo en modo desarrollo
  static void debug(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.debug, message, category, context, error, stackTrace);
  }

  /// Log de información general
  static void info(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.info, message, category, context, error, stackTrace);
  }

  /// Log de advertencias
  static void warning(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.warning, message, category, context, error, stackTrace);
  }

  /// Log de errores
  static void error(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, message, category, context, error, stackTrace);
  }

  /// Log de errores críticos
  static void critical(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.critical, message, category, context, error, stackTrace);
  }

  /// Método interno para procesar logs
  static void _log(
    LogLevel level,
    String message,
    LogCategory category,
    LogContext? context,
    Object? error,
    StackTrace? stackTrace,
  ) {
    // Verificar si el nivel es suficiente para loggear
    if (level.priority < _minLogLevel.priority) return;

    // Crear contexto completo
    final fullContext = LogContext(
      userId: context?.userId ?? _currentUserId,
      sessionId: context?.sessionId ?? _currentSessionId,
      feature: context?.feature,
      metadata: context?.metadata,
      stackTrace: context?.stackTrace ?? stackTrace?.toString(),
    );

    // Crear log estructurado
    final logData = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': level.name,
      'category': category.name,
      'message': message,
      'context': fullContext.toMap(),
      if (error != null) 'error': error.toString(),
    };

    // Output local (consola)
    _outputToConsole(level, category, message, logData);

    // Enviar a servicios externos según el nivel
    _sendToExternalServices(level, message, logData, error, stackTrace);
  }

  /// Output a consola con formato legible
  static void _outputToConsole(
    LogLevel level,
    LogCategory category,
    String message,
    Map<String, dynamic> logData,
  ) {
    final timestamp = DateTime.now().toString().substring(11, 23);
    final formattedMessage = '${level.emoji} [$timestamp] [${category.name}] $message';
    
    if (kDebugMode) {
      developer.log(
        formattedMessage,
        name: 'SalasBeats',
        level: level.priority * 300, // Convertir a nivel de dart:developer
        error: logData['error'],
        stackTrace: logData['context']['stackTrace'] != null 
            ? StackTrace.fromString(logData['context']['stackTrace'])
            : null,
      );
    } else {
      print(formattedMessage);
    }
  }

  /// Envía logs a servicios externos (Crashlytics, Analytics)
  static void _sendToExternalServices(
    LogLevel level,
    String message,
    Map<String, dynamic> logData,
    Object? error,
    StackTrace? stackTrace,
  ) {
    try {
      // Enviar a Crashlytics para errores y críticos
      if (level.priority >= LogLevel.error.priority) {
        _sendToCrashlytics(message, logData, error, stackTrace);
      }

      // Enviar eventos personalizados a Analytics
      if (level.priority >= LogLevel.warning.priority) {
        _sendToAnalytics(level, message, logData);
      }

      // Log de performance para categoría específica
      if (logData['category'] == LogCategory.performance.name) {
        _logPerformanceMetric(message, logData);
      }

    } catch (e) {
      // Evitar loops infinitos de logging
      if (kDebugMode) {
        print('Error enviando log a servicios externos: $e');
      }
    }
  }

  /// Envía errores a Firebase Crashlytics
  static void _sendToCrashlytics(
    String message,
    Map<String, dynamic> logData,
    Object? error,
    StackTrace? stackTrace,
  ) {
    try {
      // Establecer contexto del usuario
      if (logData['context']['userId'] != null) {
        FirebaseCrashlytics.instance.setUserIdentifier(
          logData['context']['userId'],
        );
      }

      // Agregar metadatos personalizados
      FirebaseCrashlytics.instance.setCustomKey('category', logData['category']);
      FirebaseCrashlytics.instance.setCustomKey('timestamp', logData['timestamp']);
      
      if (logData['context']['feature'] != null) {
        FirebaseCrashlytics.instance.setCustomKey('feature', logData['context']['feature']);
      }

      if (logData['context']['metadata'] != null) {
        final metadata = logData['context']['metadata'] as Map<String, dynamic>;
        for (final entry in metadata.entries) {
          FirebaseCrashlytics.instance.setCustomKey(entry.key, entry.value.toString());
        }
      }

      // Registrar el error
      if (error != null && stackTrace != null) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: message,
          fatal: logData['level'] == LogLevel.critical.name,
        );
      } else {
        // Crear un error sintético para logs sin excepción
        FirebaseCrashlytics.instance.recordError(
          Exception(message),
          StackTrace.current,
          reason: 'Logged ${logData['level']}: $message',
          fatal: false,
        );
      }

    } catch (e) {
      if (kDebugMode) {
        print('Error enviando a Crashlytics: $e');
      }
    }
  }

  /// Envía eventos a Firebase Analytics (placeholder)
  static void _sendToAnalytics(
    LogLevel level,
    String message,
    Map<String, dynamic> logData,
  ) {
    // TODO: Implementar cuando se configure Firebase Analytics
    // FirebaseAnalytics.instance.logEvent(
    //   name: 'app_log',
    //   parameters: {
    //     'level': level.name,
    //     'category': logData['category'],
    //     'message': message.length > 100 ? message.substring(0, 100) : message,
    //   },
    // );
  }

  /// Log específico para métricas de performance
  static void _logPerformanceMetric(
    String message,
    Map<String, dynamic> logData,
  ) {
    try {
      // Extraer métricas del metadata
      final metadata = logData['context']['metadata'] as Map<String, dynamic>?;
      if (metadata != null) {
        // Enviar métricas personalizadas a Firebase Performance
        for (final entry in metadata.entries) {
          if (entry.value is num) {
            final trace = FirebasePerformance.instance.newTrace(entry.key);
            trace.start();
            trace.setMetric('value', entry.value.toInt());
            trace.stop();
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error enviando métricas de performance: $e');
      }
    }
  }

  /// Métodos de conveniencia para casos específicos

  /// Log de autenticación
  static void logAuth(String action, {String? userId, bool success = true}) {
    final level = success ? LogLevel.info : LogLevel.error;
    final message = 'Auth $action ${success ? 'successful' : 'failed'}';
    
    _log(
      level,
      message,
      LogCategory.auth,
      LogContext(
        userId: userId,
        feature: 'authentication',
        metadata: {'action': action, 'success': success},
      ),
      null,
      null,
    );
  }

  /// Log de performance con timing
  static void logPerformance(String operation, Duration duration, {Map<String, dynamic>? metadata}) {
    info(
      'Performance: $operation completed in ${duration.inMilliseconds}ms',
      category: LogCategory.performance,
      context: LogContext(
        feature: 'performance',
        metadata: {
          'operation': operation,
          'duration_ms': duration.inMilliseconds,
          ...?metadata,
        },
      ),
    );
  }

  /// Log de eventos de UI
  static void logUserAction(String action, String screen, {Map<String, dynamic>? metadata}) {
    info(
      'User action: $action on $screen',
      category: LogCategory.ui,
      context: LogContext(
        feature: 'user_interaction',
        metadata: {
          'action': action,
          'screen': screen,
          ...?metadata,
        },
      ),
    );
  }

  /// Log de transacciones de pago
  static void logPayment(String action, {String? amount, String? currency, bool success = true}) {
    final level = success ? LogLevel.info : LogLevel.error;
    final message = 'Payment $action ${success ? 'successful' : 'failed'}';
    
    _log(
      level,
      message,
      LogCategory.payment,
      LogContext(
        feature: 'payment',
        metadata: {
          'action': action,
          'amount': amount,
          'currency': currency,
          'success': success,
        },
      ),
      null,
      null,
    );
  }

  /// Log de errores de API
  static void logApiError(String endpoint, int statusCode, String error) {
    _log(
      LogLevel.error,
      'API Error: $endpoint returned $statusCode',
      LogCategory.api,
      LogContext(
        feature: 'api_call',
        metadata: {
          'endpoint': endpoint,
          'status_code': statusCode,
          'error': error,
        },
      ),
      Exception('API Error: $error'),
      StackTrace.current,
    );
  }
}