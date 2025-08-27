import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise_plan.dart';

class ExerciseTableHelpers {
  // ✅ POPRAWKA - Grupowanie według exercise_number zamiast nazwy
  static Map<String, List<ExerciseRowsData>> groupExercisesByName(
    ExerciseTable plan,
    List<dynamic> exercises,
  ) {
    final Map<String, List<ExerciseRowsData>> groupedData = {};
    
    for (final rowData in plan.rows) {
      try {
        // ✅ UŻYJ BEZPOŚREDNIO exercise_name z rowData
        final exerciseName = rowData.exercise_name.isNotEmpty 
            ? rowData.exercise_name 
            : 'Unknown Exercise ${rowData.exercise_number}';
        
        if (!groupedData.containsKey(exerciseName)) {
          groupedData[exerciseName] = [];
        }
        groupedData[exerciseName]!.add(rowData);
      } catch (e) {
        print('Error grouping exercise: $e');
        // ✅ FALLBACK - dodaj z domyślną nazwą
        final fallbackName = 'Exercise ${rowData.exercise_number}';
        if (!groupedData.containsKey(fallbackName)) {
          groupedData[fallbackName] = [];
        }
        groupedData[fallbackName]!.add(rowData);
      }
    }
    
    print('🔍 Grouped data: ${groupedData.keys.toList()}'); // DEBUG
    return groupedData;
  }

  // ✅ POPRAWKA - Zmień parametry funkcji callback
  static List<TableRow> buildExerciseTableRows(
    List<ExerciseRowsData> exerciseRows,
    BuildContext context, {
    required Function(ExerciseRow, String, String) onKgChanged,  // ✅ DODAJ exerciseNumber
    required Function(ExerciseRow, String, String) onRepChanged, // ✅ DODAJ exerciseNumber
    required Function(ExerciseRow, String) onToggleChecked,
    required Function(ExerciseRow, String)? onToggleFailure,
  }) {
    final List<TableRow> rows = [];
    
    for (final exerciseRowsData in exerciseRows) {
      for (final row in exerciseRowsData.data) {
        rows.add(
          TableRow(
            decoration: BoxDecoration(
              color: _getRowColor(row, context), // ✅ UŻYWA TWOICH KOLORÓW
            ),
            children: [
              // Step
              _buildStepCell(row.colStep.toString(), context),

              // Weight
              _buildEditableCell(
                context,
                row.colKg.toString(),
                "weight",
                (value) => onKgChanged(row, value, exerciseRowsData.exercise_number), // ✅ POPRAWKA
              ),
              
              // Reps
              _buildEditableCell(
                context,
                row.colRepMin.toString(),
                "reps",
                (value) => onRepChanged(row, value, exerciseRowsData.exercise_number), // ✅ POPRAWKA
              ),
              
              // ✅ PRZYWRÓĆ CHECKBOX - BEZ ZMIANY KOLORÓW
              _buildCheckboxCell(
                context,
                row,
                exerciseRowsData.exercise_number,
                onToggleChecked,
                onToggleFailure,
              ),
            ],
          ),
        );
      }
    }
    
    return rows;
  }

  // ✅ POPRAWIONE KOLORY - bez zmiany dla failure
  static Color _getRowColor(ExerciseRow row, BuildContext context) {
    if (row.isFailure) {
      return  const Color.fromARGB(255, 0, 112, 4); // ✅ CIEMNY BRĄZ dla failure
    } else if (row.isChecked) {
      return const Color.fromARGB(255, 12, 107, 15); // ✅ CIEMNO ZIELONY dla checked
    }
    return Colors.transparent;
  }

  static Widget _buildStepCell(String step, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        step,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  static Widget _buildEditableCell(
    BuildContext context,
    String value,
    String type,
    Function(String) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: value,
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: onChanged,
      ),
    );
  }

  // ✅ PRZYWRÓĆ CHECKBOX BEZ ZMIAN KOLORÓW
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