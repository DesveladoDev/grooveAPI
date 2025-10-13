import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.imageUrl,
    this.displayName,
    this.radius = 20,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2,
  });

  final String? imageUrl;
  final String? displayName;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor.withValues(alpha: 0.1),
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? CachedNetworkImageProvider(imageUrl!)
          : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Text(
              _getInitials(displayName),
              style: TextStyle(
                color: textColor ?? Theme.of(context).primaryColor,
                fontSize: radius * 0.6,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );

    if (showBorder) {
      avatar = DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? Theme.of(context).primaryColor,
            width: borderWidth,
          ),
        ),
        child: avatar,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('imageUrl', imageUrl))
      ..add(StringProperty('displayName', displayName))
      ..add(DoubleProperty('radius', radius))
      ..add(ColorProperty('backgroundColor', backgroundColor))
      ..add(ColorProperty('textColor', textColor))
      ..add(DiagnosticsProperty<VoidCallback?>('onTap', onTap))
      ..add(DiagnosticsProperty<bool>('showBorder', showBorder))
      ..add(ColorProperty('borderColor', borderColor))
      ..add(DoubleProperty('borderWidth', borderWidth));
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) {
      return '?';
    }

    final words = name.trim().split(' ');
    return words.length == 1
        ? words[0].substring(0, 1).toUpperCase()
        : '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
  }
}



class UserAvatarWithStatus extends StatelessWidget {
  const UserAvatarWithStatus({
    required this.isOnline, super.key,
    this.imageUrl,
    this.displayName,
    this.radius = 20,
    this.onlineColor = Colors.green,
    this.offlineColor = Colors.grey,
    this.onTap,
  });

  final String? imageUrl;
  final String? displayName;
  final double radius;
  final bool isOnline;
  final Color onlineColor;
  final Color offlineColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Stack(
      children: [
        UserAvatar(
          imageUrl: imageUrl,
          displayName: displayName,
          radius: radius,
          onTap: onTap,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: radius * 0.4,
            height: radius * 0.4,
            decoration: BoxDecoration(
              color: isOnline ? onlineColor : offlineColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('imageUrl', imageUrl))
      ..add(StringProperty('displayName', displayName))
      ..add(DoubleProperty('radius', radius))
      ..add(DiagnosticsProperty<bool>('isOnline', isOnline))
      ..add(ColorProperty('onlineColor', onlineColor))
      ..add(ColorProperty('offlineColor', offlineColor))
      ..add(DiagnosticsProperty<VoidCallback?>('onTap', onTap));
  }
}