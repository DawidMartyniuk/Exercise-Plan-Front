
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import 'package:work_plan_front/model/training_session.dart';
import 'package:work_plan_front/provider/training_serssion_notifer.dart';
import 'package:work_plan_front/features/home/workoutCard/helper/workout_card_helpers.dart';
import 'package:work_plan_front/features/home/workoutCard/components/workout_header.dart';
import 'package:work_plan_front/features/home/workoutCard/components/workout_stats.dart';
import 'package:work_plan_front/features/home/workoutCard/workout_card_fullscreen.dart';
import 'package:work_plan_front/features/home/workout_info/workoutCard_info.dart';
import 'package:work_plan_front/shared/utils/image_untils.dart'; // ✅ DODAJ IMPORT

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


void _deleteTrainingSession(int sessionId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete Workout'),
        content: Text('Are you sure you want to delete this workout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Zamknij dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Zamknij dialog
              
              try {

                await ref.read(trainingSessionAsyncProvider.notifier)
                    .deleteTrainingSessions(sessionId);
                
                //  POKAŻ SUKCES
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Workout deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                //  POKAŻ BŁĄD
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete workout: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}

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
            //  HEADER - KOMPONENT
            WorkoutHeader(
              userName: getUserName(ref),
              date: session.startedAt,
              onInfo: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutCardInfo(trainingSession: session),
                  ),
                );
              },
              onDelete: () {
               if (session.id != null) {
                 _deleteTrainingSession(session.id!);
               }
               
              },
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
              trainingSession: widget.trainingSession,
            ),
            
            SizedBox(height: 8),
            Divider(),
            
            //  ĆWICZENIA - UPROSZCZONE
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
    return Container(
      height: 80, 
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(50),
          width: 1,
        ),
      ),
      clipBehavior: Clip.hardEdge, 
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: widget.trainingSession.exercises.take(2).length,
        itemBuilder: (context, index) {
          final exercise = widget.trainingSession.exercises[index];
          return Container(
            //  WŁASNY CONTAINER ZAMIAST LISTTILE (LEPSZĄ KONTROLA)
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface, //  KONTROLOWANE TŁO
            ),
            child: Row(
              children: [
                // IKONA ĆWICZENIA
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    color: Theme.of(context).colorScheme.primary.withAlpha(50),
                    boxShadow: [
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
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        );
                      }
                      
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
                
                SizedBox(width: 12),
                
                // ✅ TEKST
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${exercise.sets.length} sets",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        getExerciseName(exercise.exerciseId, ref) ?? "Exercise",
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}