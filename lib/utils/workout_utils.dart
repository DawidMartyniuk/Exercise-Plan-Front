import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/current_workout.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/provider/current_workout_plan_provider.dart';
import 'package:work_plan_front/provider/workout_plan_state_provider.dart';
import 'package:work_plan_front/provider/wordout_time_notifer.dart';

//  ROZPOCZNIJ TRENING GLOBALNIE
Future<void> startWorkoutGlobal({
  required BuildContext context,
  required WidgetRef ref,
  required ExerciseTable plan,
  required List<Exercise> exercises,
}) async {
  print("🏃‍♂️ Rozpoczynanie treningu globalnie...");

  if (isWorkoutActive(ref)) {
    final bool? shouldEnd = await showDialog<bool>(
      context: context,

      barrierDismissible:
          false, // Nie można zamknąć przez kliknięcie poza alertem
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                child: Text(
                  'If you want to start this training you \n must finish the previous one',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withAlpha(100), //  JAŚNIEJSZY OD TŁA
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: () {
                      // Zamknij tylko okno dialogowe
                      Navigator.of(context).pop(false);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(
                        50,
                      ), //  PRZEZROCZYSTE TŁO (CONTAINER DAJE KOLOR)
                      shadowColor: Colors.transparent, // BEZ CIENIA
                      elevation: 0, //  BEZ ELEVATION
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white, //  BIAŁY TEKST
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withAlpha(100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pop(true); // Zakończ i rozpocznij nowy
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(50),
                      shadowColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: Text(
                      'End Current & Start New',
                      style: TextStyle(color: Colors.orange, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    // return;
    if (shouldEnd != true) {
      print("❌ Użytkownik anulował rozpoczęcie nowego treningu");
      return;
    }
    print("🔄 Kończenie aktualnego treningu przed rozpoczęciem nowego...");
    await endWorkoutGlobal(
      context: context,
      ref: ref,
      showConfirmationDialog: false,
    );
  }
  print("🏃‍♂️ Uruchamianie nowego treningu...");

  //  URUCHOM TIMER
  ref.read(workoutProvider.notifier).startTimer();

  //  USTAW AKTUALNY TRENING W PROVIDER
  ref.read(currentWorkoutPlanProvider.notifier).state = Currentworkout(
    plan: plan,
    exercises: exercises,
    // active: true,
  );

  print("✅ Trening uruchomiony globalnie - timer aktywny");
}

// ✅ ZAKOŃCZ TRENING GLOBALNIE Z ALERTEM POTWIERDZENIA
Future<void> endWorkoutGlobal({
  required BuildContext context,
  required WidgetRef ref,
  bool showConfirmationDialog = true,
}) async {
  print("🛑 Próba zakończenia treningu globalnie...");

  // ✅ POKAŻ ALERT POTWIERDZENIA
  if (showConfirmationDialog == true) {
    final bool? shouldEnd = await showDialog<bool>(
      context: context,
      barrierDismissible:
          false, // Nie można zamknąć przez kliknięcie poza alertem
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                child: Text(
                  'Are you sure you want to end this workout \n and clear all progress?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //  PRZYCISK ANULOWANIA - container z jaśniejszym tłem, biały tekst
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withAlpha(100), //  JAŚNIEJSZY OD TŁA
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // Zwróć false
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(
                        50,
                      ), //  PRZEZROCZYSTE TŁO (CONTAINER DAJE KOLOR)
                      shadowColor: Colors.transparent, // BEZ CIENIA
                      elevation: 0, //  BEZ ELEVATION
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white, //  BIAŁY TEKST
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                // ✅ PRZYCISK POTWIERDZENIA - container z jaśniejszym tłem, czerwony tekst
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withAlpha(100), //  JAŚNIEJSZY OD TŁA
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // Zwróć true
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(
                        50,
                      ), // ✅ PRZEZROCZYSTE TŁO (CONTAINER DAJE KOLOR)
                      shadowColor: Colors.transparent, //  BEZ CIENIA
                      elevation: 0, // BEZ ELEVATION
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //Icon(Icons.stop, size: 16, color: Colors.red), // ✅ CZERWONA IKONA
                        SizedBox(width: 4),
                        Text(
                          'End Workout',
                          style: TextStyle(
                            color: Colors.red, // ✅ CZERWONY TEKST
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldEnd != true) {
      print("❌ Użytkownik anulował zakończenie treningu");
      return; // Nie rób nic jeśli użytkownik anulował
    }
  }

  print("✅ Użytkownik potwierdził - kończenie treningu...");

  //  ZATRZYMAJ TIMER
  final timerController = ref.read(workoutProvider.notifier);
  timerController.stopTimer();

  //  WYCZYŚĆ STAN TRENINGU
  final currentWorkout = ref.read(currentWorkoutPlanProvider);
  if (currentWorkout?.plan != null) {
    //  RESETUJ PLAN DO STANU ORYGINALNEGO
    resetPlanRows(currentWorkout!.plan!);

    //  WYCZYŚĆ STAN W PROVIDER
    ref
        .read(workoutPlanStateProvider.notifier)
        .clearPlan(currentWorkout.plan!.id);
  }

  //  WYCZYŚĆ AKTUALNY TRENING
  ref.read(currentWorkoutPlanProvider.notifier).state = null;

  print("✅ Trening zakończony globalnie");
}

// MINIMALIZUJ TRENING (zostaw aktywny w tle)
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

  // TIMER POZOSTAJE AKTYWNY
  print("✅ Trening zminimalizowany - timer aktywny w tle");
}

// ✅ SPRAWDŹ CZY TRENING JEST AKTYWNY
bool isWorkoutActive(WidgetRef ref) {
  final currentWorkout = ref.read(currentWorkoutPlanProvider);
  return currentWorkout != null;
}

// SPRAWDŹ CZY TRENING JEST AKTYWNY GLOBALNIE
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
