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
import 'package:salas_beats/utils/app_theme.dart';

// Variable global para controlar si Firebase está disponible
bool _firebaseInitialized = false;

// Handler para notificaciones en background (solo si Firebase está disponible)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (_firebaseInitialized) {
    print('Handling a background message: ${message.messageId}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Iniciando Salas & Beats...');
  
  // Intentar inicializar Firebase de forma segura
  await _safeInitializeFirebase();
  
  // Solo configurar servicios de Firebase si está disponible
  if (_firebaseInitialized) {
    await _setupFirebaseServices();
  } else {
    print('⚠️ Ejecutando sin Firebase - funcionalidad limitada');
  }
  
  runApp(const SalasBeatsApp());
}

/// Inicializa Firebase de forma segura con múltiples intentos
Future<void> _safeInitializeFirebase() async {
  try {
    print('🔥 Intentando inicializar Firebase...');
    
    // Verificar si Firebase ya está inicializado
    if (Firebase.apps.isNotEmpty) {
      print('✅ Firebase ya está inicializado');
      _firebaseInitialized = true;
      return;
    }
    
    // Intentar inicializar Firebase con timeout
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Timeout inicializando Firebase');
      },
    );
    
    _firebaseInitialized = true;
    print('✅ Firebase inicializado correctamente');
    
  } catch (e) {
    print('❌ Error inicializando Firebase: $e');
    print('📱 La aplicación continuará sin Firebase');
    _firebaseInitialized = false;
    
    // No lanzar la excepción, permitir que la app continúe
  }
}

/// Configura los servicios de Firebase solo si está disponible
Future<void> _setupFirebaseServices() async {
  try {
    print('🔧 Configurando servicios de Firebase...');
    
    // Configurar Crashlytics
    FlutterError.onError = (errorDetails) {
      try {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      } catch (e) {
        print('Error enviando crash a Crashlytics: $e');
      }
    };
    
    // Configurar notificaciones background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Inicializar servicio de notificaciones
    try {
      await NotificationService().initialize();
      print('✅ Servicio de notificaciones inicializado');
    } catch (e) {
      print('⚠️ Error inicializando notificaciones: $e');
    }
    
    print('✅ Servicios de Firebase configurados');
    
  } catch (e) {
    print('❌ Error configurando servicios de Firebase: $e');
    // Continuar sin los servicios de Firebase
  }
}

class SalasBeatsApp extends StatelessWidget {
  const SalasBeatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, BookingProvider>(
          create: (_) => BookingProvider(AuthProvider()),
          update: (_, authProvider, previous) => 
              previous ?? BookingProvider(authProvider),
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
        themeMode: ThemeMode.dark,
        locale: const Locale('es', 'MX'),
        supportedLocales: const [
          Locale('es', 'MX'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: AppRoutes.createRouter(),
        builder: (context, child) {
          // Mostrar banner si Firebase no está disponible
          if (!_firebaseInitialized) {
            return Banner(
              message: 'SIN FIREBASE',
              location: BannerLocation.topStart,
              color: Colors.orange,
              child: child ?? const SizedBox(),
            );
          }
          return child ?? const SizedBox();
        },
      ),
    );
  }
}