import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserBadgeWidget extends StatelessWidget {
  final UserBadge badge;
  final double size;
  final bool showLabel;

  const UserBadgeWidget({
    super.key,
    required this.badge,
    this.size = 24.0,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final badgeInfo = _getBadgeInfo(badge);
    
    if (showLabel) {
      return Tooltip(
        message: badgeInfo.description,
        child: Chip(
          avatar: Icon(
            badgeInfo.icon,
            size: size * 0.7,
            color: badgeInfo.color,
          ),
          label: Text(
            badgeInfo.label,
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: badgeInfo.color.withOpacity(0.1),
          side: BorderSide(
            color: badgeInfo.color.withOpacity(0.3),
            width: 1,
          ),
        ),
      );
    }

    return Tooltip(
      message: '${badgeInfo.label}\n${badgeInfo.description}',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: badgeInfo.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: badgeInfo.color.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          badgeInfo.icon,
          size: size * 0.6,
          color: Colors.white,
        ),
      ),
    );
  }

  _BadgeInfo _getBadgeInfo(UserBadge badge) {
    switch (badge) {
      case UserBadge.verified:
        return _BadgeInfo(
          icon: Icons.verified,
          color: Colors.blue,
          label: 'Verificado',
          description: 'Usuario verificado por el equipo',
        );
      case UserBadge.premium:
        return _BadgeInfo(
          icon: Icons.star,
          color: Colors.amber,
          label: 'Premium',
          description: 'Miembro premium con beneficios exclusivos',
        );
      case UserBadge.topHost:
        return _BadgeInfo(
          icon: Icons.emoji_events,
          color: Colors.orange,
          label: 'Top Host',
          description: 'Anfitrión destacado con excelente servicio',
        );
      case UserBadge.superHost:
        return _BadgeInfo(
          icon: Icons.workspace_premium,
          color: Colors.purple,
          label: 'Super Host',
          description: 'Anfitrión excepcional con alta calificación',
        );
      case UserBadge.newUser:
        return _BadgeInfo(
          icon: Icons.new_releases,
          color: Colors.green,
          label: 'Nuevo',
          description: 'Nuevo miembro de la comunidad',
        );
      case UserBadge.frequentGuest:
        return _BadgeInfo(
          icon: Icons.repeat,
          color: Colors.teal,
          label: 'Huésped Frecuente',
          description: 'Usuario activo con múltiples reservas',
        );
      case UserBadge.earlyAdopter:
        return _BadgeInfo(
          icon: Icons.rocket_launch,
          color: Colors.indigo,
          label: 'Early Adopter',
          description: 'Uno de los primeros usuarios de la plataforma',
        );
      case UserBadge.musicExpert:
        return _BadgeInfo(
          icon: Icons.music_note,
          color: Colors.red,
          label: 'Experto Musical',
          description: 'Conocedor experto en música y estudios',
        );
      case UserBadge.studioOwner:
        return _BadgeInfo(
          icon: Icons.home_work,
          color: Colors.brown,
          label: 'Propietario',
          description: 'Propietario de estudio de grabación',
        );
    }
  }
}

class UserBadgesList extends StatelessWidget {
  final List<UserBadge> badges;
  final double badgeSize;
  final bool showLabels;
  final int maxVisible;
  final MainAxisAlignment alignment;

  const UserBadgesList({
    super.key,
    required this.badges,
    this.badgeSize = 24.0,
    this.showLabels = false,
    this.maxVisible = 3,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) return const SizedBox.shrink();

    final visibleBadges = badges.take(maxVisible).toList();
    final hiddenCount = badges.length - maxVisible;

    return Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      alignment: WrapAlignment.start,
      children: [
        ...visibleBadges.map((badge) => UserBadgeWidget(
          badge: badge,
          size: badgeSize,
          showLabel: showLabels,
        )),
        if (hiddenCount > 0)
          Container(
            width: badgeSize,
            height: badgeSize,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '+$hiddenCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: badgeSize * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class UserStatusIndicator extends StatelessWidget {
  final UserStatus status;
  final double size;
  final bool showLabel;

  const UserStatusIndicator({
    super.key,
    required this.status,
    this.size = 12.0,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(status);
    
    if (showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: statusInfo.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            statusInfo.label,
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w500,
              color: statusInfo.color,
            ),
          ),
        ],
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: statusInfo.color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
    );
  }

  _StatusInfo _getStatusInfo(UserStatus status) {
    switch (status) {
      case UserStatus.online:
        return _StatusInfo(
          color: Colors.green,
          label: 'En línea',
        );
      case UserStatus.offline:
        return _StatusInfo(
          color: Colors.grey,
          label: 'Desconectado',
        );
      case UserStatus.away:
        return _StatusInfo(
          color: Colors.orange,
          label: 'Ausente',
        );
      case UserStatus.busy:
        return _StatusInfo(
          color: Colors.red,
          label: 'Ocupado',
        );
      case UserStatus.invisible:
        return _StatusInfo(
          color: Colors.grey.shade300,
          label: 'Invisible',
        );
    }
  }
}

class UserRatingWidget extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double starSize;
  final bool showReviewCount;

  const UserRatingWidget({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.starSize = 16.0,
    this.showReviewCount = true,
  });

  @override
  Widget build(BuildContext context) {
    if (rating == 0.0 && reviewCount == 0) {
      return Text(
        'Sin calificaciones',
        style: TextStyle(
          fontSize: starSize,
          color: Colors.grey.shade600,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: starSize,
          color: Colors.amber,
        ),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: starSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (showReviewCount && reviewCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: starSize * 0.8,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }
}

class _BadgeInfo {
  final IconData icon;
  final Color color;
  final String label;
  final String description;

  const _BadgeInfo({
    required this.icon,
    required this.color,
    required this.label,
    required this.description,
  });
}

class _StatusInfo {
  final Color color;
  final String label;

  const _StatusInfo({
    required this.color,
    required this.label,
  });
}