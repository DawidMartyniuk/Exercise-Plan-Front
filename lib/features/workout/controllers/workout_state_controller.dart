import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/current_workout.dart';
import 'package:work_plan_front/provider/workout_plan_state_provider.dart';
import 'package:work_plan_front/provider/current_workout_plan_provider.dart';

class WorkoutStateController {
  final WidgetRef ref;

  WorkoutStateController({required this.ref});

  void saveAllRowsToProvider(ExerciseTable workingPlan) {
    final planId = workingPlan.id;
    final rowStates = <ExerciseRowState>[];

    for (final rowData in workingPlan.rows) {
      for (final row in rowData.data) {
        rowStates.add(
          ExerciseRowState(
            colStep: row.colStep,
            colKg: row.colKg,
            colRepMin: row.colRepMin,
            colRepMax: row.colRepMax,
            isChecked: row.isChecked,
            isFailure: row.isFailure,
            exerciseNumber: rowData.exercise_number,
          ),
        );
      }
    }

    ref.read(workoutPlanStateProvider.notifier).setPlanRows(planId, rowStates);
  }

  void updateRowInProvider(ExerciseRow row, String exerciseNumber, int planId) {
    ref.read(workoutPlanStateProvider.notifier).updateRow(
      planId,
      ExerciseRowState(
        colStep: row.colStep,
        colKg: row.colKg,
        colRepMin: row.colRepMin,
        colRepMax: row.colRepMax,
        isChecked: row.isChecked,
        isFailure: row.isFailure,
        exerciseNumber: exerciseNumber,
      ),
    );
  }

  void updateCurrentWorkoutPlan(ExerciseTable workingPlan, List<Exercise> exercises) {
    final newRows = workingPlan.rows.map((rowData) => 
      rowData.copyWithData(
        rowData.data.map((row) => ExerciseRow(
          colStep: row.colStep,
          colKg: row.colKg,
          colRepMin: row.colRepMin,
          colRepMax: row.colRepMax,
          isChecked: row.isChecked,
          isFailure: row.isFailure,
          rowColor: row.rowColor,
        )).toList(),
      ),
    ).toList();

    final newPlan = workingPlan.copyWithRows(newRows);
    ref.read(currentWorkoutPlanProvider.notifier).state = Currentworkout(
      plan: newPlan,
      exercises: exercises,
    );
  }

  void removeExerciseFromWorkoutState(int planId, String exerciseNumber) {
    ref.read(workoutPlanStateProvider.notifier).removeExercise(planId, exerciseNumber);
  }
}