import 'package:flutter/material.dart';
import 'package:work_plan_front/widget/plan/plan_list/plan_selected_list.dart';

class PlanSelectedAppBar extends StatelessWidget {
  final VoidCallback? onBack;
  final String Function(BuildContext) getTime;
  final int Function() getCurrentStep;
  final VoidCallback? endWorkout;
  final String planName;

  const PlanSelectedAppBar({
    super.key,
    required this.onBack,
    required this.planName,
    required this.getTime,
    required this.getCurrentStep,
    required this.endWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
        Text(planName, style: Theme.of(context).textTheme.titleLarge),
        SizedBox(width: 20),
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
        SizedBox(width: 20),
        Text(
          getCurrentStep().toString(),
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(width: 20),
        TextButton(
          onPressed: () {
            if (endWorkout != null) endWorkout!();
          },
          child: Text(
            "End Workout",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
