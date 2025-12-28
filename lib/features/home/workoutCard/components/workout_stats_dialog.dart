import 'package:flutter/material.dart';
import 'package:work_plan_front/model/training_session.dart';
import 'package:work_plan_front/features/home/workoutCard/components/stat_item.dart';
import 'package:work_plan_front/features/home/workoutCard/helper/date_time_helper.dart';
import 'package:work_plan_front/features/home/workoutCard/helper/workout_card_helpers.dart';

class WorkoutStatsDialog extends StatelessWidget with WorkoutCardHelpers {
  final StatItem stat;
  final TrainingSession trainingSession;

  const WorkoutStatsDialog({
    super.key,
    required this.stat,
    required this.trainingSession,
  });

  static void show(BuildContext context, StatItem stat, TrainingSession trainingSession) {
    showDialog(
      context: context,
      builder: (context) => WorkoutStatsDialog(
        stat: stat,
        trainingSession: trainingSession,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: stat.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              stat.icon,
              color: stat.color,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '${stat.label} Details',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatContent(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    );
  }

  Widget _buildStatContent() {
    switch (stat.label) {
      case "Time":
        return _buildTimeContent();
      case "Volume":
        return _buildVolumeContent();
      case "Sets":
        return _buildSetsContent();
      case "Reps":
        return _buildRepsContent();
      default:
        return Text('${stat.label}: ${stat.value}');
    }
  }

  Widget _buildTimeContent() {
    final startTime = trainingSession.startedAt;
    final duration = trainingSession.duration;
    
    // ✅ OBLICZ END TIME NA PODSTAWIE START TIME + DURATION
    final endTime = DateTimeHelpers.calculateEndTime(startTime, duration);
    final isMultiDay = DateTimeHelpers.isMultiDaySession(startTime, duration);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow("Total Duration", DateTimeHelpers.formatDetailedDuration(duration)),
        SizedBox(height: 8),
        
        // ✅ START TIME INFORMACJE
        _buildInfoRow("Start Date", DateTimeHelpers.formatDateTime(startTime)),
        _buildInfoRow("Start Time", DateTimeHelpers.formatTime(startTime)),
        
        SizedBox(height: 8),
        
        // ✅ END TIME INFORMACJE (OBLICZONE)
        _buildInfoRow("End Date", DateTimeHelpers.formatDateTime(endTime)),
        _buildInfoRow("End Time", DateTimeHelpers.formatTime(endTime)),
        
        SizedBox(height: 8),
        
        // ✅ DODATKOWE INFORMACJE
        if (isMultiDay) ...[
          _buildInfoRow("Session Span", "Multi-day session"),
          _buildInfoRow("Date Range", DateTimeHelpers.getSessionDateRange(startTime, endTime)),
        ] else ...[
          _buildInfoRow("Time Range", DateTimeHelpers.formatFullTimeRange(startTime, duration)),
        ],
        
        SizedBox(height: 8),
        _buildInfoRow("Day of Week", DateTimeHelpers.getDayOfWeek(startTime)),
        _buildInfoRow("Days Ago", DateTimeHelpers.getDaysAgo(startTime)),
      ],
    );
  }

  Widget _buildVolumeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow("Total Weight", "${trainingSession.totalWeight.toInt()}kg"),
        _buildInfoRow("Total Exercises", "${getTotalExercises(trainingSession)}"),
        _buildInfoRow("Avg Weight per Exercise", "${(trainingSession.totalWeight / getTotalExercises(trainingSession)).toStringAsFixed(1)}kg"),
        _buildInfoRow("Avg Weight per Set", "${(trainingSession.totalWeight / getTotalSets(trainingSession)).toStringAsFixed(1)}kg"),
      ],
    );
  }

  Widget _buildSetsContent() {
    final totalSets = getTotalSets(trainingSession);
    final totalExercises = getTotalExercises(trainingSession);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow("Total Sets", "$totalSets"),
        _buildInfoRow("Total Exercises", "$totalExercises"),
        _buildInfoRow("Avg Sets per Exercise", (totalSets / totalExercises).toStringAsFixed(1)),
        _buildInfoRow("Sets per Minute", (totalSets / (trainingSession.duration / 60)).toStringAsFixed(1)),
      ],
    );
  }

  Widget _buildRepsContent() {
    final totalReps = getTotalReps(trainingSession);
    final totalSets = getTotalSets(trainingSession);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow("Total Reps", "$totalReps"),
        _buildInfoRow("Total Sets", "$totalSets"),
        _buildInfoRow("Avg Reps per Set", (totalReps / totalSets).toStringAsFixed(1)),
        _buildInfoRow("Reps per Minute", (totalReps / (trainingSession.duration / 60)).toStringAsFixed(1)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
