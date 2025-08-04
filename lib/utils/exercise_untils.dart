import 'package:work_plan_front/model/CurrentWorkout.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:collection/collection.dart';

class PerformedExercise {
  final String id;
  final String name;
  final String bodyPart;
  final String notes;
  final List<String> secondaryMuscles;
  final List<ExerciseSet> sets;
  PerformedExercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.notes,
    required this.secondaryMuscles,
    required this.sets,
  });
}

class ExerciseSet {
  final int step;
  final int rep;
  final int kg;
  final bool isChecked;
  final bool
  isFailure; // Dodane pole do oznaczania, czy ćwiczenie było do upadku

  ExerciseSet({
    required this.step,
    required this.rep,
    required this.kg,
    required this.isChecked,
    required this.isFailure,
  });
}

List<PerformedExercise> getPerformedExercises(Currentworkout? currentWorkout) {
  final result = <PerformedExercise>[];
  final currentPlan = currentWorkout?.plan;
  final currentExercises = currentWorkout?.exercises ?? [];
  
  if (currentPlan != null) {
    print('currentPlan.rows: ${currentPlan.rows.length}');
    
    for (final rowData in currentPlan.rows) {
      print('rowData.exercise_number: ${rowData.exercise_number}');
      print('rowData.exercise_name: ${rowData.exercise_name}');
      
      // ✅ NAPRAW MAPOWANIE - użyj exercise_name zamiast exercise_number
      Exercise? exercise = currentExercises.firstWhereOrNull((ex) {
        print('Porównuję ex.name: "${ex.name}" z rowData.exercise_name: "${rowData.exercise_name}"');
        return ex.name.toLowerCase().trim() == rowData.exercise_name.toLowerCase().trim();
      });
      
      // ✅ FALLBACK - jeśli nie znajdzie po nazwie, spróbuj po exercise_number jako string
      if (exercise == null) {
        exercise = currentExercises.firstWhereOrNull((ex) {
          print('FALLBACK: Porównuję ex.exerciseId: "${ex.exerciseId}" z rowData.exercise_number: "${rowData.exercise_number}"');
          return ex.exerciseId == rowData.exercise_number;
        });
      }
      
      print('exercise znaleziony: ${exercise?.name}');
      
      if (exercise != null) {
        final sets = rowData.data.where((row) => row.isChecked).map((row) {
          print('getPerformedExercises: $row');
          return ExerciseSet(
            step: row.colStep,
            rep: row.colRep,
            kg: row.colKg,
            isChecked: row.isChecked,
            isFailure: row.isFailure,
          );
        }).toList();

        print('sets.length: ${sets.length}');

        if (sets.isNotEmpty) {
          result.add(
            PerformedExercise(
              id: exercise.exerciseId, // ✅ UŻYJ exerciseId zamiast int.tryParse
              name: exercise.name,
              notes: rowData.notes,
              bodyPart: exercise.bodyPart,
              secondaryMuscles: exercise.secondaryMuscles,
              sets: sets,
            ),
          );
        }
      } else {
        print('❌ Nie znaleziono ćwiczenia dla: "${rowData.exercise_name}" / "${rowData.exercise_number}"');
      }
    }
  }
  
  print('Zwracam ćwiczeń: ${result.length}');
  for (final ex in result) {
    print('✅ Exercise: ${ex.name} (ID: ${ex.id}), sets: ${ex.sets.length}');
    for (final set in ex.sets) {
      print('  - Set: step=${set.step}, kg=${set.kg}, reps=${set.rep}, isFailure=${set.isFailure}');
    }
  }
  
  return result;
}


/// Zwraca gifUrl dla danego exerciseNumber (lub id) na podstawie currentWorkout.
/// Jeśli nie znajdzie, zwraca pusty string.

String getExerciseGifUrl(
  Currentworkout? currentWorkout,
  String exerciseNumber,
) {
  if (currentWorkout == null) return '';
  final exercise = currentWorkout.exercises.firstWhereOrNull(
    (ex) => int.tryParse(ex.id) == int.tryParse(exerciseNumber),
  );
  return exercise?.gifUrl ?? '';
}
