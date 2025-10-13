import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/models/chat_model.dart';
import 'package:salas_beats/providers/auth_provider.dart';
import 'package:salas_beats/providers/chat_provider.dart';
import 'package:salas_beats/widgets/chat/message_bubble.dart';
import 'package:salas_beats/widgets/chat/message_input.dart';
import 'package:salas_beats/widgets/chat/typing_indicator.dart';
import 'package:salas_beats/widgets/common/loading_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatRoomScreen extends StatefulWidget {

  const ChatRoomScreen({
    required this.chatRoom, super.key,
  });
  final ChatRoom chatRoom;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ChatRoom>('chatRoom', chatRoom));
  }
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().enterChatRoom(widget.chatRoom);
    });
  }

  @override
  void dispose() {
    context.read<ChatProvider>().exitChatRoom();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: _buildAppBar(context, theme),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(context, theme),
          ),
          _buildTypingIndicator(theme),
          _buildMessageInput(context, theme),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) => AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final currentUserId = authProvider.currentUser?.id ?? '';
              final chatProvider = context.read<ChatProvider>();
              
              final otherUserName = chatProvider.getOtherUserName(widget.chatRoom, currentUserId);
              final otherUserAvatar = chatProvider.getOtherUserAvatar(widget.chatRoom, currentUserId);
              
              return Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    backgroundImage: otherUserAvatar != null 
                        ? NetworkImage(otherUserAvatar)
                        : null,
                    child: otherUserAvatar == null
                        ? Text(
                            otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          otherUserName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Reserva #${widget.chatRoom.bookingId.substring(0, 8)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'info',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline),
                      SizedBox(width: 8),
                      Text('Info de la reserva'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'close',
                  child: Row(
                    children: [
                      Icon(Icons.close),
                      SizedBox(width: 8),
                      Text('Cerrar chat'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );

  Widget _buildMessagesList(BuildContext context, ThemeData theme) => Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.currentMessages.isEmpty) {
          return _buildEmptyMessages(theme);
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.all(16),
          itemCount: chatProvider.currentMessages.length,
          itemBuilder: (context, index) {
            final message = chatProvider.currentMessages[index];
            final isNextMessageFromSameUser = index > 0 &&
                chatProvider.currentMessages[index - 1].senderId == message.senderId;
            
            return MessageBubble(
              message: message,
              isNextMessageFromSameUser: isNextMessageFromSameUser,
              onEdit: (messageId, newContent) => 
                  chatProvider.editMessage(messageId, newContent),
              onDelete: (messageId) => chatProvider.deleteMessage(messageId),
            );
          },
        );
      },
    );

  Widget _buildEmptyMessages(ThemeData theme) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Inicia la conversación',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Envía un mensaje para comenzar a chatear',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

  Widget _buildTypingIndicator(ThemeData theme) => Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.typingIndicators.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TypingIndicatorWidget(
            indicators: chatProvider.typingIndicators,
          ),
        );
      },
    );

  Widget _buildMessageInput(BuildContext context, ThemeData theme) => Consumer<ChatProvider>(
      builder: (context, chatProvider, child) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: MessageInputWidget(
            controller: _messageController,
            onSendMessage: (content) => _sendMessage(context, content),
            onStartTyping: () => chatProvider.startTyping(),
            onAttachImage: () => _attachImage(context),
            onAttachFile: () => _attachFile(context),
            isLoading: chatProvider.isSendingMessage || chatProvider.isUploadingFile,
          ),
        ),
    );

  void _sendMessage(BuildContext context, String content) {
    if (content.trim().isEmpty) return;
    
    context.read<ChatProvider>().sendTextMessage(content);
    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _attachImage(BuildContext context) async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      
      if (image != null) {
        final file = File(image.path);
        await context.read<ChatProvider>().sendImageMessage(file);
        _scrollToBottom();
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Error al seleccionar imagen: $e');
    }
  }

  Future<void> _attachFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final fileName = result.files.first.name;
        
        await context.read<ChatProvider>().sendFileMessage(file, fileName);
        _scrollToBottom();
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Error al seleccionar archivo: $e');
    }
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

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'info':
        _showBookingInfo(context);
        break;
      case 'close':
        _showCloseConfirmation(context);
        break;
    }
  }

  void _showBookingInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información de la reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${widget.chatRoom.bookingId}'),
            const SizedBox(height: 8),
            Text('Anfitrión: ${widget.chatRoom.hostName}'),
            const SizedBox(height: 8),
            Text('Huésped: ${widget.chatRoom.guestName}'),
            const SizedBox(height: 8),
            Text('Creado: ${timeago.format(widget.chatRoom.createdAt, locale: "es")}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showCloseConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar chat'),
        content: const Text(
          '¿Estás seguro de que quieres cerrar este chat? '
          'No podrás enviar más mensajes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ChatProvider>().closeChatRoom(widget.chatRoom.id);
              Navigator.of(context).pop();
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}