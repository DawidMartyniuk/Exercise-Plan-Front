import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/weight_type.dart';
import 'package:work_plan_front/provider/weight_type_provider.dart';

class WeightSelected extends ConsumerWidget {
  final String exerciseId; 
  final String? exerciseName; 
  
  const WeightSelected({
    super.key,
    required this.exerciseId,
    this.exerciseName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ POBIERZ JEDNOSTKĘ WAGI DLA TEGO KONKRETNEGO ĆWICZENIA
    final currentWeightType = ref.watch(exerciseWeightTypeProvider(exerciseId));
    
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
        //  POKAŻ NAZWĘ ĆWICZENIA JEŚLI JEST DOSTĘPNA
        if (exerciseName != null) ...[
          const SizedBox(height: 8),
          Text(
            'dla: $exerciseName',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        
        // ✅ KILOGRAMY (kg)
        GestureDetector(
          onTap: () {
            print("Kilogramy (kg) selected for exercise: $exerciseId");
            // ✅ USTAW JEDNOSTKĘ DLA TEGO KONKRETNEGO ĆWICZENIA
            ref.read(exerciseWeightTypeProvider(exerciseId).notifier).state = WeightType.kg;
            Navigator.of(context).pop(WeightType.kg);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: currentWeightType == WeightType.kg 
                  ? Colors.green.withAlpha(51) 
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: currentWeightType == WeightType.kg 
                    ? Colors.green 
                    : Theme.of(context).colorScheme.outline.withAlpha(77),
                width: currentWeightType == WeightType.kg ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center,
                  color: currentWeightType == WeightType.kg 
                      ? Colors.green 
                      : Theme.of(context).colorScheme.onSurface,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  "Kilogramy (kg)",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: currentWeightType == WeightType.kg 
                        ? Colors.green 
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: currentWeightType == WeightType.kg 
                        ? FontWeight.bold 
                        : FontWeight.w500,
                  ),
                ),
                if (currentWeightType == WeightType.kg) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // ✅ FUNTY (lbs)
        GestureDetector(
          onTap: () {
            print("Funty (lbs) selected for exercise: $exerciseId");
            // ✅ USTAW JEDNOSTKĘ DLA TEGO KONKRETNEGO ĆWICZENIA
            ref.read(exerciseWeightTypeProvider(exerciseId).notifier).state = WeightType.lbs;
            Navigator.of(context).pop(WeightType.lbs);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: currentWeightType == WeightType.lbs 
                  ? Colors.green.withAlpha(51) 
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: currentWeightType == WeightType.lbs 
                    ? Colors.green 
                    : Theme.of(context).colorScheme.outline.withAlpha(77),
                width: currentWeightType == WeightType.lbs ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.scale,
                  color: currentWeightType == WeightType.lbs 
                      ? Colors.green 
                      : Theme.of(context).colorScheme.onSurface,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  "Funty (lbs)",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: currentWeightType == WeightType.lbs 
                        ? Colors.green 
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: currentWeightType == WeightType.lbs 
                        ? FontWeight.bold 
                        : FontWeight.w500,
                  ),
                ),
                if (currentWeightType == WeightType.lbs) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
      ],
    );
  }
}


