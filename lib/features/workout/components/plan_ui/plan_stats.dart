import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import '../../helpers/plan_helpers.dart';

class PlanStats extends StatelessWidget with PlanHelpers {
  final ExerciseTable plan;
  final bool isCompact;

  const PlanStats({
    super.key,
    required this.plan,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final totalSets = getTotalSets(plan);
    final completedSets = getCompletedSets(plan);
    final progress = getProgressPercentage(plan);

    if (isCompact) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Sets", "$completedSets/$totalSets", context),
          _buildStatItem("Progress", "${progress.toInt()}%", context),
          _buildStatItem("Exercises", "${plan.rows.length}", context),
        ],
      );
    }

    return Column(
      children: [
        // Progress Bar
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Theme.of(context).colorScheme.outline.withAlpha(50),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress / 100,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn("Total Sets", totalSets.toString(), context),
            _buildStatColumn("Completed", completedSets.toString(), context),
            _buildStatColumn("Progress", "${progress.toInt()}%", context),
            _buildStatColumn("Exercises", plan.rows.length.toString(), context),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}