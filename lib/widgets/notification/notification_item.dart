import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:salas_beats/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationItem extends StatelessWidget {

  const NotificationItem({
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
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: notification.isRead ? 0 : 2,
      color: notification.isRead ? null : theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono de notificación
              _buildNotificationIcon(context),
              const SizedBox(width: 12),
              
              // Contenido de la notificación
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      notification.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: notification.isRead 
                            ? FontWeight.normal 
                            : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Mensaje
                    Text(
                      notification.body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Tiempo y acciones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          timeago.format(notification.createdAt, locale: 'es'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        if (showActions) _buildActions(context),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Indicador de no leído
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    final theme = Theme.of(context);
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.booking:
        iconData = Icons.event;
        iconColor = Colors.blue;
        break;
      case NotificationType.payment:
        iconData = Icons.payment;
        iconColor = Colors.green;
        break;
      case NotificationType.chat:
        iconData = Icons.message;
        iconColor = Colors.orange;
        break;
      case NotificationType.review:
        iconData = Icons.star;
        iconColor = Colors.amber;
        break;
      case NotificationType.system:
        iconData = Icons.info;
        iconColor = theme.colorScheme.primary;
        break;
      case NotificationType.promotion:
        iconData = Icons.local_offer;
        iconColor = Colors.purple;
        break;
      case NotificationType.general:
      case NotificationType.host:
      default:
        iconData = Icons.notifications;
        iconColor = theme.colorScheme.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildActions(BuildContext context) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!notification.isRead && onMarkAsRead != null)
          IconButton(
            onPressed: onMarkAsRead,
            icon: const Icon(Icons.mark_email_read),
            iconSize: 18,
            tooltip: 'Marcar como leído',
          ),
        if (onDelete != null)
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            iconSize: 18,
            tooltip: 'Eliminar',
          ),
      ],
    );

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

class NotificationList extends StatelessWidget {

  const NotificationList({
    required this.notifications, super.key,
    this.isLoading = false,
    this.onNotificationTap,
    this.onMarkAsRead,
    this.onDelete,
    this.onRefresh,
  });
  final List<NotificationModel> notifications;
  final bool isLoading;
  final Function(NotificationModel)? onNotificationTap;
  final Function(NotificationModel)? onMarkAsRead;
  final Function(NotificationModel)? onDelete;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hay notificaciones',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationItem(
            notification: notification,
            onTap: () => onNotificationTap?.call(notification),
            onMarkAsRead: () => onMarkAsRead?.call(notification),
            onDelete: () => onDelete?.call(notification),
          );
        },
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<NotificationModel>('notifications', notifications));
    properties.add(DiagnosticsProperty<bool>('isLoading', isLoading));
    properties.add(ObjectFlagProperty<Function(NotificationModel p1)?>.has('onNotificationTap', onNotificationTap));
    properties.add(ObjectFlagProperty<Function(NotificationModel p1)?>.has('onMarkAsRead', onMarkAsRead));
    properties.add(ObjectFlagProperty<Function(NotificationModel p1)?>.has('onDelete', onDelete));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onRefresh', onRefresh));
  }
}