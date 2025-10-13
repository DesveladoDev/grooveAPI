import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.data,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.imageUrl,
    this.actionUrl,
    this.actionData,
  });

  /// Crea una instancia desde un documento de Firestore
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return NotificationModel.fromMap(data, doc.id);
  }

  /// Crea una instancia desde un Map
  factory NotificationModel.fromMap(Map<String, dynamic> map, [String? id]) => NotificationModel(
      id: id ?? (map['id'] as String?) ?? '',
      userId: map['userId'] as String? ?? '',
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      data: Map<String, dynamic>.from((map['data'] as Map<String, dynamic>?) ?? {}),
      type: map['type'] as String? ?? 'general',
      isRead: (map['isRead'] ?? false) as bool,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (map['readAt'] as Timestamp?)?.toDate(),
      imageUrl: map['imageUrl'] as String?,
      actionUrl: map['actionUrl'] as String?,
      actionData: map['actionData'] != null 
          ? Map<String, dynamic>.from(map['actionData'] as Map<String, dynamic>)
          : null,
    );
  final String id;
  final String userId;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? imageUrl;
  final String? actionUrl;
  final Map<String, dynamic>? actionData;

  /// Convierte la instancia a un Map para Firestore
  Map<String, dynamic> toMap() => {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'data': data,
      'type': type,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'actionData': actionData,
    };

  /// Convierte la instancia a un Map para Firestore (sin el ID)
  Map<String, dynamic> toFirestore() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  /// Crea una copia con algunos campos modificados
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    String? imageUrl,
    String? actionUrl,
    Map<String, dynamic>? actionData,
  }) => NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      actionData: actionData ?? this.actionData,
    );

  /// Marca la notificación como leída
  NotificationModel markAsRead() => copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );

  // Getters de utilidad
  
  /// Obtiene el tiempo transcurrido desde la creación
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }

  /// Obtiene el tiempo transcurrido desde la creación (formato completo)
  String get timeAgoFull {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace un momento';
    }
  }

  /// Verifica si la notificación es reciente (menos de 24 horas)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  /// Verifica si la notificación es de hoy
  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
           createdAt.month == now.month &&
           createdAt.day == now.day;
  }

  /// Obtiene el icono según el tipo de notificación
  String get typeIcon {
    switch (type) {
      case 'booking':
        return '📅';
      case 'payment':
        return '💳';
      case 'chat':
        return '💬';
      case 'review':
        return '⭐';
      case 'host':
        return '🏠';
      case 'system':
        return '⚙️';
      case 'promotion':
        return '🎉';
      default:
        return '🔔';
    }
  }

  /// Obtiene el color según el tipo de notificación
  String get typeColor {
    switch (type) {
      case 'booking':
        return '#4CAF50'; // Verde
      case 'payment':
        return '#2196F3'; // Azul
      case 'chat':
        return '#FF9800'; // Naranja
      case 'review':
        return '#FFC107'; // Amarillo
      case 'host':
        return '#9C27B0'; // Púrpura
      case 'system':
        return '#607D8B'; // Gris azulado
      case 'promotion':
        return '#E91E63'; // Rosa
      default:
        return '#757575'; // Gris
    }
  }

  /// Obtiene la prioridad según el tipo
  NotificationPriority get priority {
    switch (type) {
      case 'booking':
      case 'payment':
        return NotificationPriority.high;
      case 'chat':
      case 'review':
        return NotificationPriority.medium;
      case 'promotion':
      case 'system':
        return NotificationPriority.low;
      default:
        return NotificationPriority.medium;
    }
  }

  /// Verifica si tiene una acción asociada
  bool get hasAction => actionUrl != null || actionData != null;

  /// Obtiene el ID del elemento relacionado según el tipo
  String? get relatedId {
    switch (type) {
      case 'booking':
        return (data['bookingId'] ?? actionData?['bookingId']) as String?;
      case 'chat':
        return (data['chatRoomId'] ?? actionData?['chatRoomId']) as String?;
      case 'review':
        return (data['reviewId'] ?? actionData?['reviewId']) as String?;
      case 'host':
        return (data['listingId'] ?? actionData?['listingId']) as String?;
      default:
        return null;
    }
  }

  @override
  String toString() => 'NotificationModel(id: $id, title: $title, type: $type, isRead: $isRead, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum para las prioridades de notificación
enum NotificationPriority {
  low,
  medium,
  high,
}

/// Enum para los tipos de notificación
enum NotificationType {
  general,
  booking,
  payment,
  chat,
  review,
  host,
  system,
  promotion,
}

/// Extensión para convertir el enum a string
extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.general:
        return 'general';
      case NotificationType.booking:
        return 'booking';
      case NotificationType.payment:
        return 'payment';
      case NotificationType.chat:
        return 'chat';
      case NotificationType.review:
        return 'review';
      case NotificationType.host:
        return 'host';
      case NotificationType.system:
        return 'system';
      case NotificationType.promotion:
        return 'promotion';
    }
  }

  String get displayName {
    switch (this) {
      case NotificationType.general:
        return 'General';
      case NotificationType.booking:
        return 'Reservas';
      case NotificationType.payment:
        return 'Pagos';
      case NotificationType.chat:
        return 'Mensajes';
      case NotificationType.review:
        return 'Reseñas';
      case NotificationType.host:
        return 'Anfitrión';
      case NotificationType.system:
        return 'Sistema';
      case NotificationType.promotion:
        return 'Promociones';
    }
  }
}

/// Clase para configuración de notificaciones
class NotificationSettings {

  const NotificationSettings({
    this.enablePushNotifications = true,
    this.enableBookingNotifications = true,
    this.enableChatNotifications = true,
    this.enableReviewNotifications = true,
    this.enablePromotionNotifications = true,
    this.enableSystemNotifications = true,
    this.enableSound = true,
    this.enableVibration = true,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '08:00',
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) => NotificationSettings(
      enablePushNotifications: (map['enablePushNotifications'] ?? true) as bool,
      enableBookingNotifications: (map['enableBookingNotifications'] ?? true) as bool,
      enableChatNotifications: (map['enableChatNotifications'] ?? true) as bool,
      enableReviewNotifications: (map['enableReviewNotifications'] ?? true) as bool,
      enablePromotionNotifications: (map['enablePromotionNotifications'] ?? true) as bool,
      enableSystemNotifications: (map['enableSystemNotifications'] ?? true) as bool,
      enableSound: (map['enableSound'] ?? true) as bool,
      enableVibration: (map['enableVibration'] ?? true) as bool,
      quietHoursStart: map['quietHoursStart'] as String? ?? '22:00',
      quietHoursEnd: map['quietHoursEnd'] as String? ?? '08:00',
    );
  final bool enablePushNotifications;
  final bool enableBookingNotifications;
  final bool enableChatNotifications;
  final bool enableReviewNotifications;
  final bool enablePromotionNotifications;
  final bool enableSystemNotifications;
  final bool enableSound;
  final bool enableVibration;
  final String quietHoursStart;
  final String quietHoursEnd;

  Map<String, dynamic> toMap() => {
      'enablePushNotifications': enablePushNotifications,
      'enableBookingNotifications': enableBookingNotifications,
      'enableChatNotifications': enableChatNotifications,
      'enableReviewNotifications': enableReviewNotifications,
      'enablePromotionNotifications': enablePromotionNotifications,
      'enableSystemNotifications': enableSystemNotifications,
      'enableSound': enableSound,
      'enableVibration': enableVibration,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
    };

  NotificationSettings copyWith({
    bool? enablePushNotifications,
    bool? enableBookingNotifications,
    bool? enableChatNotifications,
    bool? enableReviewNotifications,
    bool? enablePromotionNotifications,
    bool? enableSystemNotifications,
    bool? enableSound,
    bool? enableVibration,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) => NotificationSettings(
      enablePushNotifications: enablePushNotifications ?? this.enablePushNotifications,
      enableBookingNotifications: enableBookingNotifications ?? this.enableBookingNotifications,
      enableChatNotifications: enableChatNotifications ?? this.enableChatNotifications,
      enableReviewNotifications: enableReviewNotifications ?? this.enableReviewNotifications,
      enablePromotionNotifications: enablePromotionNotifications ?? this.enablePromotionNotifications,
      enableSystemNotifications: enableSystemNotifications ?? this.enableSystemNotifications,
      enableSound: enableSound ?? this.enableSound,
      enableVibration: enableVibration ?? this.enableVibration,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
}