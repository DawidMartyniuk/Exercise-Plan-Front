import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onRemove;
  final VoidCallback? onInfo;
  final Widget? trailing;

  const ExerciseCard({
    Key? key,
    required this.exercise,
    this.onRemove,
    this.onInfo,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header z nazwą ćwiczenia i akcjami
            Row(
              children: [
                // Ikona ćwiczenia
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Nazwa ćwiczenia
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (exercise.bodyPart.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          exercise.bodyPart,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Przyciski akcji
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onInfo != null)
                      IconButton(
                        onPressed: onInfo,
                        icon: const Icon(Icons.info_outline),
                        color: Theme.of(context).colorScheme.primary,
                        tooltip: "Informacje o ćwiczeniu",
                      ),
                    if (onRemove != null)
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: Theme.of(context).colorScheme.error,
                        tooltip: "Usuń ćwiczenie",
                      ),
                  ],
                ),
              ],
            ),
            
            // Dodatkowa zawartość (np. tabela setów)
            if (trailing != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}