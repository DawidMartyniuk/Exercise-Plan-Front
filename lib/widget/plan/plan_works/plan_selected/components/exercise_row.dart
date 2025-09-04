import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise_plan.dart';

class ExerciseRowWidget extends StatelessWidget {
  final ExerciseRow row;
  final int stepNumber;
  final Function(String) onKgChanged;
  final Function(String) onRepChanged;
  final Function(bool?) onCheckedChanged;
  final VoidCallback? onFailureToggle;

  const ExerciseRowWidget({
    Key? key,
    required this.row,
    required this.stepNumber,
    required this.onKgChanged,
    required this.onRepChanged,
    required this.onCheckedChanged,
    this.onFailureToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: row.isFailure 
            ? const Color.fromARGB(255, 139, 69, 19) // ✅ CIEMNIEJSZY BRĄZ dla failure
            : row.isChecked 
                ? const Color.fromARGB(255, 12, 107, 15) // ✅ CIEMNO ZIELONY dla checked
                : Colors.transparent,
      ),
      child: Row(
        children: [
          // Step Number
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                stepNumber.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Weight Input
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: row.colKg.toString(),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: onKgChanged,
              ),
            ),
          ),
          
          // Reps Input
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: row.colRepMin.toString(),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: onRepChanged,
              ),
            ),
          ),
          
          // Checkbox with Double Tap
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onDoubleTap: onFailureToggle, // ✅ ZMIENIONE z onLongPress na onDoubleTap
                child: Checkbox(
                  value: row.isChecked,
                  onChanged: onCheckedChanged,
                  activeColor: row.isFailure 
                      ? Colors.red 
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}