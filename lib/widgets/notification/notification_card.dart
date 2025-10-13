import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:salas_beats/models/notification_model.dart';

class NotificationCard extends StatelessWidget {

  const NotificationCard({
    required this.notification, super.key,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
    this.showActions = true,
  });
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;
    
    return Card(
      elevation: isUnread ? 2 : 1,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isUnread
                ? Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, isUnread),
              const SizedBox(height: 8),
              _buildContent(theme),
              if (showActions) ...[
                const SizedBox(height: 12),
                _buildActions(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isUnread) => Row(
      children: [
        // Icono del tipo de notificación
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getTypeColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              notification.typeIcon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Título y tiempo
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      notification.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                        color: isUnread
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isUnread)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    _getTypeDisplayName(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getTypeColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    ' • ${notification.timeAgo}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

  Widget _buildContent(ThemeData theme) => Padding(
      padding: const EdgeInsets.only(left: 52),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Mostrar imagen si existe
          if (notification.imageUrl != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                notification.imageUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: Icon(Icons.broken_image),
                    ),
                  ),
              ),
            ),
          ],
          
          // Mostrar datos adicionales si existen
          if (notification.data.isNotEmpty && _shouldShowData()) ...[
            const SizedBox(height: 8),
            _buildDataChips(theme),
          ],
        ],
      ),
    );

  Widget _buildDataChips(ThemeData theme) {
    final relevantData = _getRelevantData();
    if (relevantData.isEmpty) return const SizedBox.shrink();
    
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: relevantData.entries.map((entry) => Chip(
          label: Text(
            '${entry.key}: ${entry.value}',
            style: theme.textTheme.bodySmall,
          ),
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),).toList(),
    );
  }

  Widget _buildActions(ThemeData theme) => Padding(
      padding: const EdgeInsets.only(left: 52),
      child: Row(
        children: [
          // Botón de marcar como leída
          if (!notification.isRead && onMarkAsRead != null)
            TextButton.icon(
              onPressed: onMarkAsRead,
              icon: const Icon(Icons.mark_email_read, size: 16),
              label: const Text('Marcar como leída'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                textStyle: theme.textTheme.bodySmall,
              ),
            ),
          
          const Spacer(),
          
          // Botón de eliminar
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 20),
              style: IconButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              tooltip: 'Eliminar notificación',
            ),
        ],
      ),
    );

  Color _getTypeColor() {
    switch (notification.type) {
      case 'booking':
        return const Color(0xFF4CAF50); // Verde
      case 'payment':
        return const Color(0xFF2196F3); // Azul
      case 'chat':
        return const Color(0xFFFF9800); // Naranja
      case 'review':
        return const Color(0xFFFFC107); // Amarillo
      case 'host':
        return const Color(0xFF9C27B0); // Púrpura
      case 'system':
        return const Color(0xFF607D8B); // Gris azulado
      case 'promotion':
        return const Color(0xFFE91E63); // Rosa
      default:
        return const Color(0xFF757575); // Gris
    }
  }

  String _getTypeDisplayName() {
    switch (notification.type) {
      case 'booking':
        return 'Reserva';
      case 'payment':
        return 'Pago';
      case 'chat':
        return 'Mensaje';
      case 'review':
        return 'Reseña';
      case 'host':
        return 'Anfitrión';
      case 'system':
        return 'Sistema';
      case 'promotion':
        return 'Promoción';
      default:
        return 'General';
    }
  }

  bool _shouldShowData() {
    // Solo mostrar datos para ciertos tipos de notificación
    return ['booking', 'payment', 'review'].contains(notification.type);
  }

  Map<String, String> _getRelevantData() {
    final relevantData = <String, String>{};
    
    switch (notification.type) {
      case 'booking':
        if (notification.data['bookingId'] != null) {
          relevantData['Reserva'] = notification.data['bookingId'].toString().substring(0, 8);
        }
        if (notification.data['checkIn'] != null) {
          relevantData['Check-in'] = (notification.data['checkIn'] as String?) ?? '';
        }
        break;
      case 'payment':
        if (notification.data['amount'] != null) {
          relevantData['Monto'] = '\$${notification.data['amount']}';
        }
        if (notification.data['method'] != null) {
          relevantData['Método'] = (notification.data['method'] as String?) ?? '';
        }
        break;
      case 'review':
        if (notification.data['rating'] != null) {
          relevantData['Calificación'] = '${notification.data['rating']} ⭐';
        }
        break;
    }
    
    return relevantData;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<NotificationModel>('notification', notification));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onMarkAsRead', onMarkAsRead));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onDelete', onDelete));
    properties.add(DiagnosticsProperty<bool>('showActions', showActions));
  }
}

/// Widget compacto para mostrar notificaciones en listas pequeñas
class CompactNotificationCard extends StatelessWidget {

  const CompactNotificationCard({
    required this.notification, super.key,
    this.onTap,
  });
  final NotificationModel notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUnread
              ? theme.colorScheme.primary.withOpacity(0.05)
              : null,
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            // Icono
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getTypeColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  notification.typeIcon,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Tiempo y estado
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  notification.timeAgo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case 'booking':
        return const Color(0xFF4CAF50);
      case 'payment':
        return const Color(0xFF2196F3);
      case 'chat':
        return const Color(0xFFFF9800);
      case 'review':
        return const Color(0xFFFFC107);
      case 'host':
        return const Color(0xFF9C27B0);
      case 'system':
        return const Color(0xFF607D8B);
      case 'promotion':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF757575);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<NotificationModel>('notification', notification));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
  }
}