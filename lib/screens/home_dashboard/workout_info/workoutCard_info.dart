import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/training_session.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard/components/workout_header.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard/components/workout_stats.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard/helper/workout_card_helpers.dart';
import 'package:work_plan_front/screens/home_dashboard/workout_info/exercise_list_view.dart';
import 'package:work_plan_front/screens/home_dashboard/workout_info/workout_info_summary.dart';

class WorkoutCardInfo extends ConsumerWidget with WorkoutCardHelpers {
  final TrainingSession trainingSession;

  const WorkoutCardInfo({
    Key? key,
    required this.trainingSession,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ DODAJ DEFENSIVE PROGRAMMING
    if (trainingSession == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Workout Details')),
        body: Center(
          child: Text('No workout data available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Details'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ HEADER - DODAJ NULL SAFETY
              WorkoutHeader(
                userName: getUserName(ref) ?? "Unknown User", // ✅ FALLBACK
                date: trainingSession.startedAt,
                showMoreIcon: true,
              ),
              
              SizedBox(height: 8.0),
              
              // ✅ TYTUŁ TRENINGU - DODAJ NULL SAFETY
              Row(
                children: [
                  Expanded(
                    child: Text(
                      getWorkoutTitle(trainingSession, ref) ?? 
                      trainingSession.exercise_table_name ?? 
                      "Workout Session", // ✅ PODWÓJNY FALLBACK
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 8.0),
              SizedBox(height: 8.0),
              Divider(color: Theme.of(context).dividerColor),
              
              // ✅ WORKOUT SUMMARY - WRAP W TRY-CATCH
              _buildSafeWidget(
                () => 
               WorkoutStats(
                duration: formatDuration(trainingSession.duration),
                volume: "${trainingSession.totalWeight.toInt()}kg",
                sets: "${getTotalSets(trainingSession)}",
                reps: "${getTotalReps(trainingSession)}",
                isCompact: false, // ✅ PEŁNY LAYOUT (2x2 grid)\
                trainingSession: trainingSession,
              ),
                "Error loading workout summary",
                context,
              ),
              
              SizedBox(height: 30),
              
              // ✅ LISTA ĆWICZEŃ - WRAP W TRY-CATCH
              _buildSafeWidget(
                () => ExerciseListView(trainingSession: trainingSession),
                "Error loading exercises",
                context,
              ),
              
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // HELPER DO BEZPIECZNEGO RENDEROWANIA WIDGETÓW
  Widget _buildSafeWidget(Widget Function() builder, String errorMessage, BuildContext context) {
    try {
      return builder();
    } catch (e) {
      print("❌ Error in WorkoutCardInfo: $e");
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red,
              ),
            ),
            Text(
              "Error: $e",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }
  }
}