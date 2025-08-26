import 'package:flutter/material.dart';

enum ButtonAnimationType {
  scale,
  bounce,
  fade,
  slideUp,
}

class AnimatedButton extends StatelessWidget {
  final List<Widget> buttons;
  final int delayMs;
  final ButtonAnimationType animationType;
  final WrapAlignment alignment;
  final double spacing;
  final double runSpacing;

  const AnimatedButton({
    Key? key,
    required this.buttons,
    this.delayMs = 1400,
    this.animationType = ButtonAnimationType.scale,
    this.alignment = WrapAlignment.center,
    this.spacing = 20,
    this.runSpacing = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: delayMs),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return _buildButtonAnimation(value);
      },
    );
  }

  Widget _buildButtonAnimation(double value) {

    final clampedValue = value.clamp(0.0, 1.0);
    
    Widget content = Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      children: buttons,
    );

    switch (animationType) {
      case ButtonAnimationType.scale:
        return Transform.scale(
          scale: clampedValue,
          child: content,
        );
      
      case ButtonAnimationType.bounce:
        return Transform.scale(
          scale: clampedValue,
          child: Opacity(
            opacity: clampedValue,
            child: content,
          ),
        );
      
      case ButtonAnimationType.fade:
        return Opacity(
          opacity: clampedValue,
          child: content,
        );
      
      case ButtonAnimationType.slideUp:
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: clampedValue,
            child: content,
          ),
        );
    }
  }
}