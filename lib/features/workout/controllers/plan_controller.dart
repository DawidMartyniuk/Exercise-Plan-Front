import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/model/reps_type.dart';
import 'package:work_plan_front/features/exercise/screens/exercises.dart';

class PlanController {
  final WidgetRef ref;
  final BuildContext context;
  final VoidCallback? onStateChanged;

  PlanController({
    required this.ref,
    required this.context,
    this.onStateChanged,
  });

  Future<void> addMultipleExercisesToPlan(ExerciseTable workingPlan) async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (ctx) => ExercisesScreen(
          isSelectionMode: true,
          title: 'Select Exercises for Plan',
          onMultipleExercisesSelected: (exercises) {
            print('🔧 Callback wywołany z ${exercises.length} ćwiczeniami');
          },
        ),
      ),
    );

    if (result != null) {
      if (result is List<Exercise>) {
        _handleMultipleExercises(result, workingPlan);
      } else if (result is Exercise) {
        _handleSingleExercise(result, workingPlan);
      }
    }
  }

  void _handleMultipleExercises(List<Exercise> exercises, ExerciseTable workingPlan) {
    int addedCount = 0;
    
    for (final exercise in exercises) {
      if (_addExerciseToWorkingPlan(exercise, workingPlan)) {
        addedCount++;
      }
    }

    _showAddResultMessage(addedCount, exercises.length);
    onStateChanged?.call();
  }

  void _handleSingleExercise(Exercise exercise, ExerciseTable workingPlan) {
    if (_addExerciseToWorkingPlan(exercise, workingPlan)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${exercise.name} to plan'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${exercise.name} already exists in plan'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    onStateChanged?.call();
  }

  bool _addExerciseToWorkingPlan(Exercise exercise, ExerciseTable workingPlan) {
    final exerciseExists = workingPlan.rows.any(
      (rowData) => rowData.exercise_number == exercise.id,
    );

    if (!exerciseExists) {
      final newRow = ExerciseRowsData(
        exercise_number: exercise.id,
        exercise_name: exercise.name,
        notes: '',
        rep_type: RepsType.single,
        data: [
          ExerciseRow(
            colStep: 1,
            colKg: 0,
            colRepMin: 0,
            colRepMax: 0,
            isChecked: false,
            isFailure: false,
            rowColor: Colors.transparent,
            isUserModified: false,
          ),
        ],
      );
      workingPlan.rows.add(newRow);
      return true;
    }
    return false;
  }

  void _showAddResultMessage(int addedCount, int totalCount) {
    if (addedCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added $addedCount exercise${addedCount > 1 ? 's' : ''} to plan',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All selected exercises already exist in plan'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void deleteExerciseFromPlan(ExerciseTable workingPlan, String exerciseNumber) {
    workingPlan.rows.removeWhere(
      (rowData) => rowData.exercise_number == exerciseNumber,
    );
    onStateChanged?.call();
  }

  void addNewSet(ExerciseTable workingPlan, String exerciseNumber) {
    final exerciseIndex = workingPlan.rows.indexWhere(
      (rowData) => rowData.exercise_number == exerciseNumber,
    );

    if (exerciseIndex != -1) {
      final exerciseData = workingPlan.rows[exerciseIndex];
      final newStepNumber = exerciseData.data.length + 1;
      final lastSet = exerciseData.data.isNotEmpty ? exerciseData.data.last : null;

      final newSet = ExerciseRow(
        colStep: newStepNumber,
        colKg: lastSet?.colKg ?? 0,
        colRepMin: lastSet?.colRepMin ?? 0,
        colRepMax: lastSet?.colRepMax ?? 0,
        isChecked: false,
        isFailure: false,
        rowColor: Colors.transparent,
        isUserModified: false,
      );

      workingPlan.rows[exerciseIndex].data.add(newSet);
      onStateChanged?.call();
    }
  }

  void removeLastSet(ExerciseTable workingPlan, String exerciseNumber) {
    final exerciseIndex = workingPlan.rows.indexWhere(
      (rowData) => rowData.exercise_number == exerciseNumber,
    );

    if (exerciseIndex != -1) {
      final exerciseData = workingPlan.rows[exerciseIndex];
      
      if (exerciseData.data.length > 1) {
        exerciseData.data.removeLast();
        
        // Przenumeruj serie
        for (int i = 0; i < exerciseData.data.length; i++) {
          exerciseData.data[i].colStep = i + 1;
        }
        
        onStateChanged?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed last set'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }
}