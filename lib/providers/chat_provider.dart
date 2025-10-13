import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:salas_beats/models/chat_model.dart';
import 'package:salas_beats/services/auth_service.dart';
import 'package:salas_beats/services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  
  // Estado de carga
  bool _isLoading = false;
  bool _isSendingMessage = false;
  bool _isUploadingFile = false;
  
  // Datos
  List<ChatRoom> _chatRooms = [];
  List<ChatMessage> _currentMessages = [];
  List<TypingIndicator> _typingIndicators = [];
  ChatRoom? _currentChatRoom;
  int _totalUnreadCount = 0;
  
  // Streams
  StreamSubscription<List<ChatRoom>>? _chatRoomsSubscription;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  StreamSubscription<List<TypingIndicator>>? _typingSubscription;
  StreamSubscription<int>? _unreadCountSubscription;
  
  // Estado de escritura
  bool _isTyping = false;
  Timer? _typingTimer;
  
  // Error
  String? _error;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isSendingMessage => _isSendingMessage;
  bool get isUploadingFile => _isUploadingFile;
  List<ChatRoom> get chatRooms => _chatRooms;
  List<ChatMessage> get currentMessages => _currentMessages;
  List<TypingIndicator> get typingIndicators => _typingIndicators;
  ChatRoom? get currentChatRoom => _currentChatRoom;
  int get totalUnreadCount => _totalUnreadCount;
  bool get isTyping => _isTyping;
  String? get error => _error;
  
  // Inicializar provider
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final user = await _authService.getCurrentUserData();
      if (user != null) {
        await _subscribeToUserChatRooms(user.id);
        await _subscribeToUnreadCount(user.id);
      }
    } catch (e) {
      _error = 'Error initializing chat: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Suscribirse a las salas de chat del usuario
  Future<void> _subscribeToUserChatRooms(String userId) async {
    _chatRoomsSubscription?.cancel();
    _chatRoomsSubscription = _chatService.getUserChatRooms(userId).listen(
      (chatRooms) {
        _chatRooms = chatRooms;
        notifyListeners();
      },
      onError: (Object error) {
        _error = 'Error loading chat rooms: $error';
        notifyListeners();
      },
    );
  }
  
  // Suscribirse al contador de no leídos
  Future<void> _subscribeToUnreadCount(String userId) async {
    _unreadCountSubscription?.cancel();
    _unreadCountSubscription = _chatService.getTotalUnreadCount(userId).listen(
      (count) {
        _totalUnreadCount = count;
        notifyListeners();
      },
      onError: (Object error) {
        print('Error loading unread count: $error');
      },
    );
  }
  
  // Crear o obtener sala de chat
  Future<ChatRoom?> createOrGetChatRoom({
    required String bookingId,
    required String hostId,
    required String guestId,
    required String hostName,
    required String guestName,
    String? hostAvatar,
    String? guestAvatar,
  }) async {
    try {
      _error = null;
      
      final chatRoom = await _chatService.createOrGetChatRoom(
        bookingId: bookingId,
        hostId: hostId,
        guestId: guestId,
        hostName: hostName,
        guestName: guestName,
        hostAvatar: hostAvatar,
        guestAvatar: guestAvatar,
      );
      
      return chatRoom;
    } catch (e) {
      _error = 'Error creating chat room: $e';
      notifyListeners();
      return null;
    }
  }
  
  // Entrar a una sala de chat
  Future<void> enterChatRoom(ChatRoom chatRoom) async {
    try {
      _currentChatRoom = chatRoom;
      _currentMessages = [];
      _typingIndicators = [];
      
      // Cancelar suscripciones anteriores
      _messagesSubscription?.cancel();
      _typingSubscription?.cancel();
      
      // Suscribirse a mensajes
      _messagesSubscription = _chatService.getChatMessages(chatRoom.id).listen(
        (messages) {
          _currentMessages = messages;
          notifyListeners();
        },
        onError: (Object error) {
          _error = 'Error loading messages: $error';
          notifyListeners();
        },
      );
      
      // Suscribirse a indicadores de escritura
      _typingSubscription = _chatService.getTypingIndicators(chatRoom.id).listen(
        (indicators) {
          _typingIndicators = indicators;
          notifyListeners();
        },
        onError: (Object error) {
          print('Error loading typing indicators: $error');
        },
      );
      
      // Marcar mensajes como leídos
      final user = await _authService.getCurrentUserData();
      if (user != null) {
        await _chatService.markMessagesAsRead(chatRoom.id, user.id);
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Error entering chat room: $e';
      notifyListeners();
    }
  }
  
  // Salir de la sala de chat
  void exitChatRoom() {
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    _stopTyping();
    
    _currentChatRoom = null;
    _currentMessages = [];
    _typingIndicators = [];
    
    notifyListeners();
  }
  
  // Enviar mensaje de texto
  Future<void> sendTextMessage(String content, {String? replyToId}) async {
    if (_currentChatRoom == null || content.trim().isEmpty) return;
    
    try {
      _isSendingMessage = true;
      _error = null;
      notifyListeners();
      
      await _chatService.sendMessage(
        chatRoomId: _currentChatRoom!.id,
        content: content.trim(),
        type: MessageType.text,
        replyToId: replyToId,
      );
      
      _stopTyping();
    } catch (e) {
      _error = 'Error sending message: $e';
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }
  
  // Enviar imagen
  Future<void> sendImageMessage(File imageFile, {String? caption}) async {
    if (_currentChatRoom == null) return;
    
    try {
      _isUploadingFile = true;
      _error = null;
      notifyListeners();
      
      // Subir imagen
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageUrl = await _chatService.uploadFile(
        imageFile,
        _currentChatRoom!.id,
        fileName,
      );
      
      // Enviar mensaje con la URL de la imagen
      await _chatService.sendMessage(
        chatRoomId: _currentChatRoom!.id,
        content: caption ?? 'Imagen',
        type: MessageType.image,
        metadata: {
          'imageUrl': imageUrl,
          'fileName': fileName,
        },
      );
    } catch (e) {
      _error = 'Error sending image: $e';
    } finally {
      _isUploadingFile = false;
      notifyListeners();
    }
  }
  
  // Enviar archivo
  Future<void> sendFileMessage(File file, String fileName) async {
    if (_currentChatRoom == null) return;
    
    try {
      _isUploadingFile = true;
      _error = null;
      notifyListeners();
      
      // Subir archivo
      final fileUrl = await _chatService.uploadFile(
        file,
        _currentChatRoom!.id,
        fileName,
      );
      
      // Enviar mensaje con la URL del archivo
      await _chatService.sendMessage(
        chatRoomId: _currentChatRoom!.id,
        content: fileName,
        type: MessageType.file,
        metadata: {
          'fileUrl': fileUrl,
          'fileName': fileName,
          'fileSize': await file.length(),
        },
      );
    } catch (e) {
      _error = 'Error sending file: $e';
    } finally {
      _isUploadingFile = false;
      notifyListeners();
    }
  }
  
  // Iniciar escritura
  void startTyping() {
    if (_currentChatRoom == null || _isTyping) return;
    
    _isTyping = true;
    _chatService.sendTypingIndicator(_currentChatRoom!.id, true);
    
    // Cancelar timer anterior
    _typingTimer?.cancel();
    
    // Configurar timer para detener escritura automáticamente
    _typingTimer = Timer(const Duration(seconds: 3), _stopTyping);
    
    notifyListeners();
  }
  
  // Detener escritura
  void _stopTyping() {
    if (!_isTyping || _currentChatRoom == null) return;
    
    _isTyping = false;
    _typingTimer?.cancel();
    _chatService.sendTypingIndicator(_currentChatRoom!.id, false);
    
    notifyListeners();
  }
  
  // Editar mensaje
  Future<void> editMessage(String messageId, String newContent) async {
    if (_currentChatRoom == null || newContent.trim().isEmpty) return;
    
    try {
      _error = null;
      await _chatService.editMessage(
        _currentChatRoom!.id,
        messageId,
        newContent.trim(),
      );
    } catch (e) {
      _error = 'Error editing message: $e';
      notifyListeners();
    }
  }
  
  // Eliminar mensaje
  Future<void> deleteMessage(String messageId) async {
    if (_currentChatRoom == null) return;
    
    try {
      _error = null;
      await _chatService.deleteMessage(_currentChatRoom!.id, messageId);
    } catch (e) {
      _error = 'Error deleting message: $e';
      notifyListeners();
    }
  }
  
  // Marcar mensajes como leídos
  Future<void> markMessagesAsRead(String chatRoomId) async {
    try {
      final user = await _authService.getCurrentUserData();
      if (user != null) {
        await _chatService.markMessagesAsRead(chatRoomId, user.id);
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }
  
  // Cerrar sala de chat
  Future<void> closeChatRoom(String chatRoomId) async {
    try {
      _error = null;
      await _chatService.closeChatRoom(chatRoomId);
    } catch (e) {
      _error = 'Error closing chat room: $e';
      notifyListeners();
    }
  }
  
  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Obtener nombre del otro usuario en el chat
  String getOtherUserName(ChatRoom chatRoom, String currentUserId) => currentUserId == chatRoom.hostId ? chatRoom.guestName : chatRoom.hostName;
  
  // Obtener avatar del otro usuario en el chat
  String? getOtherUserAvatar(ChatRoom chatRoom, String currentUserId) => currentUserId == chatRoom.hostId ? chatRoom.guestAvatar : chatRoom.hostAvatar;
  
  @override
  void dispose() {
    _chatRoomsSubscription?.cancel();
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    _typingTimer?.cancel();
    super.dispose();
  }
}