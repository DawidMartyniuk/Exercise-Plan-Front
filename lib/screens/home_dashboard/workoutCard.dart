import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/TrainingSesions.dart';
import 'package:work_plan_front/provider/ExercisePlanNotifier.dart';
import 'package:work_plan_front/provider/authProvider.dart';
import 'package:work_plan_front/provider/exerciseProvider.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard_info.dart';
import 'package:work_plan_front/utils/imge_untils.dart';

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
        .map(
          (ex) => ex.sets
              .map((set) => set.actualReps)
              .fold(0, (sum, reps) => sum + reps),
        )
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

  String _getUserName() {
    final authResponse = ref.watch(authProviderLogin);
    return authResponse?.user.name ?? 'User';
  }

  String? _getExerciseName(int exerciseId) {
    final allExercise = ref.watch(exerciseProvider);

    final formattedID = exerciseId.toString().padLeft(4, '0');
    print(
      "🔍 Szukam ćwiczenia: exerciseId=$exerciseId, formattedId=$formattedID",
    );
    try {
      final exercise = allExercise?.firstWhere((ex) => ex.id == formattedID);
      print("✅ Znaleziono ćwiczenie: ${exercise?.name}");
      return exercise?.name;
    } catch (e) {
      print("❌ Nie znaleziono ćwiczenia o ID: $formattedID");
      return null;
    }
  }
  String _getExerciseImage(int exerciseId) {
    final allExercise = ref.watch(exerciseProvider);

    final formattedID = exerciseId.toString().padLeft(4, '0');
    print(
      "🔍 Szukam obrazka ćwiczenia: exerciseId=$exerciseId, formattedId=$formattedID",
    );
    try {
      final exercise = allExercise?.firstWhere((ex) => ex.id == formattedID);
      print("✅ Znaleziono obrazek ćwiczenia: ${exercise?.gifUrl}");
      return exercise?.gifUrl ?? '';
    } catch (e) {
      print("❌ Nie znaleziono obrazka ćwiczenia o ID: $formattedID");
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => WorkoutCardInfo( 
                trainingSession: widget.trainingSession, 
              ),
            ),
          );
        },
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
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(50),
                      ),
                      child: Icon(
                        Icons.person, //
                        size: 20,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getUserName(),
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium!.copyWith(
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
                      Icons.more_horiz,
                      size: 24,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Text(
                      _getWorkoutTitle(),
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: EdgeInsets.only(left: 16), // ✅ Odstęp od lewej
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .start, // ✅ ZMIANA: start zamiast spaceAround
                    children: [
                      SizedBox(width: 16), // ✅ DODAJ: odstęp od lewej
                      _buildStatColumn(
                        "Time",
                        _formatDuration(widget.trainingSession.duration),
                        context,
                      ),
                      SizedBox(width: 24), // ✅ DODAJ: odstęp między kolumnami
                      _buildStatColumn(
                        "Volume",
                        "${widget.trainingSession.totalWeight.toInt()}kg",
                        context,
                      ),
                      SizedBox(width: 24), // ✅ DODAJ: odstęp między kolumnami
                      _buildStatColumn("Sets", "${_getTotalSets()}", context),
                      SizedBox(width: 24), // ✅ DODAJ: odstęp między kolumnami
                      _buildStatColumn("Reps", "${_getTotalReps()}", context),
                    ],
                  ),
                ),
                SizedBox(height: 8.0),
                Divider(color: Theme.of(context).dividerColor),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.trainingSession.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = widget.trainingSession.exercises[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: [
                          // ✅ Ikona na początku
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.onSecondary,
                                width: 2,
                              ),
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(50),
                            ),
                            child: ClipOval(
                              child: ImageUtils.buildImage(
                                imageUrl: _getExerciseImage(int.parse(exercise.exerciseId)),
                                context: context,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                placeholder: ImageUtils.buildSmallPlaceholder(context, size: 40),
                              ),
                            )
                            // Icon(
                            //   Icons.fitness_center,
                            //   size: 20,
                            //   color: Theme.of(context).colorScheme.primary,
                            // ),
                          ),
                          SizedBox(width: 12), // ✅ Odstęp między ikoną a tekstem
                          // ✅ Nazwa ćwiczenia - rozciąga się
                          
                           Text(
                            "Sets: ${exercise.sets.length} ",
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface,
                            ),
                          ),
                          
                          Text(
                              _getExerciseName(
                                int.parse(exercise.exerciseId),
                              ) ?? "Unknown Exercise",
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          
        
                          // ✅ Liczba serii
                         
        
                          SizedBox(width: 16), // ✅ Odstęp
                          // ✅ Liczba powtórzeń
                          // Text(
                          //   "${exercise.sets.map((set) => set.actualReps).reduce((a, b) => a + b)} reps",
                          //   style: Theme.of(
                          //     context,
                          //   ).textTheme.bodySmall?.copyWith(
                          //     color: Theme.of(
                          //       context,
                          //     ).colorScheme.onSurface.withAlpha(150),
                          //   ),
                          // ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 4.0),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
