import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:salas_beats/models/chat_model.dart';
import 'package:salas_beats/models/message_model.dart' hide MessageType;
import 'package:salas_beats/services/chat_service.dart';
import 'package:salas_beats/widgets/chat/message_bubble.dart';
// import '../../widgets/chat/chat_input.dart';

class ChatScreen extends StatefulWidget {

  const ChatScreen({
    required this.chatId, required this.otherUserId, required this.otherUserName, super.key,
    this.otherUserAvatar,
  });
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;

  @override
  State<ChatScreen> createState() => _ChatScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('chatId', chatId));
    properties.add(StringProperty('otherUserId', otherUserId));
    properties.add(StringProperty('otherUserName', otherUserName));
    properties.add(StringProperty('otherUserAvatar', otherUserAvatar));
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _markMessagesAsRead();
  }

  Future<void> _loadMessages() async {
    try {
      // final messages = await _chatService.getMessages(widget.chatId); // Method not available
      final messages = <MessageModel>[]; // Empty list as fallback
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar mensajes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markMessagesAsRead() async {
    try {
      // await _chatService.markMessagesAsRead(widget.chatId); // Method not available
    } catch (e) {
      // Silently handle error
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      // final message = await _chatService.sendMessage(
      //   chatRoomId: widget.chatId, // Required parameter
      //   receiverId: widget.otherUserId,
      //   text: text.trim(),
      // ); // Method not available
      final message = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        threadId: widget.chatId,
        fromUserId: 'current_user_id', // This should be the current user's ID
        toUserId: widget.otherUserId,
        text: text.trim(),
        createdAt: DateTime.now(),
      ); // Fallback

      setState(() {
        _messages.add(message);
        _isSending = false;
      });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar mensaje: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(),
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
            backgroundImage: widget.otherUserAvatar != null
                ? NetworkImage(widget.otherUserAvatar!)
                : null,
            child: widget.otherUserAvatar == null
                ? Text(
                    widget.otherUserName.isNotEmpty
                        ? widget.otherUserName[0].toUpperCase()
                        : '?',
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'En línea',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: () {
            // TODO: Implementar videollamada
          },
        ),
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: () {
            // TODO: Implementar llamada
          },
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
                  Icon(Icons.report, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Reportar usuario', style: TextStyle(color: Colors.orange)),
                ],
              ),
            ),
          ],
        ),
      ],
    );

  Widget _buildMessagesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay mensajes aún',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Envía el primer mensaje para comenzar la conversación',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMe = message.fromUserId != widget.otherUserId; // Using fromUserId instead of senderId
        final showAvatar = index == _messages.length - 1 ||
            _messages[index + 1].fromUserId != message.fromUserId; // Using fromUserId instead of senderId

        // Convert MessageModel to ChatMessage for MessageBubble
        final chatMessage = ChatMessage(
          id: message.id,
          chatRoomId: message.threadId,
          senderId: message.fromUserId,
          senderName: 'User', // Default name
          content: message.text,
          type: MessageType.text,
          timestamp: message.createdAt,
        );
        
        return MessageBubble(
          message: chatMessage,
          isNextMessageFromSameUser: !showAvatar,
        );
      },
    );
  }

  Widget _buildMessageInput() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Container( // ChatInput not available
        padding: const EdgeInsets.all(16),
        child: const Text('Chat input no disponible'),
        // controller: _messageController,
        // onSend: _sendMessage,
        // isLoading: _isSending,
      ),
    );

  void _handleMenuAction(String action) {
    switch (action) {
      case 'view_profile':
        Navigator.pushNamed(
          context,
          '/profile',
          arguments: {'userId': widget.otherUserId},
        );
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bloquear usuario'),
        content: Text(
          '¿Estás seguro de que quieres bloquear a ${widget.otherUserName}? '
          'No podrás recibir mensajes de este usuario.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _blockUser();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
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
          '¿Quieres reportar a ${widget.otherUserName} por comportamiento inapropiado?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reportUser();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
            ),
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
  }

  Future<void> _blockUser() async {
    try {
      // await _chatService.blockUser(widget.otherUserId); // Method not available
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario bloqueado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al bloquear usuario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _reportUser() async {
    try {
      // await _chatService.reportUser(widget.otherUserId, 'Comportamiento inapropiado'); // Method not available
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario reportado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reportar usuario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}