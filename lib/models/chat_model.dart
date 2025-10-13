import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {

  ChatRoom({
    required this.id,
    required this.bookingId,
    required this.hostId,
    required this.guestId,
    required this.hostName,
    required this.guestName,
    required this.unreadCount, required this.createdAt, required this.updatedAt, this.hostAvatar,
    this.guestAvatar,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSender,
    this.isActive = true,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) => ChatRoom(
      id: id,
      bookingId: (map['bookingId'] ?? '') as String,
      hostId: (map['hostId'] ?? '') as String,
      guestId: map['guestId'] as String? ?? '',
      hostName: map['hostName'] as String? ?? '',
      guestName: map['guestName'] as String? ?? '',
      hostAvatar: map['hostAvatar'] as String?,
      guestAvatar: map['guestAvatar'] as String?,
      lastMessage: map['lastMessage'] as String?,
      lastMessageTime: (map['lastMessageTime'] as Timestamp?)?.toDate(),
      lastMessageSender: map['lastMessageSender'] as String?,
      unreadCount: Map<String, int>.from(map['unreadCount'] as Map<dynamic, dynamic>? ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] as bool? ?? true,
    );
  final String id;
  final String bookingId;
  final String hostId;
  final String guestId;
  final String hostName;
  final String guestName;
  final String? hostAvatar;
  final String? guestAvatar;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSender;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Map<String, dynamic> toMap() => {
      'bookingId': bookingId,
      'hostId': hostId,
      'guestId': guestId,
      'hostName': hostName,
      'guestName': guestName,
      'hostAvatar': hostAvatar,
      'guestAvatar': guestAvatar,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'lastMessageSender': lastMessageSender,
      'unreadCount': unreadCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
    };

  ChatRoom copyWith({
    String? id,
    String? bookingId,
    String? hostId,
    String? guestId,
    String? hostName,
    String? guestName,
    String? hostAvatar,
    String? guestAvatar,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSender,
    Map<String, int>? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) => ChatRoom(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      hostId: hostId ?? this.hostId,
      guestId: guestId ?? this.guestId,
      hostName: hostName ?? this.hostName,
      guestName: guestName ?? this.guestName,
      hostAvatar: hostAvatar ?? this.hostAvatar,
      guestAvatar: guestAvatar ?? this.guestAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSender: lastMessageSender ?? this.lastMessageSender,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
}

class ChatMessage {

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.content, required this.type, required this.timestamp, this.senderAvatar,
    this.isRead = false,
    this.metadata,
    this.replyToId,
    this.isEdited = false,
    this.editedAt,
    this.isDeleted = false,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) => ChatMessage(
      id: id,
      chatRoomId: map['chatRoomId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      senderAvatar: map['senderAvatar'] as String?,
      content: map['content'] as String? ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] as bool? ?? false,
      metadata: map['metadata'] as Map<String, dynamic>?,
      replyToId: map['replyToId'] as String?,
      isEdited: map['isEdited'] as bool? ?? false,
      editedAt: (map['editedAt'] as Timestamp?)?.toDate(),
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? metadata;
  final String? replyToId;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeleted;

  Map<String, dynamic> toMap() => {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp,
      'isRead': isRead,
      'metadata': metadata,
      'replyToId': replyToId,
      'isEdited': isEdited,
      'editedAt': editedAt,
      'isDeleted': isDeleted,
    };

  ChatMessage copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? metadata,
    String? replyToId,
    bool? isEdited,
    DateTime? editedAt,
    bool? isDeleted,
  }) => ChatMessage(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
      replyToId: replyToId ?? this.replyToId,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
}

enum MessageType {
  text,
  image,
  audio,
  file,
  location,
  system,
  booking,
}

class TypingIndicator {

  TypingIndicator({
    required this.userId,
    required this.userName,
    required this.timestamp,
  });

  factory TypingIndicator.fromMap(Map<String, dynamic> map) => TypingIndicator(
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  final String userId;
  final String userName;
  final DateTime timestamp;

  Map<String, dynamic> toMap() => {
      'userId': userId,
      'userName': userName,
      'timestamp': timestamp,
    };
}