import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:salas_beats/config/constants.dart';
import 'package:salas_beats/models/chat_model.dart';

class TypingIndicatorWidget extends StatefulWidget {

  const TypingIndicatorWidget({
    required this.indicators, super.key,
  });
  final List<TypingIndicator> indicators;

  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<TypingIndicator>('indicators', indicators));
  }
}

class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ),);
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (widget.indicators.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultSpacing, vertical: AppConstants.smallSpacing),
      child: Row(
        children: [
          _buildTypingBubble(theme),
          const SizedBox(width: AppConstants.smallSpacing),
          _buildTypingText(theme),
        ],
      ),
    );
  }

  Widget _buildTypingBubble(ThemeData theme) => Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.smallSpacing, vertical: AppConstants.smallSpacing),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDot(theme, 0),
          const SizedBox(width: 4),
          _buildDot(theme, 1),
          const SizedBox(width: 4),
          _buildDot(theme, 2),
        ],
      ),
    );

  Widget _buildDot(ThemeData theme, int index) => AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final delay = index * 0.2;
        final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
        final opacity = (animationValue * 2).clamp(0.0, 1.0);
        
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(opacity),
            shape: BoxShape.circle,
          ),
        );
      },
    );

  Widget _buildTypingText(ThemeData theme) {
    final names = widget.indicators.map((i) => i.userName).toList();
    String text;
    
    if (names.length == 1) {
      text = '${names.first} está escribiendo...';
    } else if (names.length == 2) {
      text = '${names.first} y ${names.last} están escribiendo...';
    } else {
      text = 'Varias personas están escribiendo...';
    }

    return Expanded(
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          fontStyle: FontStyle.italic,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class TypingDots extends StatefulWidget {

  const TypingDots({
    required this.color, super.key,
    this.size = 6.0,
  });
  final Color color;
  final double size;

  @override
  State<TypingDots> createState() => _TypingDotsState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
    properties.add(DoubleProperty('size', size));
  }
}

class _TypingDotsState extends State<TypingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    
    _animations = _controllers.map((controller) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      ),).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) => AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) => Container(
              margin: EdgeInsets.only(
                right: index < 2 ? 4 : 0,
                bottom: _animations[index].value * 4,
              ),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(
                  0.4 + (_animations[index].value * 0.6),
                ),
                shape: BoxShape.circle,
              ),
            ),
        ),),
    );
}