import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, booking, system }
enum MessageStatus { sent, delivered, read }

class MessageModel { // Para control de moderación

  MessageModel({
    required this.id,
    required this.threadId,
    required this.fromUserId, required this.toUserId, required this.text, required this.createdAt, this.bookingId,
    this.listingId,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.readAt,
    this.metadata,
    this.imageUrl,
    this.isModerated = false,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return MessageModel.fromMap(data, doc.id);
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, [String? id]) => MessageModel(
      id: id ?? (map['id'] as String? ?? ''),
      threadId: map['threadId'] as String? ?? '',
      bookingId: map['bookingId'] as String?,
      listingId: map['listingId'] as String?,
      fromUserId: map['fromUserId'] as String? ?? '',
      toUserId: map['toUserId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => MessageStatus.sent,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      readAt: map['readAt'] != null
          ? (map['readAt'] as Timestamp).toDate()
          : null,
      metadata: map['metadata'] != null ? Map<String, dynamic>.from(map['metadata'] as Map) : null,
      imageUrl: map['imageUrl'] as String?,
      isModerated: (map['isModerated'] ?? false) as bool,
    );
  final String id;
  final String threadId;
  final String? bookingId; // Opcional, para mensajes relacionados con reservas
  final String? listingId; // Opcional, para mensajes relacionados con listings
  final String fromUserId;
  final String toUserId;
  final String text;
  final MessageType type;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata; // Para información adicional
  final String? imageUrl; // Para mensajes con imagen
  final bool isModerated;

  Map<String, dynamic> toFirestore() => {
      'threadId': threadId,
      'bookingId': bookingId,
      'listingId': listingId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'text': text,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'metadata': metadata,
      'imageUrl': imageUrl,
      'isModerated': isModerated,
    };

  MessageModel copyWith({
    String? id,
    String? threadId,
    String? bookingId,
    String? listingId,
    String? fromUserId,
    String? toUserId,
    String? text,
    MessageType? type,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? readAt,
    Map<String, dynamic>? metadata,
    String? imageUrl,
    bool? isModerated,
  }) => MessageModel(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      bookingId: bookingId ?? this.bookingId,
      listingId: listingId ?? this.listingId,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      text: text ?? this.text,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      metadata: metadata ?? this.metadata,
      imageUrl: imageUrl ?? this.imageUrl,
      isModerated: isModerated ?? this.isModerated,
    );

  // Getters útiles
  bool get isRead => status == MessageStatus.read;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get isSystemMessage => type == MessageType.system;
  bool get isBookingRelated => bookingId != null;
  
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }
  
  String get formattedDateTime => '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';

  @override
  String toString() => 'MessageModel(id: $id, fromUserId: $fromUserId, type: $type, status: $status)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Modelo para el hilo de conversación
class ChatThreadModel {

  ChatThreadModel({
    required this.id,
    required this.participantIds,
    required this.createdAt, this.bookingId,
    this.listingId,
    this.lastMessage,
    this.updatedAt,
    this.unreadCounts = const {},
    this.isActive = true,
  });

  factory ChatThreadModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return ChatThreadModel(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] as List? ?? []),
      bookingId: data['bookingId'] as String?,
      listingId: data['listingId'] as String?,
      lastMessage: data['lastMessage'] != null
          ? MessageModel.fromMap(data['lastMessage'] as Map<String, dynamic>)
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      unreadCounts: Map<String, int>.from(data['unreadCounts'] as Map<String, dynamic>? ?? {}),
      isActive: (data['isActive'] ?? true) as bool,
    );
  }
  final String id;
  final List<String> participantIds;
  final String? bookingId;
  final String? listingId;
  final MessageModel? lastMessage;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, int> unreadCounts; // userId -> unread count
  final bool isActive;

  // Getters para compatibilidad
  DateTime get lastActivity => updatedAt ?? lastMessage?.createdAt ?? createdAt;
  int get unreadCount => unreadCounts.values.fold(0, (sum, count) => sum + count);

  Map<String, dynamic> toFirestore() => {
      'participantIds': participantIds,
      'bookingId': bookingId,
      'listingId': listingId,
      'lastMessage': lastMessage?.toFirestore(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'unreadCounts': unreadCounts,
      'isActive': isActive,
    };

  // Getters útiles
  int getUnreadCount(String userId) => unreadCounts[userId] ?? 0;
  bool hasUnreadMessages(String userId) => getUnreadCount(userId) > 0;
  String getOtherParticipantId(String currentUserId) => participantIds.firstWhere((id) => id != currentUserId, orElse: () => '');

  ChatThreadModel copyWith({
    String? id,
    List<String>? participantIds,
    String? bookingId,
    String? listingId,
    MessageModel? lastMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, int>? unreadCounts,
    bool? isActive,
  }) => ChatThreadModel(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      bookingId: bookingId ?? this.bookingId,
      listingId: listingId ?? this.listingId,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      isActive: isActive ?? this.isActive,
    );

  @override
  String toString() => 'ChatThreadModel(id: $id, participantIds: $participantIds, isActive: $isActive)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatThreadModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Mock DocumentSnapshot para el último mensaje
class MockDocumentSnapshot {

  MockDocumentSnapshot(this._data, this._id);
  final Map<String, dynamic> _data;
  final String _id;

  Map<String, dynamic>? data() => _data;

  String get id => _id;

  bool get exists => true;

  dynamic operator [](Object field) => _data[field];

  dynamic get(Object field) => _data[field];
}