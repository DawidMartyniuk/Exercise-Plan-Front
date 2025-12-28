import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/features/exercise/exercise_info/widget/exercise_image.dart';
import 'package:work_plan_front/features/exercise/exercise_info/widget/exercise_info_card.dart';

class InfoTab extends StatelessWidget {
  const InfoTab({super.key, required this.exercise});
  
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ✅ DUŻY OBRAZEK ĆWICZENIA
          ExerciseImageWidget(
            imageUrl: exercise.gifUrl ?? '',
            height: 300,
            isLarge: true,
          ),

          const SizedBox(height: 24),

          // ✅ NAZWA ĆWICZENIA
          Text(
            exercise.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // ✅ INFORMACJE W KARCIE
          ExerciseInfoCard(exercise: exercise),
        ],
      ),
    );
  }
}