import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/provider/current_workout_plan_provider.dart';
import 'package:work_plan_front/provider/workout_plan_state_provider.dart';
import 'package:work_plan_front/provider/wordoutTimeNotifer.dart';

Future<void> endWorkoutGlobal({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final timerController = ref.read(workoutProvider.notifier);
  timerController.stopTimer();
  final currentWorkout = ref.read(currentWorkoutPlanProvider);
  if (currentWorkout?.plan != null) {
    ref.read(workoutPlanStateProvider.notifier).clearPlan(currentWorkout!.plan!.id);
  }
  ref.read(currentWorkoutPlanProvider.notifier).state = null;
  //Navigator.of(context).pop();
}