import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class RatingInput extends StatelessWidget {

  const RatingInput({
    required this.rating, required this.onRatingChanged, super.key,
    this.size = 32,
    this.enabled = true,
    this.activeColor,
    this.inactiveColor,
    this.label,
  });
  final int rating;
  final Function(int) onRatingChanged;
  final double size;
  final bool enabled;
  final Color? activeColor;
  final Color? inactiveColor;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeStarColor = activeColor ?? Colors.amber;
    final inactiveStarColor = inactiveColor ?? theme.colorScheme.outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            final isActive = starIndex <= rating;
            
            return GestureDetector(
              onTap: enabled ? () => onRatingChanged(starIndex) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isActive ? Icons.star : Icons.star_border,
                    size: size,
                    color: isActive ? activeStarColor : inactiveStarColor,
                  ),
                ),
              ),
            );
          }),
        ),
        if (enabled) ...[
          const SizedBox(height: 8),
          Text(
            _getRatingText(rating),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Muy malo';
      case 2:
        return 'Malo';
      case 3:
        return 'Regular';
      case 4:
        return 'Bueno';
      case 5:
        return 'Excelente';
      default:
        return '';
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('rating', rating));
    properties.add(ObjectFlagProperty<Function(int p1)>.has('onRatingChanged', onRatingChanged));
    properties.add(DoubleProperty('size', size));
    properties.add(DiagnosticsProperty<bool>('enabled', enabled));
    properties.add(ColorProperty('activeColor', activeColor));
    properties.add(ColorProperty('inactiveColor', inactiveColor));
    properties.add(StringProperty('label', label));
  }
}

class RatingDisplay extends StatelessWidget {

  const RatingDisplay({
    required this.rating, super.key,
    this.totalReviews,
    this.size = 16,
    this.showText = true,
    this.activeColor,
    this.inactiveColor,
    this.textStyle,
  });
  final double rating;
  final int? totalReviews;
  final double size;
  final bool showText;
  final Color? activeColor;
  final Color? inactiveColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeStarColor = activeColor ?? Colors.amber;
    final inactiveStarColor = inactiveColor ?? theme.colorScheme.outline;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final starIndex = index + 1;
          final difference = rating - (starIndex - 1);
          
          Widget star;
          if (difference >= 1) {
            // Estrella completa
            star = Icon(
              Icons.star,
              size: size,
              color: activeStarColor,
            );
          } else if (difference > 0) {
            // Estrella parcial
            star = Stack(
              children: [
                Icon(
                  Icons.star_border,
                  size: size,
                  color: inactiveStarColor,
                ),
                ClipRect(
                  clipper: _PartialStarClipper(difference),
                  child: Icon(
                    Icons.star,
                    size: size,
                    color: activeStarColor,
                  ),
                ),
              ],
            );
          } else {
            // Estrella vacía
            star = Icon(
              Icons.star_border,
              size: size,
              color: inactiveStarColor,
            );
          }
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: star,
          );
        }),
        if (showText) ...[
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: textStyle ?? theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (totalReviews != null) ...[
            Text(
              ' ($totalReviews)',
              style: textStyle ?? theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('rating', rating));
    properties.add(IntProperty('totalReviews', totalReviews));
    properties.add(DoubleProperty('size', size));
    properties.add(DiagnosticsProperty<bool>('showText', showText));
    properties.add(ColorProperty('activeColor', activeColor));
    properties.add(ColorProperty('inactiveColor', inactiveColor));
    properties.add(DiagnosticsProperty<TextStyle?>('textStyle', textStyle));
  }
}

class _PartialStarClipper extends CustomClipper<Rect> {

  _PartialStarClipper(this.percentage);
  final double percentage;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * percentage, size.height);

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => oldClipper is _PartialStarClipper && oldClipper.percentage != percentage;
}

class RatingBar extends StatelessWidget {

  const RatingBar({
    required this.rating, required this.count, required this.totalReviews, super.key,
    this.color,
    this.height = 8,
  });
  final int rating;
  final int count;
  final int totalReviews;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = totalReviews > 0 ? count / totalReviews : 0.0;
    final barColor = color ?? theme.colorScheme.primary;

    return Row(
      children: [
        Text(
          '$rating',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.star,
          size: 16,
          color: Colors.amber,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('rating', rating));
    properties.add(IntProperty('count', count));
    properties.add(IntProperty('totalReviews', totalReviews));
    properties.add(ColorProperty('color', color));
    properties.add(DoubleProperty('height', height));
  }
}