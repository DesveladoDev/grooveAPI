import 'package:flutter/material.dart';
import '../services/logging_service.dart';
import '../services/observability_service.dart';
import '../services/analytics_service.dart';

/// Ejemplos de uso de los servicios de logging, observabilidad y analytics
class LoggingExamples {
  
  /// Ejemplo de logging básico
  static void basicLoggingExample() {
    // Logging simple
    LoggingService.debug('Debug message for development');
    LoggingService.info('User logged in successfully');
    LoggingService.warning('API rate limit approaching');
    LoggingService.error('Failed to save user data');
    LoggingService.critical('Database connection lost');
  }

  /// Ejemplo de logging con contexto
  static void contextualLoggingExample() {
    LoggingService.info(
      'User profile updated',
      category: LogCategory.user,
      context: LogContext(
        userId: 'user123',
        feature: 'profile_management',
        metadata: {
          'fields_updated': ['name', 'email'],
          'update_source': 'mobile_app',
        },
      ),
    );
  }

  /// Ejemplo de logging de errores con stack trace
  static void errorLoggingExample() {
    try {
      // Simular una operación que falla
      throw Exception('Network timeout');
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to fetch user bookings',
        category: LogCategory.booking,
        error: e,
        stackTrace: stackTrace,
        context: LogContext(
          userId: 'user123',
          feature: 'booking_list',
          metadata: {
            'retry_count': 3,
            'endpoint': '/api/bookings',
          },
        ),
      );
    }
  }

  /// Ejemplo de logging de performance
  static void performanceLoggingExample() {
    final stopwatch = Stopwatch()..start();
    
    // Simular operación
    Future.delayed(Duration(milliseconds: 250)).then((_) {
      stopwatch.stop();
      
      LoggingService.logPerformance(
        'Database query execution',
        stopwatch.elapsed,
        metadata: {
          'query_type': 'SELECT',
          'table': 'bookings',
          'rows_returned': 25,
        },
      );
    });
  }

  /// Ejemplo de observabilidad con traces
  static Future<void> observabilityTraceExample() async {
    // Iniciar un trace personalizado
    await ObservabilityService.startTrace('user_booking_flow');
    
    try {
      // Simular pasos del proceso
      await Future.delayed(Duration(milliseconds: 100));
      ObservabilityService.setTraceMetric('user_booking_flow', 'validation_time_ms', 100);
      
      await Future.delayed(Duration(milliseconds: 200));
      ObservabilityService.setTraceMetric('user_booking_flow', 'payment_time_ms', 200);
      
      await Future.delayed(Duration(milliseconds: 150));
      ObservabilityService.setTraceMetric('user_booking_flow', 'confirmation_time_ms', 150);
      
    } finally {
      // Siempre detener el trace
      await ObservabilityService.stopTrace('user_booking_flow');
    }
  }

  /// Ejemplo de observabilidad con wrapper
  static Future<String> observabilityWrapperExample() async {
    return await ObservabilityService.withTrace(
      'api_call_user_data',
      () async {
        // Simular llamada a API
        await Future.delayed(Duration(milliseconds: 300));
        return 'User data fetched successfully';
      },
      metrics: {
        'cache_hit': 0,
        'network_calls': 1,
      },
    );
  }

  /// Ejemplo de métricas de aplicación
  static void appMetricsExample() {
    // Iniciar métricas para una sesión de usuario
    ObservabilityService.startAppMetrics('user_session');
    
    // Incrementar contadores durante la sesión
    ObservabilityService.incrementAppCounter('user_session', 'screens_viewed');
    ObservabilityService.incrementAppCounter('user_session', 'buttons_tapped', 3);
    
    // Establecer gauges
    ObservabilityService.setAppGauge('user_session', 'battery_level', 0.85);
    ObservabilityService.setAppGauge('user_session', 'network_strength', 0.92);
    
    // Al final de la sesión
    ObservabilityService.stopAppMetrics('user_session');
  }

  /// Ejemplo de analytics básico
  static void basicAnalyticsExample() {
    // Eventos simples
    AnalyticsService.trackEvent('button_clicked', properties: {
      'button_name': 'book_now',
      'screen': 'room_details',
    });

    AnalyticsService.trackEvent('feature_used', properties: {
      'feature_name': 'search_filter',
      'filter_type': 'price_range',
    });
  }

  /// Ejemplo de analytics de autenticación
  static void authAnalyticsExample() {
    // Registro exitoso
    AnalyticsService.trackAuthEvent(
      AppEvents.signUp,
      method: 'email',
      success: true,
    );

    // Login fallido
    AnalyticsService.trackAuthEvent(
      AppEvents.signIn,
      method: 'google',
      success: false,
      errorCode: 'invalid_credentials',
    );
  }

  /// Ejemplo de analytics de booking
  static void bookingAnalyticsExample() {
    AnalyticsService.trackBookingEvent(
      AppEvents.bookingCompleted,
      bookingId: 'booking_123',
      roomType: 'studio_a',
      duration: 120, // minutos
      price: 150.0,
      additionalProperties: {
        'payment_method': 'credit_card',
        'discount_applied': true,
        'booking_source': 'mobile_app',
      },
    );
  }

  /// Ejemplo de funnel de conversión
  static void conversionFunnelExample() {
    // Definir pasos del funnel
    final funnelSteps = [
      'search_initiated',
      'results_viewed',
      'room_selected',
      'booking_form_opened',
      'payment_initiated',
      'booking_confirmed',
    ];

    // Iniciar funnel
    AnalyticsService.startConversionFunnel('booking_funnel', funnelSteps);

    // Registrar pasos conforme el usuario avanza
    AnalyticsService.recordFunnelStep('booking_funnel', 'search_initiated', properties: {
      'search_term': 'studio recording',
      'location': 'mexico_city',
    });

    AnalyticsService.recordFunnelStep('booking_funnel', 'results_viewed', properties: {
      'results_count': 12,
      'filters_applied': ['price', 'availability'],
    });

    AnalyticsService.recordFunnelStep('booking_funnel', 'room_selected', properties: {
      'room_id': 'studio_a_001',
      'room_type': 'recording_studio',
    });

    // Si el usuario completa todo el proceso
    AnalyticsService.completeFunnel('booking_funnel');

    // O si abandona el proceso
    // AnalyticsService.abandonFunnel('booking_funnel', reason: 'price_too_high');
  }

  /// Ejemplo de tracking de errores
  static void errorTrackingExample() {
    try {
      // Simular error
      throw Exception('Payment processing failed');
    } catch (e, stackTrace) {
      // Registrar en logging
      LoggingService.error(
        'Payment processing error',
        category: LogCategory.payment,
        error: e,
        stackTrace: stackTrace,
      );

      // Registrar en analytics
      AnalyticsService.trackError(
        'payment_error',
        errorMessage: e.toString(),
        errorCode: 'PAYMENT_FAILED',
        context: {
          'payment_method': 'credit_card',
          'amount': 150.0,
          'currency': 'MXN',
        },
      );
    }
  }

  /// Ejemplo de tracking de performance
  static void performanceTrackingExample() {
    final stopwatch = Stopwatch()..start();

    // Simular operación lenta
    Future.delayed(Duration(milliseconds: 2000)).then((_) {
      stopwatch.stop();

      // Si la operación es lenta, registrarla
      if (stopwatch.elapsedMilliseconds > 1000) {
        AnalyticsService.trackPerformanceEvent(
          AppEvents.slowOperation,
          loadTime: stopwatch.elapsedMilliseconds,
          additionalMetrics: {
            'operation_type': 'image_upload',
            'file_size_mb': 5.2,
            'network_type': 'wifi',
          },
        );

        LoggingService.warning(
          'Slow operation detected',
          category: LogCategory.performance,
          context: LogContext(
            feature: 'image_upload',
            metadata: {
              'duration_ms': stopwatch.elapsedMilliseconds,
              'threshold_ms': 1000,
            },
          ),
        );
      }
    });
  }

  /// Ejemplo de configuración de usuario
  static void userPropertiesExample() {
    // Establecer propiedades del usuario
    AnalyticsService.setUserId('user_123');
    
    AnalyticsService.setUserProperties({
      EventProperties.userType: 'premium',
      EventProperties.userTier: 'gold',
      'signup_date': '2024-01-15',
      'preferred_language': 'es',
      'total_bookings': '15',
    });
  }

  /// Ejemplo de tracking de pantallas
  static void screenTrackingExample() {
    AnalyticsService.trackScreenView(
      'room_details',
      screenClass: 'RoomDetailsScreen',
      properties: {
        'room_id': 'studio_a_001',
        'room_type': 'recording_studio',
        'source': 'search_results',
      },
    );
  }

  /// Ejemplo completo de flujo de booking
  static Future<void> completeBookingFlowExample() async {
    // 1. Iniciar métricas de la sesión
    ObservabilityService.startAppMetrics('booking_session');
    
    // 2. Iniciar funnel de conversión
    AnalyticsService.startConversionFunnel('booking_flow', [
      'search',
      'room_view',
      'booking_form',
      'payment',
      'confirmation'
    ]);

    // 3. Iniciar trace de performance
    await ObservabilityService.startTrace('booking_process');

    try {
      // 4. Búsqueda
      LoggingService.info(
        'User initiated search',
        category: LogCategory.booking,
        context: LogContext(
          userId: 'user_123',
          feature: 'room_search',
        ),
      );

      AnalyticsService.recordFunnelStep('booking_flow', 'search');
      ObservabilityService.incrementAppCounter('booking_session', 'searches');

      // 5. Ver detalles de sala
      await Future.delayed(Duration(milliseconds: 200));
      AnalyticsService.trackScreenView('room_details');
      AnalyticsService.recordFunnelStep('booking_flow', 'room_view');
      ObservabilityService.setTraceMetric('booking_process', 'room_load_time_ms', 200);

      // 6. Llenar formulario
      await Future.delayed(Duration(milliseconds: 500));
      AnalyticsService.recordFunnelStep('booking_flow', 'booking_form');
      ObservabilityService.setTraceMetric('booking_process', 'form_fill_time_ms', 500);

      // 7. Procesar pago
      await Future.delayed(Duration(milliseconds: 1000));
      AnalyticsService.recordFunnelStep('booking_flow', 'payment');
      ObservabilityService.setTraceMetric('booking_process', 'payment_time_ms', 1000);

      // 8. Confirmación
      AnalyticsService.recordFunnelStep('booking_flow', 'confirmation');
      AnalyticsService.completeFunnel('booking_flow');

      LoggingService.info(
        'Booking completed successfully',
        category: LogCategory.booking,
        context: LogContext(
          userId: 'user_123',
          feature: 'booking_completion',
          metadata: {
            'booking_id': 'booking_456',
            'total_time_ms': 1700,
          },
        ),
      );

    } catch (e, stackTrace) {
      // Manejar errores
      LoggingService.error(
        'Booking process failed',
        category: LogCategory.booking,
        error: e,
        stackTrace: stackTrace,
      );

      AnalyticsService.abandonFunnel('booking_flow', reason: 'process_error');
      AnalyticsService.trackError('booking_error', errorMessage: e.toString());

    } finally {
      // Limpiar recursos
      await ObservabilityService.stopTrace('booking_process');
      ObservabilityService.stopAppMetrics('booking_session');
    }
  }
}

/// Widget de ejemplo que demuestra el uso en la UI
class LoggingExampleWidget extends StatefulWidget {
  const LoggingExampleWidget({super.key});

  @override
  State<LoggingExampleWidget> createState() => _LoggingExampleWidgetState();
}

class _LoggingExampleWidgetState extends State<LoggingExampleWidget> {
  @override
  void initState() {
    super.initState();
    
    // Registrar vista de pantalla
    AnalyticsService.trackScreenView(
      'logging_examples',
      screenClass: 'LoggingExampleWidget',
    );

    // Iniciar métricas de la pantalla
    ObservabilityService.startAppMetrics('example_screen');
  }

  @override
  void dispose() {
    // Detener métricas al salir
    ObservabilityService.stopAppMetrics('example_screen');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logging Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExampleButton(
            'Basic Logging',
            LoggingExamples.basicLoggingExample,
          ),
          _buildExampleButton(
            'Contextual Logging',
            LoggingExamples.contextualLoggingExample,
          ),
          _buildExampleButton(
            'Error Logging',
            LoggingExamples.errorLoggingExample,
          ),
          _buildExampleButton(
            'Performance Logging',
            LoggingExamples.performanceLoggingExample,
          ),
          _buildAsyncExampleButton(
            'Observability Trace',
            LoggingExamples.observabilityTraceExample,
          ),
          _buildExampleButton(
            'App Metrics',
            LoggingExamples.appMetricsExample,
          ),
          _buildExampleButton(
            'Basic Analytics',
            LoggingExamples.basicAnalyticsExample,
          ),
          _buildExampleButton(
            'Conversion Funnel',
            LoggingExamples.conversionFunnelExample,
          ),
          _buildAsyncExampleButton(
            'Complete Booking Flow',
            LoggingExamples.completeBookingFlowExample,
          ),
        ],
      ),
    );
  }

  Widget _buildExampleButton(String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () {
          // Registrar interacción
          AnalyticsService.trackEvent(AppEvents.buttonTap, properties: {
            'button_name': title,
            'screen': 'logging_examples',
          });

          ObservabilityService.incrementAppCounter('example_screen', 'button_taps');

          onPressed();

          // Mostrar confirmación
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title executed')),
          );
        },
        child: Text(title),
      ),
    );
  }

  Widget _buildAsyncExampleButton(String title, Future<void> Function() onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () async {
          // Registrar interacción
          AnalyticsService.trackEvent(AppEvents.buttonTap, properties: {
            'button_name': title,
            'screen': 'logging_examples',
          });

          ObservabilityService.incrementAppCounter('example_screen', 'async_button_taps');

          try {
            await onPressed();
            
            // Mostrar confirmación
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title executed successfully')),
              );
            }
          } catch (e) {
            LoggingService.error(
              'Example execution failed',
              category: LogCategory.ui,
              error: e,
            );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title failed: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: Text(title),
      ),
    );
  }
}