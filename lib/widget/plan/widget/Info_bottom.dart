import 'package:flutter/material.dart';

class InfoBottomSheet extends StatelessWidget {
  final String textInfo;

  const InfoBottomSheet({
    super.key,
    required this.textInfo
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline, color: Theme.of(context).colorScheme.onSurface, size: 48),
          const SizedBox(height: 16),
          Text(
            textInfo,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
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