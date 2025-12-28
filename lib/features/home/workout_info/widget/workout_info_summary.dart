import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:work_plan_front/model/training_session.dart';
import 'package:work_plan_front/features/home/workoutCard/helper/workout_card_helpers.dart';

class WorkoutInfoSummary extends ConsumerWidget with WorkoutCardHelpers {
  final TrainingSession trainingSession;

  const WorkoutInfoSummary({
    super.key,
    required this.trainingSession,
  });

  String _formatReadableDateTime(DateTime date) {
    final formatter = DateFormat('dd MMMM yyyy, HH:mm');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Workout Summary',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 16),
        
        _buildInfoRow(context, 'Start Workout', _formatReadableDateTime(trainingSession.startedAt)),
        _buildInfoRow(context, 'Duration', formatDuration(trainingSession.duration)),
        _buildInfoRow(context, 'Total Weight', '${trainingSession.totalWeight.toInt()}kg'),
        _buildInfoRow(context, 'Total Sets', '${getTotalSets(trainingSession)}'),
        _buildInfoRow(context, 'Total Reps', '${getTotalReps(trainingSession)}'),
        _buildInfoRow(context, "Total Exercises", '${getTotalExercises(trainingSession)}'),

        if (trainingSession.description?.isNotEmpty == true) ...[
          SizedBox(height: 16),
          _buildInfoRow(context, 'Description', trainingSession.description ?? 'No description'),
        ],
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}