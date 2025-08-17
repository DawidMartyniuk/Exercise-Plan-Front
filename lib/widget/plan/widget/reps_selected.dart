import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RepsSelected extends ConsumerWidget {
  const RepsSelected({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [

          Center(
            child: Container(
              width: 80,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        Text(
           'Wybierz rodzaj Powtórzeń',
           style: Theme.of(context).textTheme.titleLarge?.copyWith(
             fontWeight: FontWeight.bold,
           ),
        ),
        const SizedBox(height: 16),
       GestureDetector(
          onTap: () {
            print("One Rep (4) selected"); // DEBUG
            Navigator.of(context).pop();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.green.withAlpha(51), //
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.repeat,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  "One Rep (4)",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // ✅ REPETITION INTERVAL - NIEWYBRANE (NORMALNE TŁO)
        GestureDetector(
          onTap: () {
            print("Repetition interval (3 - 5) selected"); // DEBUG
            Navigator.of(context).pop();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
                border: Border.all(
                color: Theme.of(context).colorScheme.outline.withAlpha(77),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.repeat,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  "Repetition interval (3 - 5)",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
      ],
    );
  }
}

