import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/training_session.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard/helper/workout_card_helpers.dart';
import 'package:work_plan_front/screens/home_dashboard/workout_info/exercise_list_item.dart';

class ExerciseListView extends ConsumerWidget with WorkoutCardHelpers {
  final TrainingSession trainingSession;

  const ExerciseListView({
    Key? key,
    required this.trainingSession,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ NAGŁÓWEK SEKCJI
        Text(
          'Exercises',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        
        // ✅ LISTA ĆWICZEŃ
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: trainingSession.exercises.length,
          itemBuilder: (context, index) {
            final exercise = trainingSession.exercises[index];
            return ExerciseListItem(
              exercise: exercise,
              exerciseName: getExerciseName(exercise.exerciseId, ref),
              exerciseImageUrl: getExerciseImage(exercise.exerciseId, ref),
            );
          },
        ),
      ],
    );
  }
}