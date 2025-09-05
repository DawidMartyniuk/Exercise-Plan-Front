import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/CurrentWorkout.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/provider/current_workout_plan_provider.dart';
import 'package:work_plan_front/provider/workout_plan_state_provider.dart';
import 'package:work_plan_front/provider/wordoutTimeNotifer.dart';

// ✅ ROZPOCZNIJ TRENING GLOBALNIE
Future<void> startWorkoutGlobal({
  required WidgetRef ref,
  required ExerciseTable plan,
  required List<Exercise> exercises,
}) async {
  print("🏃‍♂️ Rozpoczynanie treningu globalnie...");
  
  // ✅ URUCHOM TIMER
  ref.read(workoutProvider.notifier).startTimer();
  
  // ✅ USTAW AKTUALNY TRENING W PROVIDER
  ref.read(currentWorkoutPlanProvider.notifier).state = Currentworkout(
    plan: plan,
    exercises: exercises,
  );
  
  print("✅ Trening uruchomiony globalnie - timer aktywny");
}

// ✅ ZAKOŃCZ TRENING GLOBALNIE Z ALERTEM POTWIERDZENIA
Future<void> endWorkoutGlobal({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  print("🛑 Próba zakończenia treningu globalnie...");
  
  // ✅ POKAŻ ALERT POTWIERDZENIA
  final bool? shouldEnd = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // Nie można zamknąć przez kliknięcie poza alertem
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.red,
              size: 28,
            ),
            SizedBox(width: 8),
            Text('End Workout'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to end this workout?',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            // Text(
            //   'This action will:',
            //   style: TextStyle(fontWeight: FontWeight.bold),
            // ),
            // SizedBox(height: 4),
            // Text('• Stop the timer'),
            // Text('• Clear all progress'),
            // Text('• Reset all exercises'),
            // SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                '⚠️ This action cannot be undone!',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // ✅ PRZYCISK ANULOWANIA
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Zwróć false
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          // ✅ PRZYCISK POTWIERDZENIA
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Zwróć true
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stop, size: 16),
                SizedBox(width: 4),
                Text('End Workout'),
              ],
            ),
          ),
        ],
      );
    },
  );

  // ✅ SPRAWDŹ ODPOWIEDŹ UŻYTKOWNIKA
  if (shouldEnd != true) {
    print("❌ Użytkownik anulował zakończenie treningu");
    return; // Nie rób nic jeśli użytkownik anulował
  }

  print("✅ Użytkownik potwierdził - kończenie treningu...");

  // ✅ ZATRZYMAJ TIMER
  final timerController = ref.read(workoutProvider.notifier);
  timerController.stopTimer();

  // ✅ WYCZYŚĆ STAN TRENINGU
  final currentWorkout = ref.read(currentWorkoutPlanProvider);
  if (currentWorkout?.plan != null) {
    // ✅ RESETUJ PLAN DO STANU ORYGINALNEGO
    resetPlanRows(currentWorkout!.plan!);

    // ✅ WYCZYŚĆ STAN W PROVIDER
    ref.read(workoutPlanStateProvider.notifier).clearPlan(currentWorkout.plan!.id);
  }

  // ✅ WYCZYŚĆ AKTUALNY TRENING
  ref.read(currentWorkoutPlanProvider.notifier).state = null;

  print("✅ Trening zakończony globalnie");

  // ✅ POKAŻ KOMUNIKAT O ZAKOŃCZENIU
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Workout ended successfully'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

// ✅ MINIMALIZUJ TRENING (zostaw aktywny w tle)
Future<void> minimizeWorkout({
  required WidgetRef ref,
  required ExerciseTable plan,
  required List<Exercise> exercises,
}) async {
  print("🔽 Minimalizowanie treningu...");
  
  // ✅ USTAW/ZAKTUALIZUJ GLOBALNY STAN TRENINGU
  ref.read(currentWorkoutPlanProvider.notifier).state = Currentworkout(
    plan: plan,
    exercises: exercises,
  );
  
  // ✅ TIMER POZOSTAJE AKTYWNY
  print("✅ Trening zminimalizowany - timer aktywny w tle");
}

// ✅ SPRAWDŹ CZY TRENING JEST AKTYWNY
bool isWorkoutActive(WidgetRef ref) {
  final currentWorkout = ref.read(currentWorkoutPlanProvider);
  return currentWorkout != null;
}

// ✅ SPRAWDŹ CZY TRENING JEST AKTYWNY GLOBALNIE
bool isWorkoutActiveGlobally(WidgetRef ref) {
  final currentWorkout = ref.read(currentWorkoutPlanProvider);
  final timerValue = ref.read(workoutProvider);
  
  return currentWorkout != null && timerValue > 0;
}

// ✅ RESETUJ WSZYSTKIE CHECKBOX'Y I STANY
void resetPlanRows(ExerciseTable plan) {
  for (final rowData in plan.rows) {
    for (final row in rowData.data) {
      row.isChecked = false;
      row.isFailure = false;
      row.rowColor = Colors.transparent;
      row.isUserModified = false;
    }
  }
  print("🔄 Zresetowano wszystkie wiersze planu");
}