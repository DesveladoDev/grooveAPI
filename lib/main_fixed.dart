import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:salas_beats/config/routes.dart';
import 'package:salas_beats/firebase_options.dart';
import 'package:salas_beats/providers/admin_provider.dart';
import 'package:salas_beats/providers/auth_provider.dart';
import 'package:salas_beats/providers/booking_provider.dart';
import 'package:salas_beats/providers/chat_provider.dart';
import 'package:salas_beats/providers/listing_provider.dart';
import 'package:salas_beats/providers/notification_provider.dart';
import 'package:salas_beats/providers/review_provider.dart';
import 'package:salas_beats/providers/stripe_provider.dart';
import 'package:salas_beats/services/notification_service.dart';
import 'package:salas_beats/services/logging_service.dart';
import 'package:salas_beats/services/observability_service.dart';
import 'package:salas_beats/services/analytics_service.dart';
import 'package:salas_beats/services/localization_service.dart';
import 'package:salas_beats/services/connectivity_service.dart';
import 'package:salas_beats/services/firebase_optimization_service.dart';
import 'package:salas_beats/utils/app_theme.dart';
import 'package:salas_beats/utils/font_helper.dart';
import 'package:salas_beats/generated/l10n/app_localizations.dart';
import 'package:salas_beats/widgets/persistent_error_screen.dart';

// Clave global para poder mostrar pantallas/diálogos desde handlers globales
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

// Handler para notificaciones en background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {
    // Si ya está inicializado en este isolate, continuar.
  }

  print('Handling a background message: ${message.messageId}');
}

void main() async {
  // 1. Asegurar que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Configurar manejo de errores de Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  // 3. Configurar manejo de errores de Dart/isolate
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  try {
    // 4. Inicializar Firebase PRIMERO
    print('🔥 Inicializando Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado correctamente');

    // 5. Configurar Crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    
    // 6. Configurar handler de mensajes en background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 7. Inicializar servicios críticos
    await _initializeCriticalServices();

    print('✅ Servicios críticos inicializados');

  } catch (e, stackTrace) {
    print('❌ Error durante la inicialización: $e');
    print('📋 Stack trace: $stackTrace');
    
    // Mostrar pantalla de error persistente
    runApp(MaterialApp(
      home: PersistentErrorScreen(
        details: FlutterErrorDetails(
          exception: e,
          stack: stackTrace,
        ),
      ),
    ));
    return;
  }

  // 8. Ejecutar la aplicación
  print('🚀 Iniciando aplicación...');
  runApp(const SalasBeatsApp());
}

Future<void> _initializeCriticalServices() async {
  try {
    // Inicializar servicios en orden de dependencia
    await ObservabilityService.initialize();
    
    // Configurar conectividad
    final connectivityService = ConnectivityService();
    final firebaseOptimizationService = FirebaseOptimizationService();
    await connectivityService.initialize();
    await firebaseOptimizationService.initialize();
    
    connectivityService.connectionStream.listen((isConnected) {
      if (isConnected) {
        firebaseOptimizationService.handleNetworkReconnection();
      } else {
        firebaseOptimizationService.handleNetworkDisconnection();
      }
    });

    print('✅ Servicios críticos configurados');
  } catch (e) {
    print('⚠️ Error inicializando servicios: $e');
    // No lanzar error aquí, permitir que la app continúe
  }
}

class SalasBeatsApp extends StatefulWidget {
  const SalasBeatsApp({super.key});

  @override
  State<SalasBeatsApp> createState() => _SalasBeatsAppState();
}

class _SalasBeatsAppState extends State<SalasBeatsApp> {
  Locale? _locale;
  bool _isInitialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Esperar un momento para asegurar que Firebase esté completamente listo
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Verificar que Firebase esté realmente inicializado
      if (Firebase.apps.isEmpty) {
        throw Exception('Firebase no está inicializado');
      }

      // Configurar fuentes
      await FontHelper.initializeFonts();
      
      setState(() {
        _isInitialized = true;
      });
      
      print('✅ Aplicación inicializada correctamente');
    } catch (e) {
      print('❌ Error inicializando aplicación: $e');
      setState(() {
        _initError = e.toString();
      });
    }
  }

  void _onLocaleChanged(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar pantalla de carga mientras se inicializa
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_initError != null) ...[
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $_initError'),
                ] else ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Inicializando aplicación...'),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        // Crear providers DESPUÉS de que Firebase esté inicializado
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (context) =>
            BookingProvider(Provider.of<AuthProvider>(context, listen: false))),
        ChangeNotifierProvider(create: (_) => ListingProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => StripeProvider()),
      ],
      child: MaterialApp.router(
        title: 'Salas & Beats',
        debugShowCheckedModeBanner: false,
        
        // Configuración de tema
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        
        // Configuración de localización
        locale: _locale,
        supportedLocales: const [
          Locale('en', ''),
          Locale('es', ''),
          Locale('pt', ''),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        
        // Configuración de rutas
        routerConfig: AppRoutes.createRouter(),
        
        // Observer de analytics
        builder: (context, child) {
          final analyticsObserver = AnalyticsService.getNavigatorObserver();
          return Navigator(
            observers: analyticsObserver != null ? [analyticsObserver] : const [],
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (context) => child!,
            ),
          );
        },
      ),
    );
  }
}