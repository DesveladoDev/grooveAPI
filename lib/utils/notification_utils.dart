import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:salas_beats/utils/exceptions.dart';
import 'package:salas_beats/firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

enum NotificationType {
  booking,
  payment,
  message,
  reminder,
  promotion,
  system,
  host,
  guest,
}

enum NotificationPriority {
  min,
  low,
  defaultPriority,
  high,
  max,
}

enum NotificationImportance {
  unspecified,
  none,
  min,
  low,
  defaultImportance,
  high,
  max,
}

class NotificationData {
  
  const NotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.imageUrl,
    this.sound,
    this.priority = NotificationPriority.defaultPriority,
    this.importance = NotificationImportance.defaultImportance,
    this.scheduledTime,
    this.silent = false,
    this.channelId,
    this.channelName,
    this.channelDescription,
    this.tag,
    this.group,
    this.autoCancel = true,
    this.ongoing = false,
    this.color,
    this.largeIcon,
    this.bigPicture,
    this.actions,
  });
  
  factory NotificationData.fromRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;
    
    return NotificationData(
      id: (data['id'] as String?) ?? message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification?.title ?? (data['title'] as String?) ?? '',
      body: notification?.body ?? (data['body'] as String?) ?? '',
      type: _parseNotificationType(data['type'] as String?),
      data: data,
      imageUrl: notification?.android?.imageUrl ?? notification?.apple?.imageUrl,
      sound: notification?.android?.sound ?? notification?.apple?.sound?.name,
    );
  }
  
  factory NotificationData.fromJson(Map<String, dynamic> json) => NotificationData(
      id: (json['id'] as String?) ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: NotificationUtils._parseNotificationType(json['type'] as String?),
      data: json['data'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      sound: json['sound'] as String?,
      priority: NotificationUtils._parseNotificationPriority(json['priority'] as String?),
      importance: NotificationUtils._parseNotificationImportance(json['importance'] as String?),
      scheduledTime: json['scheduledTime'] != null 
          ? DateTime.parse(json['scheduledTime'] as String) 
          : null,
      silent: (json['silent'] as bool?) ?? false,
      channelId: json['channelId'] as String?,
      channelName: json['channelName'] as String?,
      channelDescription: json['channelDescription'] as String?,
      tag: json['tag'] as String?,
      group: json['group'] as String?,
      autoCancel: (json['autoCancel'] as bool?) ?? true,
      ongoing: (json['ongoing'] as bool?) ?? false,
      color: json['color'] != null ? Color(json['color'] as int) : null,
      largeIcon: json['largeIcon'] as String?,
      bigPicture: json['bigPicture'] as String?,
    );
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? sound;
  final NotificationPriority priority;
  final NotificationImportance importance;
  final DateTime? scheduledTime;
  final bool silent;
  final String? channelId;
  final String? channelName;
  final String? channelDescription;
  final String? tag;
  final String? group;
  final bool autoCancel;
  final bool ongoing;
  final Color? color;
  final String? largeIcon;
  final String? bigPicture;
  final List<NotificationAction>? actions;
  
  Map<String, dynamic> toJson() => {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'data': data,
      'imageUrl': imageUrl,
      'sound': sound,
      'priority': priority.name,
      'importance': importance.name,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'silent': silent,
      'channelId': channelId,
      'channelName': channelName,
      'channelDescription': channelDescription,
      'tag': tag,
      'group': group,
      'autoCancel': autoCancel,
      'ongoing': ongoing,
      'color': color?.value,
      'largeIcon': largeIcon,
      'bigPicture': bigPicture,
    };
  
  static NotificationType _parseNotificationType(String? type) {
    switch (type?.toLowerCase()) {
      case 'booking':
        return NotificationType.booking;
      case 'payment':
        return NotificationType.payment;
      case 'message':
        return NotificationType.message;
      case 'reminder':
        return NotificationType.reminder;
      case 'promotion':
        return NotificationType.promotion;
      case 'system':
        return NotificationType.system;
      case 'host':
        return NotificationType.host;
      case 'guest':
        return NotificationType.guest;
      default:
        return NotificationType.system;
    }
  }
  
  static NotificationPriority _parseNotificationPriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'min':
        return NotificationPriority.min;
      case 'low':
        return NotificationPriority.low;
      case 'default':
        return NotificationPriority.defaultPriority;
      case 'high':
        return NotificationPriority.high;
      case 'max':
        return NotificationPriority.max;
      default:
        return NotificationPriority.defaultPriority;
    }
  }
  
  static NotificationImportance _parseNotificationImportance(String? importance) {
    switch (importance?.toLowerCase()) {
      case 'unspecified':
        return NotificationImportance.unspecified;
      case 'none':
        return NotificationImportance.none;
      case 'min':
        return NotificationImportance.min;
      case 'low':
        return NotificationImportance.low;
      case 'default':
        return NotificationImportance.defaultImportance;
      case 'high':
        return NotificationImportance.high;
      case 'max':
        return NotificationImportance.max;
      default:
        return NotificationImportance.defaultImportance;
    }
  }
  
  NotificationData copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? sound,
    NotificationPriority? priority,
    NotificationImportance? importance,
    DateTime? scheduledTime,
    bool? silent,
    String? channelId,
    String? channelName,
    String? channelDescription,
    String? tag,
    String? group,
    bool? autoCancel,
    bool? ongoing,
    Color? color,
    String? largeIcon,
    String? bigPicture,
    List<NotificationAction>? actions,
  }) => NotificationData(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      sound: sound ?? this.sound,
      priority: priority ?? this.priority,
      importance: importance ?? this.importance,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      silent: silent ?? this.silent,
      channelId: channelId ?? this.channelId,
      channelName: channelName ?? this.channelName,
      channelDescription: channelDescription ?? this.channelDescription,
      tag: tag ?? this.tag,
      group: group ?? this.group,
      autoCancel: autoCancel ?? this.autoCancel,
      ongoing: ongoing ?? this.ongoing,
      color: color ?? this.color,
      largeIcon: largeIcon ?? this.largeIcon,
      bigPicture: bigPicture ?? this.bigPicture,
      actions: actions ?? this.actions,
    );
}

class NotificationAction {
  
  const NotificationAction({
    required this.id,
    required this.title,
    this.icon,
    this.requiresAuthentication = false,
    this.showsUserInterface = false,
    this.data,
  });
  final String id;
  final String title;
  final String? icon;
  final bool requiresAuthentication;
  final bool showsUserInterface;
  final Map<String, dynamic>? data;
}

class NotificationChannel {
  
  const NotificationChannel({
    required this.id,
    required this.name,
    required this.description,
    this.importance = NotificationImportance.defaultImportance,
    this.enableVibration = true,
    this.enableLights = true,
    this.lightColor,
    this.sound,
    this.groupId,
    this.showBadge = true,
  });
  final String id;
  final String name;
  final String description;
  final NotificationImportance importance;
  final bool enableVibration;
  final bool enableLights;
  final Color? lightColor;
  final String? sound;
  final String? groupId;
  final bool showBadge;
}

class NotificationManager {
  
  NotificationManager._();
  static NotificationManager? _instance;
  static NotificationManager get instance => _instance ??= NotificationManager._();
  
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  final StreamController<NotificationData> _notificationController = 
      StreamController<NotificationData>.broadcast();
  final StreamController<NotificationData> _notificationTapController = 
      StreamController<NotificationData>.broadcast();
  
  bool _isInitialized = false;
  String? _fcmToken;
  
  // Getters
  Stream<NotificationData> get notificationStream => _notificationController.stream;
  Stream<NotificationData> get notificationTapStream => _notificationTapController.stream;
  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;
  
  // Default notification channels
  static const List<NotificationChannel> defaultChannels = [
    NotificationChannel(
      id: 'booking_channel',
      name: 'Booking Notifications',
      description: 'Notifications about booking updates',
      importance: NotificationImportance.high,
    ),
    NotificationChannel(
      id: 'payment_channel',
      name: 'Payment Notifications',
      description: 'Notifications about payments and transactions',
      importance: NotificationImportance.high,
    ),
    NotificationChannel(
      id: 'message_channel',
      name: 'Message Notifications',
      description: 'Notifications about new messages',
      importance: NotificationImportance.high,
    ),
    NotificationChannel(
      id: 'reminder_channel',
      name: 'Reminder Notifications',
      description: 'Reminder notifications',
    ),
    NotificationChannel(
      id: 'promotion_channel',
      name: 'Promotion Notifications',
      description: 'Promotional notifications and offers',
      importance: NotificationImportance.low,
    ),
    NotificationChannel(
      id: 'system_channel',
      name: 'System Notifications',
      description: 'System and app notifications',
    ),
  ];
  
  // Initialize notification manager
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;
      
      // Initialize timezone data
      tz.initializeTimeZones();
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Initialize Firebase messaging
      await _initializeFirebaseMessaging();
      
      // Create default notification channels
      await _createNotificationChannels();
      
      _isInitialized = true;
      debugPrint('NotificationManager initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize NotificationManager: $e');
      throw GenericException('Failed to initialize notifications: $e');
    }
  }
  
  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }
  
  // Initialize Firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request permission
    final settings = await _firebaseMessaging.requestPermission(
      
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
    
    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $_fcmToken');
    
    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      debugPrint('FCM Token refreshed: $token');
    });
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    
    // Handle notification taps when app is terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    
    // Check for initial message when app is opened from terminated state
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }
  
  // Create notification channels
  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      for (final channel in defaultChannels) {
        await _createAndroidNotificationChannel(channel);
      }
    }
  }
  
  // Create Android notification channel
  Future<void> _createAndroidNotificationChannel(NotificationChannel channel) async {
    final androidChannel = AndroidNotificationChannel(
      channel.id,
      channel.name,
      description: channel.description,
      importance: _mapImportanceToAndroid(channel.importance),
      enableVibration: channel.enableVibration,
      enableLights: channel.enableLights,
      ledColor: channel.lightColor,
      showBadge: channel.showBadge,
      sound: channel.sound != null 
          ? RawResourceAndroidNotificationSound(channel.sound) 
          : null,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }
  
  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    
    final notificationData = NotificationData.fromRemoteMessage(message);
    _notificationController.add(notificationData);
    
    // Show local notification for foreground messages
    if (!notificationData.silent) {
      showLocalNotification(notificationData);
    }
  }
  
  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    
    final notificationData = NotificationData.fromRemoteMessage(message);
    _notificationTapController.add(notificationData);
  }
  
  // Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.id}');
    
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        final notificationData = NotificationData.fromJson(data);
        _notificationTapController.add(notificationData);
      } catch (e) {
        debugPrint('Failed to parse notification payload: $e');
      }
    }
  }
  
  // Show local notification
  Future<void> showLocalNotification(NotificationData notification) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        notification.channelId ?? _getDefaultChannelId(notification.type),
        notification.channelName ?? _getDefaultChannelName(notification.type),
        channelDescription: notification.channelDescription ?? 
                          _getDefaultChannelDescription(notification.type),
        importance: _mapImportanceToAndroid(notification.importance),
        priority: _mapPriorityToAndroid(notification.priority),
        icon: notification.largeIcon,
        largeIcon: notification.largeIcon != null 
            ? DrawableResourceAndroidBitmap(notification.largeIcon!) 
            : null,
        styleInformation: notification.bigPicture != null
            ? BigPictureStyleInformation(
                DrawableResourceAndroidBitmap(notification.bigPicture!),
                largeIcon: notification.largeIcon != null 
                    ? DrawableResourceAndroidBitmap(notification.largeIcon!) 
                    : null,
              )
            : notification.body.length > 50
                ? BigTextStyleInformation(notification.body)
                : null,
        color: notification.color,
        autoCancel: notification.autoCancel,
        ongoing: notification.ongoing,
        silent: notification.silent,
        tag: notification.tag,
        groupKey: notification.group,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      if (notification.scheduledTime != null) {
        await _localNotifications.zonedSchedule(
          int.parse(notification.id),
          notification.title,
          notification.body,
          tz.TZDateTime.from(notification.scheduledTime!, tz.local),
          notificationDetails,
          payload: jsonEncode(notification.toJson()),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } else {
        await _localNotifications.show(
          int.parse(notification.id),
          notification.title,
          notification.body,
          notificationDetails,
          payload: jsonEncode(notification.toJson()),
        );
      }
    } catch (e) {
      debugPrint('Failed to show local notification: $e');
      throw GenericException('Failed to show notification: $e');
    }
  }
  
  // Schedule notification
  Future<void> scheduleNotification(
    NotificationData notification,
    DateTime scheduledTime,
  ) async {
    final scheduledNotification = notification.copyWith(
      scheduledTime: scheduledTime,
    );
    
    await showLocalNotification(scheduledNotification);
  }
  
  // Cancel notification
  Future<void> cancelNotification(String notificationId) async {
    try {
      await _localNotifications.cancel(int.parse(notificationId));
    } catch (e) {
      debugPrint('Failed to cancel notification: $e');
    }
  }
  
  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
    } catch (e) {
      debugPrint('Failed to cancel all notifications: $e');
    }
  }
  
  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async => _localNotifications.pendingNotificationRequests();
  
  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Failed to subscribe to topic: $e');
      throw GenericException('Failed to subscribe to topic: $e');
    }
  }
  
  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Failed to unsubscribe from topic: $e');
      throw GenericException('Failed to unsubscribe from topic: $e');
    }
  }
  
  // Check notification permission
  Future<bool> hasNotificationPermission() async {
    if (Platform.isAndroid) {
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    } else if (Platform.isIOS) {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }
    return false;
  }
  
  // Request notification permission
  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.requestNotificationsPermission() ?? false;
    } else if (Platform.isIOS) {
      final settings = await _firebaseMessaging.requestPermission();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }
    return false;
  }
  
  // Get default channel ID for notification type
  String _getDefaultChannelId(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return 'booking_channel';
      case NotificationType.payment:
        return 'payment_channel';
      case NotificationType.message:
        return 'message_channel';
      case NotificationType.reminder:
        return 'reminder_channel';
      case NotificationType.promotion:
        return 'promotion_channel';
      case NotificationType.system:
      case NotificationType.host:
      case NotificationType.guest:
        return 'system_channel';
    }
  }
  
  // Get default channel name for notification type
  String _getDefaultChannelName(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return 'Booking Notifications';
      case NotificationType.payment:
        return 'Payment Notifications';
      case NotificationType.message:
        return 'Message Notifications';
      case NotificationType.reminder:
        return 'Reminder Notifications';
      case NotificationType.promotion:
        return 'Promotion Notifications';
      case NotificationType.system:
      case NotificationType.host:
      case NotificationType.guest:
        return 'System Notifications';
    }
  }
  
  // Get default channel description for notification type
  String _getDefaultChannelDescription(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return 'Notifications about booking updates';
      case NotificationType.payment:
        return 'Notifications about payments and transactions';
      case NotificationType.message:
        return 'Notifications about new messages';
      case NotificationType.reminder:
        return 'Reminder notifications';
      case NotificationType.promotion:
        return 'Promotional notifications and offers';
      case NotificationType.system:
      case NotificationType.host:
      case NotificationType.guest:
        return 'System and app notifications';
    }
  }
  
  // Map importance to Android importance
  Importance _mapImportanceToAndroid(NotificationImportance importance) {
    switch (importance) {
      case NotificationImportance.unspecified:
        return Importance.unspecified;
      case NotificationImportance.none:
        return Importance.none;
      case NotificationImportance.min:
        return Importance.min;
      case NotificationImportance.low:
        return Importance.low;
      case NotificationImportance.defaultImportance:
        return Importance.defaultImportance;
      case NotificationImportance.high:
        return Importance.high;
      case NotificationImportance.max:
        return Importance.max;
    }
  }
  
  // Map priority to Android priority
  Priority _mapPriorityToAndroid(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.min:
        return Priority.min;
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.defaultPriority:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.max:
        return Priority.max;
    }
  }
  
  // Dispose resources
  void dispose() {
    _notificationController.close();
    _notificationTapController.close();
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  // Asegurar que Firebase esté inicializado en el isolate de background
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {
    // Si ya está inicializado o las opciones no están disponibles, continuar
  }

  debugPrint('Handling background message: ${message.messageId}');
  // Aquí se puede manejar la lógica del mensaje en background
}

// Notification utilities
class NotificationUtils {
  // Create booking notification
  static NotificationData createBookingNotification({
    required String bookingId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) => NotificationData(
      id: 'booking_$bookingId',
      title: title,
      body: body,
      type: NotificationType.booking,
      data: {
        'bookingId': bookingId,
        'type': 'booking',
        ...?data,
      },
      priority: NotificationPriority.high,
      importance: NotificationImportance.high,
    );
  
  // Create payment notification
  static NotificationData createPaymentNotification({
    required String paymentId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) => NotificationData(
      id: 'payment_$paymentId',
      title: title,
      body: body,
      type: NotificationType.payment,
      data: {
        'paymentId': paymentId,
        'type': 'payment',
        ...?data,
      },
      priority: NotificationPriority.high,
      importance: NotificationImportance.high,
    );
  
  // Create message notification
  static NotificationData createMessageNotification({
    required String chatId,
    required String senderId,
    required String senderName,
    required String message,
    Map<String, dynamic>? data,
  }) => NotificationData(
      id: 'message_${chatId}_${DateTime.now().millisecondsSinceEpoch}',
      title: senderName,
      body: message,
      type: NotificationType.message,
      data: {
        'chatId': chatId,
        'senderId': senderId,
        'type': 'message',
        ...?data,
      },
      priority: NotificationPriority.high,
      importance: NotificationImportance.high,
    );
  
  // Create reminder notification
  static NotificationData createReminderNotification({
    required String reminderId,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, dynamic>? data,
  }) => NotificationData(
      id: 'reminder_$reminderId',
      title: title,
      body: body,
      type: NotificationType.reminder,
      scheduledTime: scheduledTime,
      data: {
        'reminderId': reminderId,
        'type': 'reminder',
        ...?data,
      },
    );
  
  // Create promotion notification
  static NotificationData createPromotionNotification({
    required String promotionId,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) => NotificationData(
      id: 'promotion_$promotionId',
      title: title,
      body: body,
      type: NotificationType.promotion,
      imageUrl: imageUrl,
      data: {
        'promotionId': promotionId,
        'type': 'promotion',
        ...?data,
      },
      priority: NotificationPriority.low,
      importance: NotificationImportance.low,
    );
  
  // Generate unique notification ID
  static String generateNotificationId([String? prefix]) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return prefix != null ? '${prefix}_$timestamp' : timestamp.toString();
  }
  
  // Format notification time
  static String formatNotificationTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
  
  // Parse notification type from string
  static NotificationType _parseNotificationType(String? type) {
    if (type == null) return NotificationType.system;
    
    switch (type.toLowerCase()) {
      case 'booking':
        return NotificationType.booking;
      case 'payment':
        return NotificationType.payment;
      case 'message':
        return NotificationType.message;
      case 'reminder':
        return NotificationType.reminder;
      case 'promotion':
        return NotificationType.promotion;
      case 'host':
        return NotificationType.host;
      case 'guest':
        return NotificationType.guest;
      case 'system':
      default:
        return NotificationType.system;
    }
  }
  
  // Parse notification priority from string
  static NotificationPriority _parseNotificationPriority(String? priority) {
    if (priority == null) return NotificationPriority.defaultPriority;
    
    switch (priority.toLowerCase()) {
      case 'min':
        return NotificationPriority.min;
      case 'low':
        return NotificationPriority.low;
      case 'high':
        return NotificationPriority.high;
      case 'max':
        return NotificationPriority.max;
      case 'default':
      default:
        return NotificationPriority.defaultPriority;
    }
  }
  
  // Parse notification importance from string
  static NotificationImportance _parseNotificationImportance(String? importance) {
    if (importance == null) return NotificationImportance.defaultImportance;
    
    switch (importance.toLowerCase()) {
      case 'unspecified':
        return NotificationImportance.unspecified;
      case 'none':
        return NotificationImportance.none;
      case 'min':
        return NotificationImportance.min;
      case 'low':
        return NotificationImportance.low;
      case 'high':
        return NotificationImportance.high;
      case 'max':
        return NotificationImportance.max;
      case 'default':
      default:
        return NotificationImportance.defaultImportance;
    }
  }
}