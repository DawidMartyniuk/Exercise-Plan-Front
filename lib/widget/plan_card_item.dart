import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise_plan.dart';

class PlanCardItem extends StatelessWidget {
  final ExerciseTable plan;
  final VoidCallback? onStartWorkout;

  const PlanCardItem({super.key, required this.plan, this.onStartWorkout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(plan.exercise_table, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: plan.rows.map((row) => ListTile(
                    title: Text(row.exercise_name),
                    subtitle: Text("Notatki: ${row.notes}"),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onStartWorkout,
                child: const Text("Zwin plan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}