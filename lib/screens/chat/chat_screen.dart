import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/models/chat_model.dart';
import 'package:salas_beats/models/message_model.dart' hide MessageType;
import 'package:salas_beats/models/user_model.dart';
import 'package:salas_beats/providers/chat_provider.dart';
import 'package:salas_beats/widgets/chat/message_bubble.dart';
import 'package:salas_beats/widgets/chat/message_input.dart';
import 'package:salas_beats/widgets/common/loading_widget.dart';

class ChatScreen extends StatefulWidget {

  const ChatScreen({
    required this.chatId, required this.otherUser, super.key,
  });
  final String chatId;
  final UserModel otherUser;

  @override
  State<ChatScreen> createState() => _ChatScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('chatId', chatId));
    properties.add(DiagnosticsProperty<UserModel>('otherUser', otherUser));
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadMessages() async {
    try {
      final chatProvider = context.read<ChatProvider>();
      // Crear un ChatRoom mock para usar enterChatRoom
      final chatRoom = ChatRoom(
        id: widget.chatId,
        bookingId: '',
        hostId: '',
        guestId: '',
        hostName: '',
        guestName: '',
        lastMessageTime: DateTime.now(),
        unreadCount: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await chatProvider.enterChatRoom(chatRoom);
    } catch (e) {
      _showErrorSnackBar('Error al cargar mensajes');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _markMessagesAsRead() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.markMessagesAsRead(widget.chatId);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreMessages();
    }
  }

  void _loadMoreMessages() {
    // ChatProvider no tiene loadMoreMessages, se maneja automáticamente
    // a través de la suscripción en enterChatRoom
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildMessagesList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );

  PreferredSizeWidget _buildAppBar() => AppBar(
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: widget.otherUser.photoURL != null
                    ? NetworkImage(widget.otherUser.photoURL!)
                    : null,
                child: widget.otherUser.photoURL == null
                ? Text(
                    widget.otherUser.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 14),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUser.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    // TODO: Implementar funcionalidad de estado en línea
                    const isOnline = false; // Temporalmente deshabilitado
                    return const Text(
                      isOnline ? 'En línea' : 'Desconectado',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOnline ? Colors.green : Colors.grey,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: _startVideoCall,
        ),
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: _startVoiceCall,
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view_profile',
              child: Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 8),
                  Text('Ver perfil'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'block_user',
              child: Row(
                children: [
                  Icon(Icons.block, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Bloquear usuario', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'report_user',
              child: Row(
                children: [
                  Icon(Icons.report, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Reportar usuario', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );

  Widget _buildLoadingState() => const Center(
      child: LoadingWidget(message: 'Cargando mensajes...'),
    );

  Widget _buildMessagesList() => Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final messages = chatProvider.currentMessages;
        
        if (messages.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length + (chatProvider.isSendingMessage ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == messages.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final message = messages[index];
            const currentUserId = 'user1'; // TODO: Get from auth service
            final isMe = message.senderId == currentUserId;
            final showAvatar = _shouldShowAvatar(messages, index, isMe);
            final showTimestamp = _shouldShowTimestamp(messages, index);
            
            return Column(
              children: [
                if (showTimestamp) _buildTimestampDivider(message.timestamp),
                MessageBubble(
                  message: message,
                  isNextMessageFromSameUser: !showAvatar,
                ),
              ],
            );
          },
        );
      },
    );

  Widget _buildEmptyState() => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay mensajes aún',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Envía el primer mensaje para comenzar la conversación',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

  Widget _buildTimestampDivider(DateTime timestamp) => Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatTimestamp(timestamp),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );

  Widget _buildMessageInput() => DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: MessageInputWidget(
        controller: _messageController,
        onSendMessage: _sendMessage,
        onStartTyping: () {},
        onAttachImage: _showAttachmentOptions,
        onAttachFile: _showAttachmentOptions,
        isLoading: _isSending,
      ),
    );

  bool _shouldShowAvatar(List<ChatMessage> messages, int index, bool isMe) {
    if (isMe) return false;
    if (index == 0) return true;
    
    final currentMessage = messages[index];
    final nextMessage = messages[index - 1];
    
    return currentMessage.senderId != nextMessage.senderId;
  }

  bool _shouldShowTimestamp(List<ChatMessage> messages, int index) {
    if (index == messages.length - 1) return true;
    
    final currentMessage = messages[index];
    final nextMessage = messages[index + 1];
    
    final timeDiff = currentMessage.timestamp.difference(nextMessage.timestamp);
    return timeDiff.inHours >= 1;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inDays == 0) {
      return 'Hoy';
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} días atrás';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Future<void> _sendMessage(String text, {MessageModel? replyTo}) async {
    if (text.trim().isEmpty || _isSending) return;
    
    setState(() {
      _isSending = true;
    });
    
    try {
      final chatProvider = context.read<ChatProvider>();
      await chatProvider.sendTextMessage(
        text.trim(),
        replyToId: replyTo?.id,
      );
      
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      _showErrorSnackBar('Error al enviar mensaje');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }



  void _showAttachmentOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Archivo'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _takePhoto() {
    // TODO: Implementar tomar foto
  }

  void _pickImage() {
    // TODO: Implementar seleccionar imagen
  }

  void _pickFile() {
    // TODO: Implementar seleccionar archivo
  }

  void _startVideoCall() {
    // TODO: Implementar videollamada
    _showErrorSnackBar('Videollamadas próximamente');
  }

  void _startVoiceCall() {
    // TODO: Implementar llamada de voz
    _showErrorSnackBar('Llamadas de voz próximamente');
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'view_profile':
        // TODO: Navegar al perfil del usuario
        break;
      case 'block_user':
        _showBlockUserDialog();
        break;
      case 'report_user':
        _showReportUserDialog();
        break;
    }
  }

  void _showBlockUserDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bloquear usuario'),
        content: Text(
          '¿Estás seguro de que quieres bloquear a ${widget.otherUser.name}? No podrán enviarte mensajes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar bloqueo de usuario
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );
  }

  void _showReportUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar usuario'),
        content: Text(
          '¿Quieres reportar a ${widget.otherUser.name}? Revisaremos el reporte y tomaremos las medidas necesarias.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar reporte de usuario
              // await _chatService.reportUser(widget.otherUserId, 'Comportamiento inapropiado'); // Method not available
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}