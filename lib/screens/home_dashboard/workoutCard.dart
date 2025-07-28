import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/TrainingSesions.dart';
import 'package:work_plan_front/provider/ExercisePlanNotifier.dart';

class WorkoutCard extends ConsumerStatefulWidget {
  final TrainingSession trainingSession;

  const WorkoutCard({super.key, required this.trainingSession});

  @override
  _WorkoutCardState createState() => _WorkoutCardState();
}

class _WorkoutCardState extends ConsumerState<WorkoutCard> {


  String _formatDuration(int durationMinutes) {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return "${hours}h ${minutes}m";
    }
    return "${minutes}m";
  }

  String _getDaysAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    if (difference == 0) return "Today";
    if (difference == 1) return "Yesterday";
    return "$difference days ago";
  }

  int _getTotalSets() {
    return widget.trainingSession.exercises
        .map((ex) => ex.sets.length)
        .fold(0, (sum, sets) => sum + sets);
  }

  int _getTotalReps() {
    return widget.trainingSession.exercises
        .map((ex) => ex.sets.map((set) => set.actualReps).fold(0, (sum, reps) => sum + reps))
        .fold(0, (sum, reps) => sum + reps);
  }
  
    String _getWorkoutTitle() {
    final exercisePlans = ref.watch(exercisePlanProvider);
    
    // Znajdź plan o tym samym ID
    try {
      final matchingPlan = exercisePlans.firstWhere(
        (plan) => plan.id == widget.trainingSession.exerciseTableId,
      );
      return matchingPlan.exercise_table;
    } catch (e) {
      // Jeśli nie znajdzie planu, zwróć domyślną nazwę
      return widget.trainingSession.description.isNotEmpty 
          ? widget.trainingSession.description 
          : 'Workout Session';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                      color: Theme.of(context).colorScheme.primary.withAlpha(50),
                    ),
                    child: Icon(
                      Icons.person, // ✅ Zmieniono na person
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.trainingSession.description?.isEmpty ?? true 
                              ? 'Workout Session' 
                              : widget.trainingSession.description!,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          _getDaysAgo(widget.trainingSession.startedAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.more_horiz, // ✅ Zmieniono na chevron_right
                    size: 24,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text(
                    _getWorkoutTitle(), // ✅ Rzeczywista liczba ćwiczeń
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // ✅ Równomierne rozłożenie
                children: [
                  _buildStatColumn("Time", _formatDuration(widget.trainingSession.duration), context),
                  _buildStatColumn("Volume", "${widget.trainingSession.totalWeight.toInt()}kg", context),
                  _buildStatColumn("Sets", "${_getTotalSets()}", context),
                  _buildStatColumn("Reps", "${_getTotalReps()}", context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4.0),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}