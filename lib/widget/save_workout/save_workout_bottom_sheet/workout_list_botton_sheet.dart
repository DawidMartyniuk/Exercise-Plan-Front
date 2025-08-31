import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/provider/current_workout_plan_provider.dart';
import 'package:work_plan_front/screens/exercise_info.dart';
import 'package:work_plan_front/utils/exercise_untils.dart';

class WorkoutListBottonSheet extends ConsumerWidget {
  const WorkoutListBottonSheet({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWorkout = ref.watch(currentWorkoutPlanProvider);
    final performedExercises = getPerformedExercises(currentWorkout);

    print('Liczba ćwiczeń do wyświetlenia: ${performedExercises.length}');
    for (final ex in performedExercises) {
      print(
        'Partia: ${ex.bodyPart}, ćwiczenie: ${ex.name}, liczba serii: ${ex.sets.length}',
      );
    }
    //final gifUrl = getExerciseGifUrl(currentWorkout, ex.id);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Wykonywane ćwiczenia:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...performedExercises.map((ex) {
              final gifUrl = getExerciseGifUrl(currentWorkout, ex.id);
              final exercise = currentWorkout?.exercises.firstWhereOrNull(
                (e) => int.tryParse(e.id) == int.tryParse(ex.id),
              );
              return ExpansionTile(
                leading: GestureDetector(
                  onTap:
                      exercise != null
                          ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ExerciseInfoScreen(exercise: exercise),
                              ),
                            );
                          }
                          : null,
                  child: ClipOval(
                    child:
                        gifUrl.isNotEmpty
                            ? Image.network(
                              gifUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                              alignment: Alignment.center,
                              child: const Text(
                                "brak",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                  ),
                ),
                title: Text(ex.name),
                subtitle: Text(
                  "Partia: ${ex.bodyPart}\nDodatkowe: ${ex.secondaryMuscles.join(', ')}",
                ),
                children:
                    ex.sets
                        .map(
                          (set) => ListTile(
                            title: Text(
                              "Seria: Powtórzenia: ${set.colRepMin},  Kg: ${set.kg}",
                            ),
                            trailing:
                                set.isChecked
                                    ? Icon(Icons.check, color: Colors.green)
                                    : Icon(Icons.close, color: Colors.red),
                          ),
                        )
                        .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
