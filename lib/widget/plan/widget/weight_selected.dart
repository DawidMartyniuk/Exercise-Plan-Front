import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeightSelected extends ConsumerWidget {
  const WeightSelected({super.key});

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
           'Wybierz jednostkę wagi',
           style: Theme.of(context).textTheme.titleLarge?.copyWith(
             fontWeight: FontWeight.bold,
           ),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.fitness_center),
          title: const Text("Kilogramy (kg)"),
          trailing: const Icon(Icons.check, color: Colors.green), // ✅ AKTUALNIE WYBRANY
          onTap: () {
            print("Kilogramy selected"); // DEBUG
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.fitness_center),
          title: const Text("Funt (lbs)"),
          onTap: () {
            print("Funt (lbs) selected"); // DEBUG
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}


