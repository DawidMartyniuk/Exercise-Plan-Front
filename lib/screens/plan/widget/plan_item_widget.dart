import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/widget/plan/widget/plan_card_more_option.dart';

class PlanItemWidget extends StatelessWidget {
  final ExerciseTable plan;
  final List<Exercise> allExercises;
  final Function(ExerciseTable, List<Exercise>) onStartWorkout;
  final Function(ExerciseTable, BuildContext, int) onDeletePlan;

  const PlanItemWidget({
    Key? key,
    required this.plan,
    required this.allExercises,
    required this.onStartWorkout,
    required this.onDeletePlan,
  }) : super(key: key);

  List<Exercise> _getFilteredExercise(ExerciseTable plan, List<Exercise> allExercises) {
    final planExerciseIds = plan.rows.map((row) => row.exercise_number).toSet();
    return allExercises.where((ex) => planExerciseIds.contains(ex.exerciseId)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<ExerciseTable>(
      data: plan,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 300,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            plan.exercise_table,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildPlanCard(context),
      ),
      child: _buildPlanCard(context),
    );
  }

  Widget _buildPlanCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      color: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).toInt()),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.exercise_table,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                PlanCardMoreOption(
                  onDeletePlan: () => onDeletePlan(plan, context, plan.id),
                  plan: plan,
                ),
              ],
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                plan.rows.map((row) => row.exercise_name).join(", "),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
                ),
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                onPressed: () {
                  final filteredExercises = _getFilteredExercise(plan, allExercises);
                  onStartWorkout(plan, filteredExercises);
                },
                child: Text(
                  "Start workout",
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}