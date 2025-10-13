import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:salas_beats/models/user_model.dart';
import 'package:salas_beats/utils/helpers.dart';

class UserCard extends StatelessWidget {

  const UserCard({
    required this.user, super.key,
    this.onTap,
    this.trailing,
    this.showStatus = true,
    this.showLastSeen = false,
    this.showRating = false,
    this.compact = false,
    this.margin,
    this.padding,
  });
  final UserModel user;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showStatus;
  final bool showLastSeen;
  final bool showRating;
  final bool compact;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<UserModel>('user', user))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap))
      ..add(DiagnosticsProperty<Widget?>('trailing', trailing))
      ..add(DiagnosticsProperty<bool>('showStatus', showStatus))
      ..add(DiagnosticsProperty<bool>('showLastSeen', showLastSeen))
      ..add(DiagnosticsProperty<bool>('showRating', showRating))
      ..add(DiagnosticsProperty<bool>('compact', compact))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry?>('margin', margin))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry?>('padding', padding));
  }

  @override
  Widget build(BuildContext context) => Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: compact ? _buildCompactLayout(context) : _buildFullLayout(context),
        ),
      ),
    );

  Widget _buildCompactLayout(BuildContext context) => Row(
      children: [
        _buildAvatar(context, size: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // TODO: Implementar lastSeen en UserModel
              // if (showLastSeen && user.lastSeen != null)
              //   Text(
              //     'Última vez: ${AppDateUtils.formatRelativeTime(user.lastSeen!)}',
              //     style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //       color: Colors.grey[600],
              //     ),
              //   ),
            ],
          ),
        ),
        if (showStatus) _buildStatusIndicator(context),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );

  Widget _buildFullLayout(BuildContext context) => Column(
      children: [
        Row(
          children: [
            _buildAvatar(context),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.displayName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (showStatus) _buildStatusIndicator(context),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (user.email.isNotEmpty)
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (user.phone?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.phone ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  // TODO: Implementar lastSeen en UserModel
                  // if (showLastSeen && user.lastSeen != null) ..[
                  //   const SizedBox(height: 4),
                  //   Text(
                  //     'Última vez: ${AppDateUtils.formatRelativeTime(user.lastSeen!)}',
                  //     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  //       color: Colors.grey[500],
                  //     ),
                  //   ),
                  // ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
        if (showRating && user.rating > 0) ...[
          const SizedBox(height: 12),
          _buildRatingSection(context),
        ],
        if (user.bio.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildBioSection(context),
        ],
      ],
    );

  Widget _buildAvatar(BuildContext context, {double size = 60}) => Stack(
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundColor: Colors.grey[300],
          backgroundImage: user.photoURL?.isNotEmpty ?? false
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: user.photoURL?.isEmpty ?? true
              ? Icon(
                  Icons.person,
                  size: size * 0.6,
                  color: Colors.grey[600],
                )
              : null,
        ),
        if (user.isVerified)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).cardColor,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.verified,
                size: size * 0.25,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );

  Widget _buildStatusIndicator(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (user.status) {
      case 'online':
        statusColor = Colors.green;
        statusText = 'En línea';
        statusIcon = Icons.circle;
        break;
      case 'away':
        statusColor = Colors.orange;
        statusText = 'Ausente';
        statusIcon = Icons.circle;
        break;
      case 'busy':
        statusColor = Colors.red;
        statusText = 'Ocupado';
        statusIcon = Icons.do_not_disturb;
        break;
      case 'offline':
      default:
        statusColor = Colors.grey;
        statusText = 'Desconectado';
        statusIcon = Icons.circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 12,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) => Row(
      children: [
        Icon(
          Icons.star,
          size: 16,
          color: Colors.amber[600],
        ),
        const SizedBox(width: 4),
        Text(
          user.rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${user.reviewCount} reseñas)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        if (user.badges.isNotEmpty)
          Wrap(
            spacing: 4,
            children: user.badges.take(3).map((badge) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),).toList(),
          ),
      ],
    );

  Widget _buildBioSection(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        user.bio,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.grey[700],
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
}

// Variante compacta para listas
class CompactUserCard extends StatelessWidget {

  const CompactUserCard({
    required this.user, super.key,
    this.onTap,
    this.trailing,
    this.showStatus = true,
  });
  final UserModel user;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showStatus;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<UserModel>('user', user))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap))
      ..add(DiagnosticsProperty<Widget?>('trailing', trailing))
      ..add(DiagnosticsProperty<bool>('showStatus', showStatus));
  }

  @override
  Widget build(BuildContext context) => UserCard(
        user: user,
        onTap: onTap,
        trailing: trailing,
        showStatus: showStatus,
        compact: true,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(12),
      );
}

// Variante para chat
class ChatUserCard extends StatelessWidget {

  const ChatUserCard({
    required this.user, super.key,
    this.onTap,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
  });
  final UserModel user;
  final VoidCallback? onTap;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<UserModel>('user', user))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap))
      ..add(StringProperty('lastMessage', lastMessage))
      ..add(DiagnosticsProperty<DateTime?>('lastMessageTime', lastMessageTime))
      ..add(IntProperty('unreadCount', unreadCount))
      ..add(FlagProperty('isOnline', value: isOnline, ifTrue: 'online'));
  }

  @override
  Widget build(BuildContext context) => ListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[300],
            backgroundImage: user.photoURL?.isNotEmpty ?? false
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: user.photoURL?.isEmpty ?? true
                ? Icon(
                    Icons.person,
                    color: Colors.grey[600],
                  )
                : null,
          ),
          if (isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).cardColor,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        user.displayName,
        style: TextStyle(
          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: lastMessage != null
          ? Text(
              lastMessage!,
              style: TextStyle(
                color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
                fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (lastMessageTime != null)
            Text(
              Helpers.formatDate(lastMessageTime!, format: 'dd/MM'),
              style: TextStyle(
                fontSize: 12,
                color: unreadCount > 0 ? Theme.of(context).primaryColor : Colors.grey[600],
                fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          if (unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
}
