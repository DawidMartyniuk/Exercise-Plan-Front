import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/provider/current_workout_plan_provider.dart';
import 'package:work_plan_front/utils/workout_utils.dart';
import 'package:work_plan_front/widget/plan/plan_works/plan_selected/plan_selected_list.dart';

class PlanSelectedAppBar extends ConsumerWidget {
  final VoidCallback? onBack;
  final String Function(BuildContext) getTime;
  final int Function() getCurrentStep;
  //final VoidCallback? endWorkout;
  final VoidCallback? onSavePlan;
  final VoidCallback? onEditPlan;
  final String planName;
  final bool isReadOnly;
  final bool isWorkoutMode; // Ustaw na true, jeśli w trybie treningu

  const PlanSelectedAppBar({
    super.key,
    required this.onBack,
    required this.planName,
    required this.getTime,
    required this.onSavePlan,
    required this.onEditPlan,
    //required this.endWorkout,
    required this.getCurrentStep,
    required this.isReadOnly,
    this.isWorkoutMode = false,
  });
void hidingScreen(BuildContext context, WidgetRef ref) async {
  if (isWorkoutMode) {
    // ✅ TRYB TRENINGU - MINIMALIZUJ I ZOSTAW TIMER AKTYWNY
    print("🔽 Minimalizowanie treningu - timer pozostaje aktywny globalnie");

    final currentWorkout = ref.read(currentWorkoutPlanProvider);
    if (currentWorkout == null) {
      print("⚠️ Brak globalnego stanu treningu - ustaw go przed minimalizacją");
    }

    if (onBack != null) {
      onBack!(); // To zapisze dane do provider
    }
    
    Navigator.pop(context);
    print("🔙 Powrót do poprzedniego ekranu - trening zminimalizowany");
  } else {
    // ✅ TRYB PODGLĄDU/EDYCJI - NORMALNY POWRÓT
    print("🔙 Tryb ReadOnly/Edycji - normalny powrót");
    
    if (onBack != null) {
      print("🔙 Wywołuję callback onBack");
      onBack!();
    }
    
    // ✅ ZAWSZE WYKONAJ Navigator.pop DLA TRYBU READONLY
    Navigator.pop(context);
    print("🔙 Navigator.pop() wykonany");
  }
  print("🔍 hidingScreen zakończony - kliknięcie");
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Przycisk powrotu
        IconButton(
          icon: Icon(
            Icons.arrow_downward,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => hidingScreen(context, ref),
        ),

        SizedBox(width: 16),
        // Czas
        isReadOnly
            ? Container()
            : Row(
              children: [
                Icon(
                  Icons.timelapse,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 4),
                Text(
                  getTime(context),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
        const SizedBox(width: 16),
        // Nazwa planu na środku
        Expanded(
          child: Center(
            child: Text(
              planName,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // getCurrentStep na końcu
        isReadOnly
            ? Container()
            : Text(
              getCurrentStep().toString(),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
        const SizedBox(width: 16),
        // Save Plan na końcu
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 98, 204, 107),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () {
            if (isReadOnly) {
              if (onEditPlan != null) onEditPlan!();
            } else {
              if (onSavePlan != null) onSavePlan!();
            }
          },
          child: Text(
            isReadOnly ? 'Edit' : 'Save',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
