import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import 'package:work_plan_front/model/TrainingSesions.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard/workout_card_helpers.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard/workout_header.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard/workout_stats.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard/workout_card_fullscreen.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard_info.dart';
import 'package:work_plan_front/utils/imge_untils.dart'; // ✅ DODAJ IMPORT

class WorkoutCard extends ConsumerStatefulWidget {
  final TrainingSession trainingSession;
  final bool showAsFullScreen;
  final List<TrainingSession>? allSessionsForDate;

  const WorkoutCard({
    super.key, 
    required this.trainingSession,
    this.showAsFullScreen = false,
    this.allSessionsForDate,
  });

  @override
  _WorkoutCardState createState() => _WorkoutCardState();
}

class _WorkoutCardState extends ConsumerState<WorkoutCard> with WorkoutCardHelpers {
  @override
  Widget build(BuildContext context) {
    if (widget.showAsFullScreen) {
      return WorkoutCardFullscreen(
        trainingSession: widget.trainingSession,
        allSessionsForDate: widget.allSessionsForDate,
      );
    }

    return Container(
      padding: EdgeInsets.all(16.0),
      child: OpenContainer<bool>(
        transitionType: ContainerTransitionType.fade,
        transitionDuration: Duration(milliseconds: 500),
        openColor: Theme.of(context).colorScheme.surface,
        closedColor: Colors.transparent,
        closedBuilder: (context, action) => _buildCompactCard(),
        openBuilder: (context, action) => WorkoutCardInfo(
          trainingSession: widget.trainingSession,
        ),
      ),
    );
  }

  Widget _buildCompactCard() {
    final session = widget.trainingSession;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ HEADER - KOMPONENT
            WorkoutHeader(
              userName: getUserName(ref),
              date: session.startedAt,
            ),
            
            SizedBox(height: 12),
            
            // ✅ TYTUŁ
            Row(
              children: [
                Expanded(
                  child: Text(
                    getWorkoutTitle(session, ref) ?? "Workout",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            // ✅ STATYSTYKI - KOMPONENT
            WorkoutStats(
              duration: formatDuration(session.duration),
              volume: "${session.totalWeight.toInt()}kg",
              sets: "${getTotalSets(session)}",
              reps: "${getTotalReps(session)}",
              isCompact: true,
            ),
            
            SizedBox(height: 8),
            Divider(),
            
            // ✅ ĆWICZENIA - UPROSZCZONE
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 80),
              child: _buildExercisesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.trainingSession.exercises.take(2).length,
      itemBuilder: (context, index) {
        final exercise = widget.trainingSession.exercises[index];
        return ListTile(
          dense: true,
          leading: Container(
            width: 32, // ✅ WIĘKSZA IKONA
            height: 32, // ✅ WIĘKSZA IKONA
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary, // ✅ WYRAŹNIEJSZE OBRAMOWANIE
                width: 2, // ✅ GRUBSZE OBRAMOWANIE
              ),
              color: Theme.of(context).colorScheme.primary.withAlpha(50),
              boxShadow: [ // ✅ DODAJ CIEŃ
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withAlpha(30),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: () {
                final imageUrl = getExerciseImage(exercise.exerciseId, ref);
                
                if (imageUrl == null || imageUrl.isEmpty) {
                  return Icon(
                    Icons.fitness_center,
                    size: 18, // ✅ WIĘKSZA IKONA
                    color: Theme.of(context).colorScheme.primary,
                  );
                }
                
                // ✅ DODAJ ImageUtils.buildImage
                return ImageUtils.buildImage(
                  imageUrl: imageUrl,
                  context: context,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  placeholder: Icon(
                    Icons.fitness_center,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              }(),
            ),
          ),
          title: Text(
            "${exercise.sets.length} sets",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            getExerciseName(exercise.exerciseId, ref) ?? "Exercise", 
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      },
    );
  }
}