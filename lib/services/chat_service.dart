import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:salas_beats/models/chat_model.dart';
import 'package:salas_beats/models/user_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Crear o obtener sala de chat para una reserva
  Future<ChatRoom> createOrGetChatRoom({
    required String bookingId,
    required String hostId,
    required String guestId,
    required String hostName,
    required String guestName,
    String? hostAvatar,
    String? guestAvatar,
  }) async {
    try {
      // Buscar sala existente
      final existingRoom = await _firestore
          .collection('chats')
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get();

      if (existingRoom.docs.isNotEmpty) {
        return ChatRoom.fromMap(
          existingRoom.docs.first.data(),
          existingRoom.docs.first.id,
        );
      }

      // Crear nueva sala
      final chatRoomData = {
        'bookingId': bookingId,
        'hostId': hostId,
        'guestId': guestId,
        'participants': [hostId, guestId],
        'hostName': hostName,
        'guestName': guestName,
        'hostAvatar': hostAvatar,
        'guestAvatar': guestAvatar,
        'lastMessage': null,
        'lastMessageTime': null,
        'lastMessageSender': null,
        'unreadCount': {
          hostId: 0,
          guestId: 0,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      final docRef = await _firestore.collection('chats').add(chatRoomData);
      
      // Obtener el documento creado
      final doc = await docRef.get();
      return ChatRoom.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Error creating chat room: $e');
    }
  }

  // Obtener salas de chat del usuario
  Stream<List<ChatRoom>> getUserChatRooms(String userId) => _firestore
        .collection('chats')
        .where('isActive', isEqualTo: true)
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoom.fromMap(doc.data(), doc.id))
            .toList(),);

  // Enviar mensaje
  Future<void> sendMessage({
    required String chatRoomId,
    required String content,
    required MessageType type,
    String? replyToId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      // Obtener datos del usuario
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final userData = UserModel.fromFirestore(userDoc);

      final messageData = {
        'chatRoomId': chatRoomId,
        'senderId': currentUser.uid,
        'senderName': userData.name,
        'senderAvatar': userData.photoURL,
        'content': content,
        'type': type.toString().split('.').last,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'metadata': metadata,
        'replyToId': replyToId,
        'isEdited': false,
        'editedAt': null,
        'isDeleted': false,
      };

      // Agregar mensaje
      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(messageData);

      // Actualizar sala de chat
      await _updateChatRoomLastMessage(
        chatRoomId: chatRoomId,
        lastMessage: content,
        senderId: currentUser.uid,
      );
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  // Obtener mensajes de una sala
  Stream<List<ChatMessage>> getChatMessages(String chatRoomId) => _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
            .toList(),);

  // Marcar mensajes como leídos
  Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    try {
      final batch = _firestore.batch();
      
      // Obtener mensajes no leídos
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      // Marcar como leídos
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      // Actualizar contador de no leídos
      await _firestore.collection('chats').doc(chatRoomId).update({
        'unreadCount.$userId': 0,
      });
    } catch (e) {
      throw Exception('Error marking messages as read: $e');
    }
  }

  // Subir archivo (imagen, audio, etc.)
  Future<String> uploadFile(File file, String chatRoomId, String fileName) async {
    try {
      final ref = _storage
          .ref()
          .child('chat_files')
          .child(chatRoomId)
          .child(fileName);

      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }

  // Enviar indicador de escritura
  Future<void> sendTypingIndicator(String chatRoomId, bool isTyping) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = UserModel.fromFirestore(userDoc);

      if (isTyping) {
        await _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .collection('typing')
            .doc(user.uid)
            .set({
          'userId': user.uid,
          'userName': userData.name,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .collection('typing')
            .doc(user.uid)
            .delete();
      }
    } catch (e) {
      print('Error sending typing indicator: $e');
    }
  }

  // Obtener indicadores de escritura
  Stream<List<TypingIndicator>> getTypingIndicators(String chatRoomId) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('typing')
        .where('userId', isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TypingIndicator.fromMap(doc.data()))
            .where((indicator) => 
                DateTime.now().difference(indicator.timestamp).inSeconds < 5,)
            .toList(),);
  }

  // Editar mensaje
  Future<void> editMessage(String chatRoomId, String messageId, String newContent) async {
    try {
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({
        'content': newContent,
        'isEdited': true,
        'editedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error editing message: $e');
    }
  }

  // Eliminar mensaje
  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    try {
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({
        'isDeleted': true,
        'content': 'Mensaje eliminado',
      });
    } catch (e) {
      throw Exception('Error deleting message: $e');
    }
  }

  // Obtener total de mensajes no leídos
  Stream<int> getTotalUnreadCount(String userId) => _firestore
        .collection('chatRooms')
        .where('isActive', isEqualTo: true)
        .where(Filter.or(
          Filter('hostId', isEqualTo: userId),
          Filter('guestId', isEqualTo: userId),
        ),)
        .snapshots()
        .map((snapshot) {
      var total = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final unreadCount = data['unreadCount'] as Map<String, dynamic>? ?? {};
        total += (unreadCount[userId] as int?) ?? 0;
      }
      return total;
    });

  // Actualizar último mensaje de la sala
  Future<void> _updateChatRoomLastMessage({
    required String chatRoomId,
    required String lastMessage,
    required String senderId,
  }) async {
    try {
      // Obtener sala actual
      final chatRoomDoc = await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .get();
      
      if (!chatRoomDoc.exists) return;
      
      final chatRoom = ChatRoom.fromMap(chatRoomDoc.data()!, chatRoomDoc.id);
      
      // Determinar quién recibe la notificación
      final receiverId = senderId == chatRoom.hostId ? chatRoom.guestId : chatRoom.hostId;
      
      // Actualizar contador de no leídos
      final currentUnreadCount = chatRoom.unreadCount[receiverId] ?? 0;
      
      await _firestore.collection('chats').doc(chatRoomId).update({
        'lastMessage': lastMessage,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSender': senderId,
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCount.$receiverId': currentUnreadCount + 1,
      });
    } catch (e) {
      print('Error updating chat room: $e');
    }
  }

  // Cerrar sala de chat
  Future<void> closeChatRoom(String chatRoomId) async {
    try {
      await _firestore.collection('chats').doc(chatRoomId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error closing chat room: $e');
    }
  }
}