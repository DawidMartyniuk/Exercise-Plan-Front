import 'package:flutter/material.dart';

class KeyboardDismisser extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const KeyboardDismisser({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: child,
    );
  }
}