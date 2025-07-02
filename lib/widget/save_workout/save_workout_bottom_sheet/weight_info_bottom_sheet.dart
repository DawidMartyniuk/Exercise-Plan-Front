import 'package:flutter/material.dart';

class WeightInfoBottomSheet extends StatelessWidget {
  const WeightInfoBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary, size: 48),
          const SizedBox(height: 16),
          Text(
            'Zmiana ciężaru będzie dostępna w przyszłej wersji.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}