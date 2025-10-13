import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/models/chat_model.dart';
import 'package:salas_beats/providers/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatelessWidget {

  const MessageBubble({
    required this.message, super.key,
    this.isNextMessageFromSameUser = false,
    this.onEdit,
    this.onDelete,
  });
  final ChatMessage message;
  final bool isNextMessageFromSameUser;
  final Function(String messageId, String newContent)? onEdit;
  final Function(String messageId)? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = context.read<AuthProvider>().user?.id ?? '';
    final isOwnMessage = message.senderId == currentUserId;
    
    return Container(
      margin: EdgeInsets.only(
        bottom: isNextMessageFromSameUser ? 2 : 8,
        left: isOwnMessage ? 48 : 0,
        right: isOwnMessage ? 0 : 48,
      ),
      child: Column(
        crossAxisAlignment: isOwnMessage 
            ? CrossAxisAlignment.end 
            : CrossAxisAlignment.start,
        children: [
          if (!isNextMessageFromSameUser) _buildMessageHeader(theme, isOwnMessage),
          _buildMessageContent(context, theme, isOwnMessage),
          if (!isNextMessageFromSameUser) _buildMessageFooter(context, theme),
        ],
      ),
    );
  }

  Widget _buildMessageHeader(ThemeData theme, bool isOwnMessage) {
    if (isOwnMessage) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Text(
        message.senderName,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, ThemeData theme, bool isOwnMessage) => GestureDetector(
      onLongPress: () => _showMessageOptions(context, isOwnMessage),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: _getMessageBackgroundColor(theme, isOwnMessage),
          borderRadius: _getMessageBorderRadius(isOwnMessage),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: _buildMessageBody(context, theme, isOwnMessage),
      ),
    );

  Widget _buildMessageBody(BuildContext context, ThemeData theme, bool isOwnMessage) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage(theme, isOwnMessage);
      case MessageType.image:
        return _buildImageMessage(context, theme, isOwnMessage);
      case MessageType.audio:
        return _buildAudioMessage(context, theme, isOwnMessage);
      case MessageType.file:
        return _buildFileMessage(context, theme, isOwnMessage);
      case MessageType.location:
        return _buildLocationMessage(context, theme, isOwnMessage);
      case MessageType.system:
        return _buildSystemMessage(theme);
      case MessageType.booking:
        return _buildBookingMessage(context, theme, isOwnMessage);
    }
  }

  Widget _buildTextMessage(ThemeData theme, bool isOwnMessage) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isEdited) _buildEditedIndicator(theme),
          Text(
            message.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _getMessageTextColor(theme, isOwnMessage),
            ),
          ),
        ],
      ),
    );

  Widget _buildImageMessage(BuildContext context, ThemeData theme, bool isOwnMessage) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: _getMessageBorderRadius(isOwnMessage),
          child: GestureDetector(
            onTap: () => _showImageFullScreen(context),
            child: Image.network(
              (message.metadata?['fileUrl'] as String?) ?? '',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200,
                  height: 200,
                  color: theme.colorScheme.surface,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                  width: 200,
                  height: 200,
                  color: theme.colorScheme.errorContainer,
                  child: Icon(
                    Icons.broken_image,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
            ),
          ),
        ),
        if (message.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              message.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _getMessageTextColor(theme, isOwnMessage),
              ),
            ),
          ),
      ],
    );

  Widget _buildFileMessage(BuildContext context, ThemeData theme, bool isOwnMessage) => Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _openFile((message.metadata?['fileUrl'] as String?) ?? ''),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getFileIcon((message.metadata?['fileName'] as String?) ?? ''),
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (message.metadata?['fileName'] as String?) ?? 'Archivo',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _getMessageTextColor(theme, isOwnMessage),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Toca para abrir',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              message.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _getMessageTextColor(theme, isOwnMessage),
              ),
            ),
          ],
        ],
      ),
    );

  Widget _buildSystemMessage(ThemeData theme) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        message.content,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );

  Widget _buildEditedIndicator(ThemeData theme) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        'editado',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          fontStyle: FontStyle.italic,
        ),
      ),
    );

  Widget _buildMessageFooter(BuildContext context, ThemeData theme) => Padding(
      padding: const EdgeInsets.only(top: 2, left: 12, right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            timeago.format(message.timestamp),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          if (message.isRead && message.senderId == context.read<AuthProvider>().user?.id) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.done_all,
              size: 12,
              color: theme.colorScheme.primary,
            ),
          ],
        ],
      ),
    );

  Color _getMessageBackgroundColor(ThemeData theme, bool isOwnMessage) {
    if (message.type == MessageType.system) {
      return theme.colorScheme.surfaceContainerHighest.withOpacity(0.3);
    }
    
    return isOwnMessage
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
  }

  Color _getMessageTextColor(ThemeData theme, bool isOwnMessage) {
    if (message.type == MessageType.system) {
      return theme.colorScheme.onSurface.withOpacity(0.6);
    }
    
    return isOwnMessage
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;
  }

  BorderRadius _getMessageBorderRadius(bool isOwnMessage) {
    const radius = Radius.circular(16);
    const smallRadius = Radius.circular(4);
    
    if (isOwnMessage) {
      return BorderRadius.only(
        topLeft: radius,
        topRight: isNextMessageFromSameUser ? smallRadius : radius,
        bottomLeft: radius,
        bottomRight: smallRadius,
      );
    } else {
      return BorderRadius.only(
        topLeft: isNextMessageFromSameUser ? smallRadius : radius,
        topRight: radius,
        bottomLeft: smallRadius,
        bottomRight: radius,
      );
    }
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
        return Icons.archive;
      case 'mp3':
      case 'wav':
      case 'aac':
        return Icons.audio_file;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _showMessageOptions(BuildContext context, bool isOwnMessage) {
    if (message.type == MessageType.system) return;
    
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwnMessage && message.type == MessageType.text) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar mensaje'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Eliminar mensaje'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copiar'),
              onTap: () {
                Navigator.pop(context);
                _copyMessage(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: message.content);
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar mensaje'),
        content: TextField(
          controller: controller,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Escribe tu mensaje...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onEdit?.call(message.id, controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar mensaje'),
        content: const Text('¿Estás seguro de que quieres eliminar este mensaje?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              onDelete?.call(message.id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioMessage(BuildContext context, ThemeData theme, bool isOwnMessage) => Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_filled,
            color: isOwnMessage ? Colors.white : theme.primaryColor,
            size: 32,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audio Message',
                  style: TextStyle(
                    color: isOwnMessage ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '0:30',
                  style: TextStyle(
                    color: isOwnMessage ? Colors.white70 : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  Widget _buildLocationMessage(BuildContext context, ThemeData theme, bool isOwnMessage) => Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            color: isOwnMessage ? Colors.white : theme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Location shared',
              style: TextStyle(
                color: isOwnMessage ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

  Widget _buildBookingMessage(BuildContext context, ThemeData theme, bool isOwnMessage) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOwnMessage ? Colors.white.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event,
            color: isOwnMessage ? Colors.white : theme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Booking information',
              style: TextStyle(
                color: isOwnMessage ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

  void _copyMessage(BuildContext context) {
    // Implementar copia al portapapeles
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mensaje copiado'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showImageFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                (message.metadata?['fileUrl'] as String?) ?? '',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ChatMessage>('message', message));
    properties.add(DiagnosticsProperty<bool>('isNextMessageFromSameUser', isNextMessageFromSameUser));
    properties.add(ObjectFlagProperty<Function(String messageId, String newContent)?>.has('onEdit', onEdit));
    properties.add(ObjectFlagProperty<Function(String messageId)?>.has('onDelete', onDelete));
  }
}