import 'package:work_plan_front/model/CurrentWorkout.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:collection/collection.dart';

class PerformedExercise {
  final String id;
  final String name;
  final String bodyPart;
  final List<String> secondaryMuscles;
  final List<ExerciseSet> sets;
  PerformedExercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.secondaryMuscles,
    required this.sets,
  });
}

class ExerciseSet {
  final int rep;
  final int kg;
  final bool isChecked;
  ExerciseSet({required this.rep, required this.kg, required this.isChecked});
}

List<PerformedExercise> getPerformedExercises(Currentworkout? currentWorkout) {
  final result = <PerformedExercise>[];
  final currentPlan = currentWorkout?.plan;
  final currentExercises = currentWorkout?.exercises ?? [];
  if (currentPlan != null) {
    print('currentPlan.rows: ${currentPlan.rows.length}');
    for (final rowData in currentPlan.rows) {
      print('rowData.exercise_number: ${rowData.exercise_number}');
      for (final ex in currentExercises) {
        print('Porównuję ex.id: ${ex.id} z rowData.exercise_number: ${rowData.exercise_number}');
      }
      Exercise? exercise = currentExercises.firstWhereOrNull(
        (ex) {
          final exId = int.tryParse(ex.id ?? '');
          final rowId = int.tryParse(rowData.exercise_number ?? '');
          print('exId: $exId, rowId: $rowId');
          return exId != null && rowId != null && exId == rowId;
        },
      );
      print('exercise znaleziony: ${exercise?.name}');
      if (exercise != null) {
        final sets =
            rowData.data
                .where((row) => row.isChecked)
                .map(
                  (row) => ExerciseSet(
                    rep: row.colRep,
                    kg: row.colKg,
                    isChecked: row.isChecked,
                  ),
                )
                .toList();
        print('sets.length: ${sets.length}');
        if (sets.isNotEmpty) {
          result.add(
            PerformedExercise(
              id: exercise.id,
              name: exercise.name,
              bodyPart: exercise.bodyPart,
              secondaryMuscles: exercise.secondaryMuscles,
              sets: sets,
            ),
          );
        }
      }
    }
    print('Zwracam ćwiczeń: ${result.length}');
  }
  return result;
}

/// Zwraca gifUrl dla danego exerciseNumber (lub id) na podstawie currentWorkout.
/// Jeśli nie znajdzie, zwraca pusty string.
String getExerciseGifUrl(Currentworkout? currentWorkout, String exerciseNumber) {
  if (currentWorkout == null) return '';
  final exercise = currentWorkout.exercises.firstWhereOrNull(
    (ex) => int.tryParse(ex.id) == int.tryParse(exerciseNumber),
  );
  return exercise?.gifUrl ?? '';
}
