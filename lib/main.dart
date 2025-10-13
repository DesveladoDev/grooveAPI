import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
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
  // IMPORTANTE: El handler de background corre en un isolate separado.
  // Debe inicializar Firebase explícitamente para evitar el error
  // [core/no-app] No Firebase App 'DEFAULT' has been created.
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
  // 1. Asegura que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa Firebase de forma asíncrona ANTES que cualquier otra cosa
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  try {
    // Configurar Crashlytics de forma optimizada
    await _setupCrashlytics();
    
    // Configurar notificaciones background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Inicializar servicios de la aplicación
    await _initializeServices();
    
  } catch (e) {
    print('Error durante la inicialización: $e');
    // Continuar con la app incluso si hay errores de inicialización
  }
  
  // 3. Ejecuta tu aplicación
  runApp(const SalasBeatsApp());
}



/// Inicializa todos los servicios de la aplicación
Future<void> _initializeServices() async {
  try {
    // Inicializar servicios en orden de dependencia
    await ObservabilityService.initialize();
    await AnalyticsService.initialize();
    await LocalizationService().initialize();
    await NotificationService().initialize();
    
    // Inicializar fuentes de manera segura para evitar errores de plataforma
    await FontHelper.initializeFonts();
    
    // Inicializar servicio de conectividad para evitar errores de red
    await ConnectivityService().initialize();
    
    // Inicializar optimizaciones de Firebase para reducir errores de conexión
    await FirebaseOptimizationService().initialize();
    
    // Configurar listener de conectividad para Firebase
    _setupConnectivityListener();
    
    LoggingService.info(
      'All services initialized successfully',
      category: LogCategory.general,
    );
  } catch (e, stackTrace) {
    print('Error initializing services: $e');
    LoggingService.error(
      'Failed to initialize services',
      category: LogCategory.general,
      error: e,
      stackTrace: stackTrace,
    );
  }
}

/// Configura Crashlytics de forma optimizada para evitar warnings
Future<void> _setupCrashlytics() async {
  try {
    // Configurar la colección de datos de Crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    
    // Configurar el manejo de errores de Flutter de forma asíncrona
    FlutterError.onError = (FlutterErrorDetails errorDetails) {
      // Ejecutar en un microtask para evitar bloquear el hilo principal
      Future.microtask(() {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        
        // También registrar en nuestro sistema de logging
        LoggingService.error(
          'Flutter fatal error: ${errorDetails.exception}',
          category: LogCategory.general,
          error: errorDetails.exception,
          stackTrace: errorDetails.stack,
          context: LogContext(
            feature: 'flutter_error_handler',
            metadata: {
              'library': errorDetails.library,
              'context': errorDetails.context?.toString(),
            },
          ),
        );

        // Guardar y mostrar pantalla persistente del error
        PersistentErrorScreen.show(
          null,
          details: errorDetails,
          navigatorKey: appNavigatorKey,
        );
      });
    };
    
    // Configurar el manejo de errores de Dart/isolates
    PlatformDispatcher.instance.onError = (error, stack) {
      // Ejecutar en un microtask para evitar bloquear el hilo principal
      Future.microtask(() {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        
        // También registrar en nuestro sistema de logging
        LoggingService.critical(
          'Platform dispatcher error: $error',
          category: LogCategory.general,
          error: error,
          stackTrace: stack,
        );

        // Guardar y mostrar pantalla persistente del error
        final details = FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'platform_dispatcher',
          context: DiagnosticsNode.message('unhandled platform error'),
        );
        PersistentErrorScreen.show(
          null,
          details: details,
          navigatorKey: appNavigatorKey,
        );
      });
      return true;
    };
    
    print('✅ Crashlytics configurado correctamente');
    
  } catch (e) {
    print('⚠️ Error configurando Crashlytics: $e');
    // Continuar sin Crashlytics si hay errores
  }
}

/// Configura el listener de conectividad para manejar Firebase automáticamente
void _setupConnectivityListener() {
  final connectivityService = ConnectivityService();
  final firebaseOptimization = FirebaseOptimizationService();
  
  connectivityService.connectionStream.listen((isConnected) {
    if (isConnected) {
      // Reconectar Firebase cuando se restaure la conexión
      firebaseOptimization.handleNetworkReconnection();
      print('Network reconnected - Firebase re-enabled');
    } else {
      // Desconectar Firebase cuando se pierda la conexión
      firebaseOptimization.handleNetworkDisconnection();
      print('Network disconnected - Firebase disabled');
    }
  });
}

class SalasBeatsApp extends StatefulWidget {
  const SalasBeatsApp({super.key});

  @override
  State<SalasBeatsApp> createState() => _SalasBeatsAppState();
}

class _SalasBeatsAppState extends State<SalasBeatsApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
    LocalizationService().addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocalizationService().removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _loadLocale() async {
    final locale = LocalizationService().currentLocale;
    if (mounted) {
      setState(() {
        _locale = locale;
      });
    }
  }

  void _onLocaleChanged() {
    _loadLocale();
  }

  Future<void> _initializeApp() async {
    try {
      // Asegurar que Firebase esté completamente inicializado
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      
      // Para dispositivos físicos, necesitamos más tiempo para la inicialización
      await Future.delayed(Duration(milliseconds: 500));
      
      // Verificar que los servicios críticos estén disponibles
      await _verifyFirebaseServices();
      
      print('✅ Aplicación inicializada correctamente para dispositivo físico');
      
    } catch (e) {
      print('⚠️ Error en inicialización: $e');
      // Continuar con inicialización básica
      await Future.delayed(Duration(milliseconds: 200));
    }
  }
  
  Future<void> _verifyFirebaseServices() async {
     try {
       // Verificar Auth
       firebase_auth.FirebaseAuth.instance.currentUser;
      
      // Verificar Firestore con timeout
      // Consultar una colección con lectura pública según reglas (app_settings)
      await FirebaseFirestore.instance
          .collection('app_settings')
          .limit(1)
          .get()
          .timeout(Duration(seconds: 3));
          
    } catch (e) {
      print('⚠️ Servicios Firebase no completamente disponibles: $e');
      // No es crítico, continuar
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error initializing app: ${snapshot.error}'),
              ),
            ),
          );
        }
        
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProxyProvider<AuthProvider, BookingProvider>(
              create: (_) => BookingProvider(AuthProvider()),
              update: (_, authProvider, previous) => previous ?? BookingProvider(authProvider),
            ),
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
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Tema oscuro por defecto
        locale: _locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: AppRoutes.createRouter(),
      ),
    );
       }
     );
}