import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart'; // ✅ DODAJ IMPORT
import 'package:work_plan_front/model/TrainingSesions.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
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

  String? _getWorkoutTitle() {
  final exercisePlans = ref.watch(exercisePlanProvider);
  
  print("🔍 Szukam planu ID=${widget.trainingSession.exerciseTableId}");
 // print("🔍 Dostępne plany: ${exercisePlans.map((p) => 'ID=${p.id}:${p.exercise_table}').join(', ')}");

  // ✅ JEŚLI BRAK PLANÓW - UŻYJ exercise_table_name Z SESJI
  if (exercisePlans.isEmpty) {
    print("⚠️ Brak planów - używam exercise_table_name z sesji");
    if (widget.trainingSession.exercise_table_name!.isNotEmpty) {
      return widget.trainingSession.exercise_table_name;
    }
    return "Workout #${widget.trainingSession.id}";
  }

  // Znajdź plan o tym samym ID
  try {
    final matchingPlan = exercisePlans.firstWhere(
      (plan) => plan.id == widget.trainingSession.exerciseTableId,
    );
    //print("✅ Znaleziono plan: ${matchingPlan.exercise_table}");
    return matchingPlan.exercise_table;
  } catch (e) {
    print("❌ Nie znaleziono planu ID=${widget.trainingSession.exerciseTableId}: $e");
    
    // ✅ FALLBACK 1: Użyj exercise_table_name z sesji
    if (widget.trainingSession.exercise_table_name!.isNotEmpty) {
      return widget.trainingSession.exercise_table_name;
    }
    
    // ✅ FALLBACK 2: Użyj description
    if (widget.trainingSession.description.isNotEmpty) {
      return widget.trainingSession.description;
    }
    
    // ✅ FALLBACK 3: Generyczna nazwa
    return 'Workout #${widget.trainingSession.id}';
  }
}

  String _getUserName() {
    final authResponse = ref.watch(authProviderLogin);
    return authResponse!.user?.name ?? 'User';
  }

  String? _getExerciseName(String exerciseId) {

    final exerciseState = ref.watch(exerciseProvider);

    return exerciseState.when(
      data:  (allExercise) {
        try {
          final exercise = allExercise.firstWhere((ex) => ex.exerciseId == exerciseId);
         // print("✅ Znaleziono ćwiczenie: ${exercise.name}");
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
  
  String? _getExerciseImage(String exerciseId) {
    final exerciseData = ref.watch(exerciseProvider);

    return exerciseData.when(
      data: (allExercise) {
        try {
          final exercise = allExercise.firstWhere((ex) => ex.exerciseId == exerciseId);
         // print("✅ Znaleziono obrazek ćwiczenia: ${exercise.gifUrl}");
          return exercise.gifUrl ?? '';
        } catch (e) {
          print("❌ Nie znaleziono obrazka ćwiczenia o ID: $exerciseId");
          return '';
        }
      },
      error: (error, stackTrace) {
        print("❌ Błąd podczas pobierania obrazków ćwiczeń: $error");
        return '';
      },
      loading: () => '',
    );

  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.all(16.0),
      // ✅ ZAMIEŃ GestureDetector na OpenContainer z animations
      child: OpenContainer<bool>(
        transitionType: ContainerTransitionType.fade,
        transitionDuration: Duration(milliseconds: 500),
        openColor: Theme.of(context).colorScheme.surface,
        closedColor: Colors.transparent,
        openShape: RoundedRectangleBorder(),
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        openElevation: 0,
        closedElevation: 2,
        
        // ✅ WIDGET ZAMKNIĘTY (karta)
        closedBuilder: (context, action) => Card(
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // ✅ DODAJ - pozwala na minimalizację rozmiaru
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
                        Icons.person,
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
                Row(
                  children: [
                    Expanded( // ✅ DODAJ EXPANDED dla długich tytułów
                      child: Text(
                        _getWorkoutTitle() ?? "Workout",
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 2, // ✅ OGRANICZ do 2 linii
                        overflow: TextOverflow.ellipsis, // ✅ DODAJ ellipsis
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                
                // ✅ STATYSTYKI - zrób scrollowalne poziomo
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
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
                
                // ✅ LISTA ĆWICZEŃ - OGRANICZAJ WYSOKOŚĆ
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 80, // ✅ MAKSYMALNA WYSOKOŚĆ 80px
                  ),
                  child: widget.trainingSession.exercises.length > 1
                    ? _buildCompactExerciseList() // ✅ KOMPAKTOWA LISTA dla > 1 ćwiczeń
                    : _buildFullExerciseList(), // ✅ PEŁNA LISTA dla ≤ 1 ćwiczeń
                ),
              ],
            ),
          ),
        ),
        
        // ✅ WIDGET OTWARTY (WorkoutCardInfo)
        openBuilder: (context, action) => WorkoutCardInfo(
          trainingSession: widget.trainingSession,
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

  Widget _buildCompactExerciseList() {
    return Column(
         mainAxisSize: MainAxisSize.min, // ✅ DODAJ - pozwala na minimalizację rozmiaru
      children: [
        // ✅ POKAŻ PIERWSZE 2 ĆWICZENIA
        ...widget.trainingSession.exercises.take(2).map((exercise) => 
          _buildExerciseRow(exercise, isCompact: true)
        ),
        
        // ✅ POKAŻ "i X więcej..." jeśli jest więcej niż 2
        if (widget.trainingSession.exercises.length > 2)
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.more_horiz,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
                ),
                SizedBox(width: 6),
                Text(
                  "+ ${widget.trainingSession.exercises.length - 2} more exercises",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
                    fontStyle: FontStyle.italic,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ✅ DODAJ NOWĄ METODĘ - pełna lista ćwiczeń
Widget _buildFullExerciseList() {
  return Column( // ✅ ZMIEŃ Z ListView.builder NA Column
    mainAxisSize: MainAxisSize.min, // ✅ DODAJ
    children: widget.trainingSession.exercises
        .take(2) // ✅ MAKSYMALNIE 2 ĆWICZENIA
        .map((exercise) => _buildExerciseRow(exercise, isCompact: false))
        .toList(),
  );
}

  // ✅ DODAJ NOWĄ METODĘ - pojedynczy rząd ćwiczenia
  Widget _buildExerciseRow(exercise, {required bool isCompact}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: isCompact ? 4.0 : 8.0, // ✅ Mniejszy padding dla kompaktowej wersji
      ),
      child: Row(
        children: [
          // ✅ Ikona na początku
          Container(
            width: isCompact ? 30 : 40, // ✅ Mniejsza ikona dla kompaktowej wersji
            height: isCompact ? 30 : 40,
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
                    size: isCompact ? 15 : 20,
                    color: Theme.of(context).colorScheme.primary,
                  );
                }
                
                // ✅ JEŚLI JEST OBRAZEK - POKAŻ OBRAZEK
                return ImageUtils.buildImage(
                  imageUrl: imageUrl,
                  context: context,
                  width: isCompact ? 30 : 40,
                  height: isCompact ? 30 : 40,
                  fit: BoxFit.cover,
                  placeholder: Icon(
                    Icons.fitness_center,
                    size: isCompact ? 15 : 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              }(),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text(
                  "Sets: ${exercise.sets.length} ",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: isCompact ? 11 : null, // ✅ Mniejszy tekst dla kompaktowej wersji
                  ),
                ),
                
                // ✅ NAZWA ĆWICZENIA
                Expanded(
                  child: Text(
                    _getExerciseName(exercise.exerciseId) ?? "Unknown Exercise",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: isCompact ? 12 : null, // ✅ Mniejszy tekst dla kompaktowej wersji
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
    );
  }
}
