import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/provider/current_workout_plan_provider.dart';
import 'package:work_plan_front/utils/workout_utils.dart';
import 'package:work_plan_front/widget/plan/plan_works/plan_selected/plan_selected_list.dart';

class PlanSelectedAppBar extends ConsumerWidget {
  final VoidCallback? onBack;

  final VoidCallback? onSavePlan;
  final VoidCallback? onEditPlan;
  final String planName;
  final bool isReadOnly;
  final bool isWorkoutMode; 

  const PlanSelectedAppBar({
    super.key,
    required this.onBack,
    required this.planName,

    required this.onSavePlan,
    required this.onEditPlan,

 
    required this.isReadOnly,
    this.isWorkoutMode = false,
  });
void hidingScreen(BuildContext context, WidgetRef ref) async {
  if (isWorkoutMode) {
    print("🔽 Minimalizowanie treningu - timer pozostaje aktywny globalnie");
    final currentWorkout = ref.read(currentWorkoutPlanProvider);
    if (currentWorkout == null) {
      print("⚠️ Brak globalnego stanu treningu - ustaw go przed minimalizacją");
    }

    if (onBack != null) {
      onBack!(); 
    }
    
    Navigator.pop(context);
    print("🔙 Powrót do poprzedniego ekranu - trening zminimalizowany");
  } else {

    print("🔙 Tryb ReadOnly/Edycji - normalny powrót");
    
    if (onBack != null) {
      print("🔙 Wywołuję callback onBack");
      onBack!();
    }

    Navigator.pop(context);
    print("🔙 Navigator.pop() wykonany");
  }
  print("🔍 hidingScreen zakończony - kliknięcie");
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
       
        IconButton(
          icon: Icon(
        Icons.arrow_downward,
        color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => hidingScreen(context, ref),
        ),

        SizedBox(width: 16),
        const SizedBox(width: 16),
      
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
      
        
        SizedBox(
          width: 70, 
          height: 36, 
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 98, 204, 107),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), //  KONTROLOWANY PADDING
              minimumSize: Size.zero, // ✅ USUŃ MINIMALNY ROZMIAR
              tapTargetSize: MaterialTapTargetSize.shrinkWrap, //  ZMNIEJSZ TARGET SIZE
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
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16, 
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis, 

            ),
          ),
        )
      ],
    );
  }
}
