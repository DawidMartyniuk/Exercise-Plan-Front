import 'package:flutter/material.dart';
import 'package:work_plan_front/widget/plan/plan_list/plan_selected/plan_selected_list.dart';

class PlanSelectedAppBar extends StatelessWidget {
  final VoidCallback? onBack;
  final String Function(BuildContext) getTime;
  final int Function() getCurrentStep;
  //final VoidCallback? endWorkout;
  final VoidCallback? onSavePlan;
  final String planName;

  const PlanSelectedAppBar({
    super.key,
    required this.onBack,
    required this.planName,
    required this.getTime,
    required this.onSavePlan,
    //required this.endWorkout,
    required this.getCurrentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Przycisk powrotu
        IconButton(
          icon: Icon(
            Icons.arrow_downward,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {
            if (onBack != null) {
              onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        // Czas
        Row(
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
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // getCurrentStep na końcu
        Text(
          getCurrentStep().toString(),
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 16),
        // Save Plan na końcu
        TextButton(
          onPressed: () {
            if (onSavePlan != null) onSavePlan!();
          },
          child: Text(
            "Save Plan",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
