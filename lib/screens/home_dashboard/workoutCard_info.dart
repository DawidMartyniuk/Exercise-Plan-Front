import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart'; // ✅ Import for DateFormat
 // ✅ DODAJ IMPORT dla formatowania dat
import 'package:work_plan_front/model/TrainingSesions.dart';
import 'package:work_plan_front/provider/ExercisePlanNotifier.dart';
import 'package:work_plan_front/provider/authProvider.dart';
import 'package:work_plan_front/provider/exerciseProvider.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard/components/avatar_widget.dart';
import 'package:work_plan_front/utils/imge_untils.dart';

class WorkoutCardInfo extends ConsumerStatefulWidget {
  final TrainingSession trainingSession;

  const WorkoutCardInfo({
    Key? key,
    required this.trainingSession,
  }) : super(key: key);

  @override
  _WorkoutCardInfoState createState() => _WorkoutCardInfoState();
}

class _WorkoutCardInfoState extends ConsumerState<WorkoutCardInfo> {
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

  // ✅ ALTERNATYWNA METODA: Bardziej czytelny format
  String _formatReadableDateTime(DateTime date) {
    final formatter = DateFormat('dd MMMM yyyy, HH:mm');
    return formatter.format(date);
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

    try {
      final matchingPlan = exercisePlans.firstWhere(
        (plan) => plan.id == widget.trainingSession.exerciseTableId,
      );
      return matchingPlan.exercise_table;
    } catch (e) {
      return widget.trainingSession.description.isNotEmpty
          ? widget.trainingSession.description
          : 'Workout Session';
    }
  }

  String _getUserName() {
    final authResponse = ref.watch(authProviderLogin);
    return authResponse!.user!.name ?? 'User';
  }
  String? _getExerciseImage(String exerciseId) {
    final exerciseState = ref.watch(exerciseProvider);

    return exerciseState.when(
      data: (allExercise) {
        try {
          final exercise = allExercise.firstWhere((ex) => ex.exerciseId == exerciseId);
          return exercise.gifUrl!.isNotEmpty ? exercise.gifUrl : null;
        } catch (e) {
          print("❌ Nie znaleziono ćwiczenia o ID: $exerciseId");
          return null;
        }
      },
      error: (error, stackTrace) {
        print("❌ Błąd podczas pobierania ćwiczeń: $error");
        return null;
      },
      loading: () => "Loading...",
    );
  }

  String? _getExerciseName(String exerciseId) {

    final exerciseState = ref.watch(exerciseProvider);

    return exerciseState.when(
      data:  (allExercise) {
        try {
          final exercise = allExercise.firstWhere((ex) => ex.exerciseId == exerciseId);
          //print("✅ Znaleziono ćwiczenie: ${exercise.name}");
          return exercise.name;
        } catch (e) {
          print("❌ Nie znaleziono ćwiczenia o ID: $exerciseId");
          return "Unknown Exercise ($exerciseId)";
        }
      },
      error: (error, stackTrace) {
        print("❌ Błąd podczas pobierania ćwiczeń: $error");
        return null;
      },
      loading: () => "Loading...",
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Details'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView( // ✅ DODAJ SCROLLING
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ SEKCJA 1: Header z użytkownikiem i datą
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
                    child: AvatarWidget(),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getUserName(),
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
                    Icons.more_horiz,
                    size: 24,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ),
              
              SizedBox(height: 8.0),
              
              // ✅ SEKCJA 2: Tytuł treningu
              Row(
                children: [
                  Expanded( // ✅ DODAJ EXPANDED
                    child: Text(
                      _getWorkoutTitle(),
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 2, // ✅ OGRANICZ LINIE
                      overflow: TextOverflow.ellipsis, // ✅ DODAJ ELLIPSIS
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 8.0),
              
              // ✅ SEKCJA 3: Statystyki - ZRÓB SCROLLOWALNE JEŚLI TRZEBA
              SingleChildScrollView(
                scrollDirection: Axis.horizontal, // ✅ HORIZONTAL SCROLL
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 16),
                      _buildStatColumn(
                        "Time",
                        _formatDuration(widget.trainingSession.duration),
                        context,
                      ),
                      SizedBox(width: 24),
                      _buildStatColumn(
                        "Volume",
                        "${widget.trainingSession.totalWeight.toInt()}kg",
                        context,
                      ),
                      SizedBox(width: 24),
                      _buildStatColumn("Sets", "${_getTotalSets()}", context),
                      SizedBox(width: 24),
                      _buildStatColumn("Reps", "${_getTotalReps()}", context),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 8.0),
              
              Divider(color: Theme.of(context).dividerColor),
                  // ✅ WORKOUT SUMMARY
              Text(
                'Workout Summary',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              
              // ✅ POPRAWIONE formatowanie daty
              _buildInfoRow('Start Workout', _formatReadableDateTime(widget.trainingSession.startedAt)),
              _buildInfoRow('Duration', _formatDuration(widget.trainingSession.duration)),
              _buildInfoRow('Total Weight', '${widget.trainingSession.totalWeight.toInt()}kg'),
              _buildInfoRow('Total Sets', '${_getTotalSets()}'),
              _buildInfoRow('Total Reps', '${_getTotalReps()}'),
              
              if (widget.trainingSession.description.isNotEmpty) ...[
                SizedBox(height: 16),
                _buildInfoRow('Description', widget.trainingSession.description),
              ],
              
              SizedBox(height: 30), // ✅ DODATKOWY PADDING NA KOŃCU
              
              SizedBox(height: 16),
              
              // ✅ LISTA ĆWICZEŃ - USUŃ EXPANDED, UŻYWAJ shrinkWrap
              ListView.builder(
                shrinkWrap: true, // ✅ WAŻNE!
                physics: NeverScrollableScrollPhysics(), // ✅ WYŁĄCZ WŁASNE SCROLLING
                itemCount: widget.trainingSession.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = widget.trainingSession.exercises[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // ✅ DODAJ crossAxisAlignment
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
                            color: Theme.of(context).colorScheme.primary.withAlpha(50),
                          ),
                          child: ClipOval(
                            child: () {
                              final imageUrl = _getExerciseImage(exercise.exerciseId);
                              
                              // ✅ JEŚLI BRAK OBRAZKA - POKAŻ IKONĘ
                              if (imageUrl == null || imageUrl.isEmpty) {
                                return Icon(
                                  Icons.fitness_center,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                );
                              }
                              
                              // ✅ JEŚLI JEST OBRAZEK - POKAŻ OBRAZEK
                              return ImageUtils.buildImage(
                                imageUrl: imageUrl,
                                context: context,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                placeholder: Icon(
                                  Icons.fitness_center,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              );
                            }(),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column( // ✅ UŻYJ COLUMN ZAMIAST ROW
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ✅ NAZWA ĆWICZENIA
                              Text(
                                _getExerciseName(exercise.exerciseId) ?? "Unknown Exercise",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              // ✅ LICZBA SETÓW
                              Text(
                                "Sets: ${exercise.sets.length}",
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              SizedBox(height: 20), // ✅ DODAJ PADDING NA KOŃCU
              
          
            ],
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

  Widget _buildInfoRow(String label, String value) {
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