import 'package:flutter/material.dart';
import 'package:work_plan_front/theme/app_theme.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final bool showBackground;

  const AppBackground({
    super.key, 
    required this.child,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBackground) {
      return child;
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
        image: AssetImage('assets/background/background-1.jpg'), 
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.surface.withAlpha(200),
            BlendMode.darken,
          ),
        ),
      ),
      child: child,
    );
  }
}