import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/reps_type.dart';
import 'package:work_plan_front/provider/repsTypeProvider.dart';
import 'package:work_plan_front/provider/weightTypeProvider.dart';
import 'package:work_plan_front/widget/plan/plan_works/plan_selected/components/exercise_row.dart';

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
    
   // print('🔍 Grouped data: ${groupedData.keys.toList()}');
    return groupedData;
  }

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
              
              // ✅ WEIGHT COLUMN
              isReadOnly 
                  ? _buildReadOnlyCell(context, exerciseRow.colKg.toString())
                  : _buildEditableWeightCell(
                    context, 
                    exerciseRow.colKg.toString(),
                    (value) => onKgChanged?.call(exerciseRow, value, exerciseRowData.exercise_number),
                  ),
              
              // ✅ REPS COLUMN - UŻYJ _buildEditableCell
              _buildEditableCell(
                context,
                exerciseRow.colRepMin.toString(),
                "reps",
                (value) => onRepChanged?.call(exerciseRow, value, exerciseRowData.exercise_number),
                ref: ref,
                exerciseNumber: exerciseRowData.exercise_number,
                row: exerciseRow,
                getOriginalRange: getOriginalRange,
                isReadOnly: isReadOnly,
              ),
              
              // ✅ CHECKBOX COLUMN - TYLKO JEŚLI NIE isReadOnly
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
  static Widget _buildReadOnlyCell(BuildContext context, String value) {
  return Container(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      value,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
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


//  POPRAW _buildEditableCell ABY UŻYWAŁ ORYGINALNYCH ZAKRESÓW
static Widget _buildEditableCell(
  BuildContext context,
  String value,
  String type,
  Function(String) onChanged, {
  required WidgetRef ref,
  required String exerciseNumber,
  required ExerciseRow row,
  required String Function(String, int) getOriginalRange, 
  bool isReadOnly = false,
}) {
  String displayValue = "";
  String hintText = "";

  if (type == "reps") {
    final repsType = ref.watch(exerciseRepsTypeProvider(exerciseNumber));

    if (repsType == RepsType.range) {
      if (row.isUserModified) {
        // ✅ UŻYTKOWNIK WPROWADZIŁ WARTOŚĆ - ZAWSZE POKAZUJ JĄ
        displayValue = row.colRepMin.toString();
        hintText = "";
      } else if (row.isChecked) {
        // ✅ ZAZNACZONE ALE BRAK MODYFIKACJI - POKAZUJ ŚREDNIĄ
        final middleValue = ((row.colRepMin + row.colRepMax) ~/ 2).round();
        displayValue = middleValue.toString();
        hintText = "";
      } else {
        // ✅ NIEZAZNACZONE I BRAK MODYFIKACJI - POKAZUJ ZAKRES W HINT
        displayValue = "";
        hintText = getOriginalRange(exerciseNumber, row.colStep);
      }
    } else {
      // ✅ SINGLE
      displayValue = row.colRepMin > 0 ? row.colRepMin.toString() : "";
      hintText = "0";
    }
  } else if (type == "weight") {
    // ✅ WAGA
    final weightType = ref.watch(exerciseWeightTypeProvider(exerciseNumber));
    final unit = weightType.displayName;
    
    displayValue = value != "0" ? value : "";
    hintText = "0 $unit";
  }
  
  if (isReadOnly) {
    String readOnlyText = displayValue;
    if (displayValue.isEmpty && hintText.isNotEmpty) {
      readOnlyText = hintText;
    }
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        readOnlyText,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  return Container(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
        contentPadding: EdgeInsets.zero,
      ),
      controller: TextEditingController(text: displayValue),
      onChanged: (newValue) {
        onChanged(newValue);
      },
      // ✅ ZAWSZE EDYTOWALNE
    ),
  );
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

// ✅ DODAJ METODĘ DLA WEIGHT FIELD Z LOGAMI
static Widget _buildEditableWeightCell(
  BuildContext context, 
  String initialValue,
  Function(String) onChanged,
) {
 // print("🏋️ _buildEditableWeightCell CALLED:");
 // print("  - initialValue: '$initialValue'");
  //print("  - initialValue.runtimeType: ${initialValue.runtimeType}");
  
  return Container(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: initialValue.isEmpty ? "0 kg" : initialValue, // ✅ POPRAWKA HINT
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
      controller: TextEditingController(text: initialValue), // ✅ USTAW KONTROLER
      onChanged: (newValue) {
        print("🏋️ _buildEditableWeightCell onChanged: '$newValue'");
        onChanged(newValue);
      },
      onTap: () {
        print("🏋️ _buildEditableWeightCell tapped - current value: '$initialValue'");
      },
    ),
  );
}
}
