import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/reps_type.dart';
import 'package:work_plan_front/provider/reps_type_provider.dart';

class ExerciseController {
  final WidgetRef ref;
  final Function(ExerciseRow, String, int) updateRowInProvider;
  final Function(String, int) getOriginalRowData;

  ExerciseController({
    required this.ref,
    required this.updateRowInProvider,
    required this.getOriginalRowData,
  });

  void onKgChanged(ExerciseRow row, String value, String exerciseNumber, int planId) {
    if (value.isEmpty) {
      row.colKg = 0;
    } else {
      final newValue = double.tryParse(value) ?? 0;
      if (newValue >= 0) {
        row.colKg = newValue as int;
      } else {
        return;
      }
    }
    updateRowInProvider(row, exerciseNumber, planId);
  }

  void onRepChanged(ExerciseRow row, String value, String exerciseNumber, int planId) {
    final repsType = ref.read(exerciseRepsTypeProvider(exerciseNumber));

    if (value.isEmpty) {
      row.isUserModified = false;
      final originalRow = getOriginalRowData(exerciseNumber, row.colStep);
      if (originalRow != null) {
        row.colRepMin = originalRow.colRepMin;
        if (repsType == RepsType.single) {
          row.colRepMax = originalRow.colRepMax;
        }
      }
    } else {
      final newValue = int.tryParse(value) ?? 0;
      if (newValue >= 0) {
        row.isUserModified = true;
        row.colRepMin = newValue;
        if (repsType == RepsType.single) {
          row.colRepMax = newValue;
        }
      } else {
        return;
      }
    }
    updateRowInProvider(row, exerciseNumber, planId);
  }

  void onToggleRowChecked(ExerciseRow row, String exerciseNumber, int planId) {
    row.isChecked = !row.isChecked;
    row.rowColor = row.isChecked 
        ? const Color.fromARGB(255, 103, 189, 106) 
        : Colors.transparent;

    final repsType = ref.read(exerciseRepsTypeProvider(exerciseNumber));

    if (repsType == RepsType.range && !row.isUserModified && row.isChecked) {
      final originalRow = getOriginalRowData(exerciseNumber, row.colStep);
      if (originalRow != null) {
        final middleValue = ((originalRow.colRepMin + originalRow.colRepMax) ~/ 2).round();
        row.colRepMin = middleValue;
        row.isUserModified = true;
      }
    }

    updateRowInProvider(row, exerciseNumber, planId);
  }

  void onToggleRowFailure(ExerciseRow row, String exerciseNumber, int planId) {
    row.isFailure = !row.isFailure;
    updateRowInProvider(row, exerciseNumber, planId);
  }
}