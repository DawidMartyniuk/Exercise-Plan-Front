import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/widget/plan/plan_works/plan_selected/components/exercise_image.dart';

class CreationPlanCardHeader extends StatelessWidget {
  final Exercise exercise;
  const CreationPlanCardHeader({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.drag_handle,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withAlpha(40), // spójne tło
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withAlpha(100), // spójny border
            ),
          ),
          child: ExerciseImage(
            exerciseId: exercise.id,
            size: 48,
            showBorder: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            exercise.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}