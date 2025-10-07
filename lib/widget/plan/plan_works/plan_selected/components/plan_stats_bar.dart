import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/provider/wordout_time_notifer.dart';

class PlanStatsBar extends ConsumerWidget {
  final bool isWorkoutMode;
  final bool isWorkoutActive;
  final int sets;

  const PlanStatsBar({
    super.key,
    required this.isWorkoutMode,
    required this.isWorkoutActive,
    required this.sets,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String timeText = "00:00";
    if (isWorkoutMode && isWorkoutActive) {
      final currentTime = ref.watch(workoutProvider);
      final minutes = currentTime ~/ 60;
      final seconds = currentTime % 60;
      timeText = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    }

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.timelapse, color: Theme.of(context).colorScheme.onSurface),
          //const SizedBox(width: 8),
          Text(timeText, style: Theme.of(context).textTheme.bodyLarge),
          const Spacer(),
          Text("Sets: $sets", style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
