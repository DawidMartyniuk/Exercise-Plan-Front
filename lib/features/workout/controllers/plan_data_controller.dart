import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/reps_type.dart';
import 'package:work_plan_front/provider/workout_plan_state_provider.dart';
import 'package:work_plan_front/provider/reps_type_provider.dart';

class PlanDataController {
  final WidgetRef ref;

  PlanDataController({required this.ref});

  ExerciseTable createDeepCopyOfPlan(ExerciseTable plan) {
    return ExerciseTable(
      id: plan.id,
      exercise_table: plan.exercise_table,
      rows: plan.rows.map((row) => ExerciseRowsData(
        exercise_number: row.exercise_number,
        exercise_name: row.exercise_name,
        notes: row.notes,
        rep_type: row.rep_type,
        data: row.data.map((exerciseRow) => ExerciseRow(
          colStep: exerciseRow.colStep,
          colKg: exerciseRow.colKg,
          colRepMin: exerciseRow.colRepMin,
          colRepMax: exerciseRow.colRepMax,
          isChecked: exerciseRow.isChecked,
          isFailure: exerciseRow.isFailure,
          rowColor: exerciseRow.rowColor,
          isUserModified: false,
        )).toList(),
      )).toList(),
    );
  }

  void initializePlanData(ExerciseTable workingPlan) {
    final planId = workingPlan.id;
    final savedRows = ref.read(workoutPlanStateProvider).getRows(planId);

    // Ustaw domyślne wagi
    for (final exerciseData in workingPlan.rows) {
      for (final row in exerciseData.data) {
        if (row.colKg == 0) {
          row.colKg = 20;
        }
      }
    }

    // Ustaw typy powtórzeń
    Future(() {
      for (final rowData in workingPlan.rows) {
        final hasRange = rowData.data.any((row) =>
            row.colRepMin > 0 &&
            row.colRepMax > 0 &&
            row.colRepMin != row.colRepMax);

        ref.read(exerciseRepsTypeProvider(rowData.exercise_number).notifier)
            .state = hasRange ? RepsType.range : RepsType.single;
      }
    });

    if (savedRows.isNotEmpty) {
      _applyUserProgress(workingPlan, savedRows);
    }
  }

  void _applyUserProgress(ExerciseTable workingPlan, List<ExerciseRowState> savedRows) {
    for (final rowData in workingPlan.rows) {
      for (final row in rowData.data) {
        final match = savedRows.firstWhereOrNull((e) =>
            e.colStep == row.colStep &&
            e.exerciseNumber == rowData.exercise_number);

        if (match != null) {
          row.colKg = match.colKg;
          row.colRepMin = match.colRepMin;
          row.colRepMax = match.colRepMax;
          row.isChecked = match.isChecked;
          row.isFailure = match.isFailure;
        }

        row.rowColor = row.isChecked ? Colors.green : Colors.transparent;
      }
    }
  }

  ExerciseRow? getOriginalRowData(ExerciseTable originalPlan, String exerciseNumber, int colStep) {
    for (final rowData in originalPlan.rows) {
      if (rowData.exercise_number == exerciseNumber) {
        for (final row in rowData.data) {
          if (row.colStep == colStep) {
            return row;
          }
        }
      }
    }
    return null;
  }

  String getOriginalRange(ExerciseTable originalPlan, String exerciseNumber, int colStep) {
    final originalRow = getOriginalRowData(originalPlan, exerciseNumber, colStep);
    if (originalRow != null && originalRow.colRepMin != originalRow.colRepMax) {
      return "${originalRow.colRepMin} - ${originalRow.colRepMax}";
    }
    return "0";
  }
}