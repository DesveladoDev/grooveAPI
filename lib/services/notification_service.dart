import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:salas_beats/models/notification_model.dart';
import 'package:salas_beats/utils/logger.dart';

class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _fcmToken;
  bool _isInitialized = false;

  // Getters
  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      // Solicitar permisos
      await _requestPermissions();

      // Configurar notificaciones locales
      await _initializeLocalNotifications();

      // Configurar Firebase Messaging
      await _initializeFirebaseMessaging();

      // Obtener y guardar FCM token
      await _getFCMToken();

      // Configurar listeners
      _setupMessageListeners();

      _isInitialized = true;
      Logger.instance.info('NotificationService inicializado correctamente');
    } catch (e) {
      Logger.instance.error('Error al inicializar NotificationService: $e');
      rethrow;
    }
  }

  /// Solicita permisos de notificación
  Future<void> _requestPermissions() async {
    // Permisos de Firebase Messaging
    final settings = await _firebaseMessaging.requestPermission(
      
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Logger.instance.info('Permisos de notificación concedidos');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      Logger.instance.info('Permisos de notificación provisionales concedidos');
    } else {
      Logger.instance.warning('Permisos de notificación denegados');
    }

    // Permisos específicos de iOS
    if (Platform.isIOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Inicializa las notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Inicializa Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // El handler para mensajes en background se configura en main.dart
  }

  /// Obtiene y guarda el FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        Logger.instance.info('FCM Token obtenido: ${_fcmToken!.substring(0, 20)}...');
        await _saveFCMTokenToFirestore();
      }
    } catch (e) {
      Logger.instance.error('Error al obtener FCM token: $e');
    }
  }

  /// Guarda el FCM token en Firestore
  Future<void> _saveFCMTokenToFirestore() async {
    try {
      final user = _auth.currentUser;
      if (user != null && _fcmToken != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmTokens': FieldValue.arrayUnion([_fcmToken]),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        Logger.instance.info('FCM token guardado en Firestore');
      }
    } catch (e) {
      Logger.instance.error('Error al guardar FCM token: $e');
    }
  }

  /// Configura los listeners de mensajes
  void _setupMessageListeners() {
    // Mensajes cuando la app está en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Mensajes cuando la app se abre desde una notificación
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Verificar si la app se abrió desde una notificación
    _checkInitialMessage();

    // Listener para cambios de token
    _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);
  }

  /// Maneja mensajes cuando la app está en foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    Logger.instance.info('Mensaje recibido en foreground: ${message.messageId}');
    
    // Mostrar notificación local
    await _showLocalNotification(message);
    
    // Guardar notificación en Firestore
    await _saveNotificationToFirestore(message);
  }

  /// Maneja cuando la app se abre desde una notificación
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    Logger.instance.info('App abierta desde notificación: ${message.messageId}');
    await _handleNotificationAction(message);
  }

  /// Verifica si la app se abrió desde una notificación inicial
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      Logger.instance.info('App abierta desde notificación inicial: ${initialMessage.messageId}');
      await _handleNotificationAction(initialMessage);
    }
  }

  /// Maneja la renovación del token
  Future<void> _onTokenRefresh(String token) async {
    Logger.instance.info('FCM token renovado');
    _fcmToken = token;
    await _saveFCMTokenToFirestore();
  }

  /// Muestra una notificación local
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final android = message.notification?.android;
      final apple = message.notification?.apple;

      if (notification != null) {
        const androidDetails = AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
        );

        const iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        const details = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

        await _localNotifications.show(
          message.hashCode,
          notification.title,
          notification.body,
          details,
          payload: jsonEncode(message.data),
        );
      }
    } catch (e) {
      Logger.instance.error('Error al mostrar notificación local: $e');
    }
  }

  /// Guarda la notificación en Firestore
  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final notificationModel = NotificationModel(
          id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user.uid,
          title: message.notification?.title ?? '',
          body: message.notification?.body ?? '',
          data: message.data,
          type: (message.data['type'] as String?) ?? 'general',
          isRead: false,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('notifications')
            .doc(notificationModel.id)
            .set(notificationModel.toMap());

        Logger.instance.info('Notificación guardada en Firestore: ${notificationModel.id}');
      }
    } catch (e) {
      Logger.instance.error('Error al guardar notificación: $e');
    }
  }

  /// Maneja las acciones de notificación
  Future<void> _handleNotificationAction(RemoteMessage message) async {
    try {
      final data = message.data;
      final type = data['type'];

      switch (type) {
        case 'booking':
          // Navegar a detalles de reserva
          final bookingId = data['bookingId'];
          if (bookingId != null) {
            // NavigationService.navigateTo('/booking-detail', arguments: {'bookingId': bookingId});
          }
          break;
        case 'chat':
          // Navegar a chat
          final chatRoomId = data['chatRoomId'];
          if (chatRoomId != null) {
            // NavigationService.navigateTo('/chat-room', arguments: {'chatRoomId': chatRoomId});
          }
          break;
        case 'review':
          // Navegar a reseñas
          final reviewId = data['reviewId'];
          if (reviewId != null) {
            // NavigationService.navigateTo('/review-detail', arguments: {'reviewId': reviewId});
          }
          break;
        default:
          Logger.instance.info('Tipo de notificación no manejado: $type');
      }
    } catch (e) {
      Logger.instance.error('Error al manejar acción de notificación: $e');
    }
  }

  /// Maneja cuando se toca una notificación local
  void _onNotificationTapped(NotificationResponse response) {
    try {
      if (response.payload != null) {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        final message = RemoteMessage(
          messageId: data['messageId'] as String?,
          data: Map<String, String>.from(data),
        );
        _handleNotificationAction(message);
      }
    } catch (e) {
      Logger.instance.error('Error al manejar tap de notificación: $e');
    }
  }

  /// Envía una notificación a un usuario específico
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      // Obtener tokens FCM del usuario
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      
      if (userData != null && userData['fcmTokens'] != null) {
        final tokens = List<String>.from(userData['fcmTokens'] as List<dynamic>);
        
        for (final token in tokens) {
          await _sendNotificationToToken(
            token: token,
            title: title,
            body: body,
            data: data,
          );
        }
      }
    } catch (e) {
      Logger.instance.error('Error al enviar notificación a usuario: $e');
    }
  }

  /// Envía una notificación a un token específico
  Future<void> _sendNotificationToToken({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      // Nota: En producción, esto se haría desde Cloud Functions
      // por seguridad y para evitar exponer las credenciales del servidor
      Logger.instance.info('Enviando notificación a token: ${token.substring(0, 20)}...');
      
      // Aquí iría la lógica para enviar via HTTP a FCM
      // o mejor aún, llamar a una Cloud Function
    } catch (e) {
      Logger.instance.error('Error al enviar notificación a token: $e');
    }
  }

  /// Marca una notificación como leída
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      
      Logger.instance.info('Notificación marcada como leída: $notificationId');
    } catch (e) {
      Logger.instance.error('Error al marcar notificación como leída: $e');
    }
  }

  /// Obtiene las notificaciones del usuario actual
  Stream<List<NotificationModel>> getUserNotifications() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data()))
            .toList(),);
  }

  /// Elimina una notificación
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
      
      Logger.instance.info('Notificación eliminada: $notificationId');
    } catch (e) {
      Logger.instance.error('Error al eliminar notificación: $e');
    }
  }

  /// Limpia todas las notificaciones del usuario
  Future<void> clearAllNotifications() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final batch = _firestore.batch();
        final notifications = await _firestore
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .get();

        for (final doc in notifications.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
        Logger.instance.info('Todas las notificaciones eliminadas');
      }
    } catch (e) {
      Logger.instance.error('Error al limpiar notificaciones: $e');
    }
  }

  /// Actualiza el badge de la app
  Future<void> updateBadgeCount(int count) async {
    try {
      if (Platform.isIOS) {
        // En iOS, el badge se actualiza automáticamente con las notificaciones locales
        // o se puede usar un plugin específico como flutter_app_badger
        // Por ahora, dejamos este método como placeholder
      }
    } catch (e) {
      Logger.instance.error('Error al actualizar badge: $e');
    }
  }

  /// Limpia el token FCM al cerrar sesión
  Future<void> clearFCMToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null && _fcmToken != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmTokens': FieldValue.arrayRemove([_fcmToken]),
        });
      }
      
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      
      Logger.instance.info('FCM token limpiado');
    } catch (e) {
      Logger.instance.error('Error al limpiar FCM token: $e');
    }
  }

  /// Dispose del servicio
  void dispose() {
    _isInitialized = false;
  }
}