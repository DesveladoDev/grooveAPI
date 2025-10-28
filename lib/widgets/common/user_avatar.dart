import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:salas_beats/models/user_model.dart';
import 'package:salas_beats/utils/helpers.dart';

class UserAvatar extends StatelessWidget {

  const UserAvatar({
    super.key,
    this.user,
    this.imageUrl,
    this.name,
    this.size = 40,
    this.onTap,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.backgroundColor,
    this.textColor,
    this.fallbackIcon,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2,
  });
  final User? user;
  final String? imageUrl;
  final String? name;
  final double size;
  final VoidCallback? onTap;
  final bool showOnlineIndicator;
  final bool isOnline;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? fallbackIcon;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<User?>('user', user))
      ..add(StringProperty('imageUrl', imageUrl))
      ..add(StringProperty('name', name))
      ..add(DoubleProperty('size', size))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap))
      ..add(FlagProperty('showOnlineIndicator', value: showOnlineIndicator, ifTrue: 'showing online indicator'))
      ..add(FlagProperty('isOnline', value: isOnline, ifTrue: 'online'))
      ..add(ColorProperty('backgroundColor', backgroundColor))
      ..add(ColorProperty('textColor', textColor))
      ..add(DiagnosticsProperty<IconData?>('fallbackIcon', fallbackIcon))
      ..add(FlagProperty('showBorder', value: showBorder, ifTrue: 'showing border'))
      ..add(ColorProperty('borderColor', borderColor))
      ..add(DoubleProperty('borderWidth', borderWidth));
  }

  @override
  Widget build(BuildContext context) {
    final effectiveImageUrl = imageUrl ?? user?.photoURL;
    final effectiveName = name ?? user?.displayName ?? user?.email ?? '';
    final effectiveBackgroundColor = backgroundColor ?? 
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
    final effectiveTextColor = textColor ?? 
        Theme.of(context).colorScheme.onSurface;
    final effectiveBorderColor = borderColor ?? 
        Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: showBorder
                  ? Border.all(
                      color: effectiveBorderColor,
                      width: borderWidth,
                    )
                  : null,
            ),
            child: ClipOval(
              child: effectiveImageUrl != null && effectiveImageUrl.isNotEmpty
                  ? _buildNetworkImage(effectiveImageUrl, effectiveBackgroundColor)
                  : _buildFallbackAvatar(effectiveName, effectiveBackgroundColor, effectiveTextColor),
            ),
          ),
          if (showOnlineIndicator)
            Positioned(
              right: 0,
              bottom: 0,
              child: _buildOnlineIndicator(context),
            ),
        ],
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl, Color backgroundColor) => CachedNetworkImage(
    imageUrl: imageUrl,
    width: size,
    height: size,
    fit: BoxFit.cover,
    placeholder: (context, url) => Container(
      width: size,
      height: size,
      color: backgroundColor,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
    errorWidget: (context, url, error) => _buildFallbackAvatar(
      name ?? '',
      backgroundColor,
      Theme.of(context).colorScheme.onSurface,
    ),
  );

  Widget _buildFallbackAvatar(String name, Color backgroundColor, Color textColor) {
    final initials = _getInitials(name);
    final fontSize = size * 0.4;

    return Container(
      width: size,
      height: size,
      color: backgroundColor,
      child: Center(
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                fallbackIcon ?? Icons.person,
                color: textColor,
                size: size * 0.6,
              ),
      ),
    );
  }

  Widget _buildOnlineIndicator(BuildContext context) {
    final indicatorSize = size * 0.25;
    
    return Container(
      width: indicatorSize,
      height: indicatorSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOnline ? Colors.green : Colors.grey,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    } else {
      return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
    }
  }
}

class UserAvatarGroup extends StatelessWidget {

  const UserAvatarGroup({
    required this.users, super.key,
    this.size = 32,
    this.maxVisible = 3,
    this.onTap,
    this.overlap = 0.3,
  });
  final List<User> users;
  final double size;
  final int maxVisible;
  final VoidCallback? onTap;
  final double overlap;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<User>('users', users))
      ..add(DoubleProperty('size', size))
      ..add(IntProperty('maxVisible', maxVisible))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap))
      ..add(DoubleProperty('overlap', overlap));
  }

  @override
  Widget build(BuildContext context) {
    final visibleUsers = users.take(maxVisible).toList();
    final remainingCount = users.length - maxVisible;
    
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: _calculateWidth(),
        height: size,
        child: Stack(
          children: [
            ...visibleUsers.asMap().entries.map((entry) {
              final index = entry.key;
              final user = entry.value;
              
              return Positioned(
                left: index * size * (1 - overlap),
                child: UserAvatar(
                  user: user,
                  size: size,
                  showBorder: true,
                  borderColor: Theme.of(context).colorScheme.surface,
                ),
              );
            }),
            if (remainingCount > 0)
              Positioned(
                left: visibleUsers.length * size * (1 - overlap),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '+$remainingCount',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: size * 0.3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _calculateWidth() {
    final visibleCount = users.length > maxVisible ? maxVisible : users.length;
    final hasRemainingIndicator = users.length > maxVisible;
    
    if (visibleCount == 0) return 0;
    if (visibleCount == 1 && !hasRemainingIndicator) return size;
    
    final overlappedWidth = (visibleCount - 1) * size * (1 - overlap);
    final lastAvatarWidth = size;
    final remainingIndicatorWidth = hasRemainingIndicator ? size : 0;
    
    return overlappedWidth + lastAvatarWidth + remainingIndicatorWidth;
  }
}

class EditableUserAvatar extends StatelessWidget {

  const EditableUserAvatar({
    super.key,
    this.user,
    this.imageUrl,
    this.name,
    this.size = 80,
    this.onEditPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.editIcon,
  });
  final User? user;
  final String? imageUrl;
  final String? name;
  final double size;
  final VoidCallback? onEditPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? editIcon;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<User?>('user', user))
      ..add(StringProperty('imageUrl', imageUrl))
      ..add(StringProperty('name', name))
      ..add(DoubleProperty('size', size))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onEditPressed', onEditPressed))
      ..add(FlagProperty('isLoading', value: isLoading, ifTrue: 'loading'))
      ..add(ColorProperty('backgroundColor', backgroundColor))
      ..add(ColorProperty('textColor', textColor))
      ..add(DiagnosticsProperty<IconData?>('editIcon', editIcon));
  }

  @override
  Widget build(BuildContext context) => Stack(
      children: [
        UserAvatar(
          user: user,
          imageUrl: imageUrl,
          name: name,
          size: size,
          backgroundColor: backgroundColor,
          textColor: textColor,
        ),
        if (isLoading)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
        if (!isLoading && onEditPressed != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onEditPressed,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: Icon(
                  editIcon ?? Icons.edit,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: size * 0.15,
                ),
              ),
            ),
          ),
      ],
    );
}
