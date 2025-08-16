import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/TrainingSesions.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard/workout_card_helpers.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard/components/workout_header.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard/components/workout_stats.dart';
import 'package:work_plan_front/utils/image_untils.dart'; // ✅ DODAJ IMPORT

class WorkoutCardFullscreen extends ConsumerWidget with WorkoutCardHelpers {
  final TrainingSession trainingSession;
  final List<TrainingSession>? allSessionsForDate;
  
  const WorkoutCardFullscreen({
    super.key,
    required this.trainingSession,
    this.allSessionsForDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getWorkoutTitle(trainingSession, ref) ?? "Workout Details"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (allSessionsForDate != null && allSessionsForDate!.length > 1)
              ...allSessionsForDate!.map((session) => 
                _buildSessionCard(session, context, ref)
              ).toList()
            else
              _buildSessionCard(trainingSession, context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(TrainingSession session, BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ HEADER - TEN SAM KOMPONENT
            WorkoutHeader(
              userName: getUserName(ref),
              date: session.startedAt,
              showMoreIcon: false,
            ),
            
            SizedBox(height: 16),
            
            // ✅ TYTUŁ
            Text(
              getWorkoutTitle(session, ref) ?? "Workout",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16),
            
            // ✅ STATYSTYKI - TEN SAM KOMPONENT
            WorkoutStats(
              duration: formatDuration(session.duration),
              volume: "${session.totalWeight.toInt()}kg",
              sets: "${getTotalSets(session)}",
              reps: "${getTotalReps(session)}",
              isCompact: false,
            ),
            
            SizedBox(height: 16),
            Divider(),
            
            
            ...session.exercises.map((exercise) => 
              ListTile(
                leading: Container(
                  width: 40, // ✅ WIĘKSZA IKONA
                  height: 40, // ✅ WIĘKSZA IKONA
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
                          size: 22, // ✅ WIĘKSZA IKONA
                          color: Theme.of(context).colorScheme.primary,
                        );
                      }
                      
                      // ✅ DODAJ ImageUtils.buildImage
                      return ImageUtils.buildImage(
                        imageUrl: imageUrl,
                        context: context,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        placeholder: Icon(
                          Icons.fitness_center,
                          size: 22,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }(),
                  ),
                ),
                title: Text("${exercise.sets.length} sets"),
                subtitle: Text(getExerciseName(exercise.exerciseId, ref) ?? "Exercise"),
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }
}