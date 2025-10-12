import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/widget/plan/plan_works/plan_selected/plan_selected_list.dart';
import 'package:work_plan_front/widget/plan/widget/plan_card_more_option.dart';
import 'package:work_plan_front/provider/exercise_plan_notifier.dart';

class PlanItemWidget extends ConsumerWidget {
  final ExerciseTable plan;
  final List<Exercise> allExercises;
  final Future<void> Function(ExerciseTable, List<Exercise>) onStartWorkout; // ✅ ZMIEŃ NA ASYNC
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
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPlans = ref.watch(exercisePlanProvider);
    final currentPlan = currentPlans.firstWhere(
      (p) => p.id == plan.id,
      orElse: () => plan,
    );

    return Draggable<ExerciseTable>(
      data: currentPlan,
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
            currentPlan.exercise_table,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildPlanCard(context, currentPlan),
      ),
      child: _buildPlanCard(context, currentPlan),
    );
  }

  Widget _buildPlanCard(BuildContext context, ExerciseTable currentPlan) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      color: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).toInt()),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 6.0,
          horizontal: 16.0,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    currentPlan.exercise_table,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                PlanCardMoreOption(
                  onShowPlan: () => _showPlanSelected(context, currentPlan),
                  onDeletePlan: () => onDeletePlan(currentPlan, context, currentPlan.id),
                  plan: currentPlan,
                ),
              ],
            ),
            SizedBox(height: 2),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                currentPlan.rows.map((row) => row.exercise_name).join(", "),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
                ),
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                // ✅ ZMIEŃ onPressed NA ASYNC
                onPressed: () async {
                  final filteredExercises = _getFilteredExercise(currentPlan, allExercises);
                  await onStartWorkout(currentPlan, filteredExercises);
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

  void _showPlanSelected(BuildContext context, ExerciseTable plan) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => 
  
        PlanSelectedList(
          plan: plan,
          exercises: allExercises,
          isReadOnly: true, //  TRYB PODGLĄDU
          isWorkoutMode: false, //  BEZ TRENINGU
        ),
     // ),
    ),
  );
}
}