import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/reps_type.dart';
import 'package:work_plan_front/provider/repsTypeProvider.dart';

class WorkoutRepsField extends ConsumerWidget {
  final ExerciseRow row;
  final String exerciseNumber;
  final Function(String) onRepChanged;
  final String Function(String, int) getOriginalRange;
  final bool isReadOnly;

  const WorkoutRepsField({
    super.key,
    required this.row,
    required this.exerciseNumber,
    required this.onRepChanged,
    required this.getOriginalRange,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repsType = ref.watch(exerciseRepsTypeProvider(exerciseNumber));
    
    String displayValue = "";
    String hintText = "";

    if (repsType == RepsType.range) {
      if (row.isUserModified || row.colRepMin > 0) {
        // ✅ UŻYTKOWNIK WPROWADZIŁ WARTOŚĆ LUB MA JAKĄŚ WARTOŚĆ - POKAZUJ JĄ
        displayValue = row.colRepMin.toString();
        hintText = "";
      } else {
        // ✅ BRAK WARTOŚCI - POKAZUJ ZAKRES W HINT
        displayValue = "";
        hintText = getOriginalRange(exerciseNumber, row.colStep);
      }
    } else {
      // ✅ SINGLE/SECONDS
      displayValue = row.colRepMin > 0 ? row.colRepMin.toString() : "";
      hintText = repsType == RepsType.single ? "0 " : "0";
    }

    print("🔍 WorkoutRepsField: displayValue='$displayValue', hintText='$hintText', isUserModified=${row.isUserModified}");

    // ✅ JEŚLI isReadOnly - ZWRÓĆ TYLKO TEXT
    if (isReadOnly) {
      String readOnlyText = displayValue.isNotEmpty ? displayValue : hintText;
      
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
    
    // ✅ TRYB EDYCJI - PROSTY TEXTFIELD
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
            fontSize: 12,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        controller: TextEditingController(text: displayValue),
        onChanged: (newValue) {
          print("🔍 WorkoutRepsField onChanged: '$newValue'");
          onRepChanged(newValue);
        },
        // ✅ DODAJ onTap DO SELEKCJI CAŁEGO TEKSTU
        onTap: () {
          // ✅ AUTOMATYCZNIE ZAZNACZ CAŁY TEKST PRZY KLIKNIĘCIU
          if (displayValue.isNotEmpty) {
            print("🔍 TextField tapped - selecting all text");
          }
        },
      ),
    );
  }
}