import 'package:flutter/material.dart';

enum AnimationType {
  slideLeft,
  slideRight,
  slideUp,
  slideDown,
  fadeIn,
  scaleIn,
  bounce,
}

class AnimatedField extends StatelessWidget {
  final Widget child;
  final int delayMs;
  final AnimationType animationType;
  final double slideDistance;
  final Duration? duration;
  final Curve? curve;

  const AnimatedField({
    super.key,
    required this.child,
    this.delayMs = 800,
    this.animationType = AnimationType.slideLeft,
    this.slideDistance = 50,
    this.duration,
    this.curve,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? Duration(milliseconds: delayMs),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve ?? Curves.easeOut,
      builder: (context, value, child) {
        return _buildAnimation(value);
      },
    );
  }

  Widget _buildAnimation(double value) {
    // ✅ ZABEZPIECZENIE - UPEWNIJ SIĘ ŻE VALUE JEST W ZAKRESIE 0.0-1.0
    final clampedValue = value.clamp(0.0, 1.0);
    
    switch (animationType) {
      case AnimationType.slideLeft:
        return Transform.translate(
          offset: Offset(slideDistance * (1 - clampedValue), 0),
          child: Opacity(
            opacity: clampedValue, // ✅ UŻYJ CLAMPEDVALUE
            child: child,
          ),
        );
      
      case AnimationType.slideRight:
        return Transform.translate(
          offset: Offset(-slideDistance * (1 - clampedValue), 0),
          child: Opacity(
            opacity: clampedValue, // ✅ UŻYJ CLAMPEDVALUE
            child: child,
          ),
        );
      
      case AnimationType.slideUp:
        return Transform.translate(
          offset: Offset(0, slideDistance * (1 - clampedValue)),
          child: Opacity(
            opacity: clampedValue, // ✅ UŻYJ CLAMPEDVALUE
            child: child,
          ),
        );
      
      case AnimationType.slideDown:
        return Transform.translate(
          offset: Offset(0, -slideDistance * (1 - clampedValue)),
          child: Opacity(
            opacity: clampedValue, // ✅ UŻYJ CLAMPEDVALUE
            child: child,
          ),
        );
      
      case AnimationType.fadeIn:
        return Opacity(
          opacity: clampedValue, // ✅ UŻYJ CLAMPEDVALUE
          child: child,
        );
      
      case AnimationType.scaleIn:
        return Transform.scale(
          scale: clampedValue, // ✅ UŻYJ CLAMPEDVALUE
          child: Opacity(
            opacity: clampedValue, // ✅ UŻYJ CLAMPEDVALUE
            child: child,
          ),
        );
      
      case AnimationType.bounce:
        return Transform.scale(
          scale: clampedValue, // ✅ UŻYJ CLAMPEDVALUE
          child: child,
        );
    }
  }
}