import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/features/workout/plan_selected/components/workout_reps_field.dart';
import 'package:work_plan_front/features/workout/plan_selected/components/workout_weight_filed.dart';

class ExerciseTableHelpers {
  static Map<String, List<ExerciseRowsData>> groupExercisesByName(
    ExerciseTable plan,
    List<dynamic> exercises,
  ) {
    final Map<String, List<ExerciseRowsData>> groupedData = {};
    
    for (final rowData in plan.rows) {
      try {
        final exerciseName = rowData.exercise_name.isNotEmpty 
            ? rowData.exercise_name 
            : 'Unknown Exercise ${rowData.exercise_number}';
        
        if (!groupedData.containsKey(exerciseName)) {
          groupedData[exerciseName] = [];
        }
        groupedData[exerciseName]!.add(rowData);
      } catch (e) {
        print('Error grouping exercise: $e');
        final fallbackName = 'Exercise ${rowData.exercise_number}';
        if (!groupedData.containsKey(fallbackName)) {
          groupedData[fallbackName] = [];
        }
        groupedData[fallbackName]!.add(rowData);
      }
    }
    
    return groupedData;
  }

  //JEDNA PROSTA METODA - UŻYWA TYLKO WorkoutWeightField I WorkoutRepsField
  static List<TableRow> buildExerciseTableRows(
    List<ExerciseRowsData> exerciseRows,
    BuildContext context, {
    Function(ExerciseRow, String, String)? onKgChanged,
    Function(ExerciseRow, String, String)? onRepChanged,
    Function(ExerciseRow, String)? onToggleChecked,
    Function(ExerciseRow, String)? onToggleFailure,
    required WidgetRef ref,
    required String Function(String, int) getOriginalRange,
    bool isReadOnly = false,
  }) {
    final List<TableRow> rows = [];

    for (final exerciseRowData in exerciseRows) {
      for (final exerciseRow in exerciseRowData.data) {
        rows.add(
          TableRow(
            decoration: BoxDecoration(
              color: _getRowColor(exerciseRow, context, isReadOnly),
            ),
            children: [
              // ✅ STEP COLUMN
              _buildStepCell(exerciseRow.colStep.toString(), context),
              
              // ✅ WEIGHT COLUMN - TYLKO WorkoutWeightField
              Container(
                child: WorkoutWeightField(
                  row: exerciseRow,
                  exerciseNumber: exerciseRowData.exercise_number,
                  onWeightChanged: (value) => onKgChanged?.call(exerciseRow, value, exerciseRowData.exercise_number),
                  isReadOnly: isReadOnly,
                ),
              ),
              
              // ✅ REPS COLUMN - TYLKO WorkoutRepsField
              Container(
                child: WorkoutRepsField(
                  row: exerciseRow,
                  exerciseNumber: exerciseRowData.exercise_number,
                  onRepChanged: (value) => onRepChanged?.call(exerciseRow, value, exerciseRowData.exercise_number),
                  getOriginalRange: getOriginalRange,
                  isReadOnly: isReadOnly,
                ),
              ),
              
              // ✅ CHECKBOX COLUMN
              if (!isReadOnly)
                _buildCheckboxCell(
                  context,
                  exerciseRow,
                  exerciseRowData.exercise_number,
                  onToggleChecked!,
                  onToggleFailure,
                ),
            ],
          ),
        );
      }
    }

    return rows;
  }

  // ✅ PODSTAWOWE HELPER METODY
static Widget _buildStepCell(String step, BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(8.0),
    // ✅ DODAJ HEIGHT ŻEBY WYRÓWNAĆ Z INNYMI POLAMI
    height: 48, // ✅ TAKA SAMA WYSOKOŚĆ JAK WorkoutWeightField
    child: Center( // ✅ WYŚRODKUJ ZAWARTOŚĆ
      child: Text(
        step,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

  static Color _getRowColor(ExerciseRow row, BuildContext context, [bool isReadOnly = false]) {
    if (isReadOnly) {
      return Colors.transparent;
    }
    if (row.isFailure) {
      return const Color.fromARGB(255, 139, 69, 19); 
    } else if (row.isChecked) {
      return const Color.fromARGB(255, 12, 107, 15);
    }
    return Colors.transparent;
  }

  static Widget _buildCheckboxCell(
    BuildContext context,
    ExerciseRow row,
    String exerciseNumber,
    Function(ExerciseRow, String) onToggleChecked,
    Function(ExerciseRow, String)? onToggleFailure,
  ) {
    return GestureDetector(
      onDoubleTap: onToggleFailure != null 
          ? () => onToggleFailure(row, exerciseNumber)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Checkbox(
          value: row.isChecked,
          onChanged: (value) => onToggleChecked(row, exerciseNumber),
          activeColor: Theme.of(context).colorScheme.primary,
          checkColor: Theme.of(context).colorScheme.onSurface,
          side: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  static Widget buildHeaderCell(BuildContext context, String text) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  static int calculateTotalSteps(ExerciseTable plan) {
    return plan.rows.fold(0, (sum, rowData) => sum + rowData.data.length);
  }

  static int calculateCurrentStep(ExerciseTable plan) {
    return plan.rows.fold(0, (sum, rowData) {
      return sum + rowData.data.where((row) => row.isChecked).length;
    });
  }
}
