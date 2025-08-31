import 'package:flutter/material.dart';

class BottomButtonAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onEnd;

  const BottomButtonAppBar({
    Key? key,
    required this.onBack,
    required this.onEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        ElevatedButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Powrót'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
        ),
        const SizedBox(width: 40), // widoczny odstęp między przyciskami
        ElevatedButton.icon(
          onPressed: onEnd,
          icon: const Icon(Icons.stop_circle_outlined),
          label: const Text('Koniec'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
        ),
          ],
        ),
      ),
    );
  }
}
