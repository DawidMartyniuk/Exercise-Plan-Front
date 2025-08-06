import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import 'package:work_plan_front/model/TrainingSesions.dart';
import 'package:work_plan_front/provider/ExercisePlanNotifier.dart';
import 'package:work_plan_front/provider/authProvider.dart';
import 'package:work_plan_front/provider/exerciseProvider.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard_info.dart';
import 'package:work_plan_front/utils/imge_untils.dart';

class WorkoutCard extends ConsumerStatefulWidget {
  final TrainingSession trainingSession;
  final bool showAsFullScreen; // ✅ NOWY PARAMETR
  final List<TrainingSession>? allSessionsForDate; // ✅ LISTA WSZYSTKICH SESJI DLA DNIA

  const WorkoutCard({
    super.key, 
    required this.trainingSession,
    this.showAsFullScreen = false, // ✅ DOMYŚLNIE FALSE
    this.allSessionsForDate, // ✅ OPCJONALNA LISTA
  });

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
  if (exercisePlans.isEmpty) {
    print("⚠️ Brak planów - używam exercise_table_name z sesji");
    if (widget.trainingSession.exercise_table_name!.isNotEmpty) {
      return widget.trainingSession.exercise_table_name;
    }
    return "Workout #${widget.trainingSession.id}";
  }

  try {
    final matchingPlan = exercisePlans.firstWhere(
      (plan) => plan.id == widget.trainingSession.exerciseTableId,
    );
    return matchingPlan.exercise_table;
  } catch (e) {
    print("❌ Nie znaleziono planu ID=${widget.trainingSession.exerciseTableId}: $e");
    
    if (widget.trainingSession.exercise_table_name!.isNotEmpty) {
      return widget.trainingSession.exercise_table_name;
    }
    
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
    // ✅ JEŚLI showAsFullScreen = true, POKAŻ JAKO OSOBNY EKRAN
    if (widget.showAsFullScreen) {
      return _buildFullScreenView();
    }

    // ✅ DOMYŚLNY WIDOK (dla RecentWorkoutsSection)
    return _buildCardView();
  }

  // ✅ NOWY - WIDOK PEŁNOEKRANOWY Z APPBAR
  Widget _buildFullScreenView() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getWorkoutTitle() ?? "Workout Details",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ JEŚLI JEST WIĘCEJ NIŻ 1 SESJA NA DZIEŃ - POKAŻ WSZYSTKIE
            if (widget.allSessionsForDate != null && widget.allSessionsForDate!.length > 1)
              ...widget.allSessionsForDate!.map((session) => 
                _buildFullWorkoutCard(session)
              ).toList()
            else
              _buildFullWorkoutCard(widget.trainingSession),
          ],
        ),
      ),
    );
  }

  // ✅ PEŁNA KARTA TRENINGU (bez ograniczeń wysokości)
  Widget _buildFullWorkoutCard(TrainingSession session) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ HEADER
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
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
                    size: 25,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getUserName(),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        _getDaysAgo(session.startedAt),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.0),
            
            // ✅ TYTUŁ TRENINGU
            Text(
              _getWorkoutTitleForSession(session) ?? "Workout",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16.0),
            
            // ✅ STATYSTYKI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                  "Time",
                  _formatDuration(session.duration),
                  context,
                ),
                _buildStatColumn(
                  "Volume",
                  "${session.totalWeight.toInt()}kg",
                  context,
                ),
                _buildStatColumn("Sets", "${_getTotalSetsForSession(session)}", context),
                _buildStatColumn("Reps", "${_getTotalRepsForSession(session)}", context),
              ],
            ),
            
            SizedBox(height: 16.0),
            Divider(color: Theme.of(context).dividerColor),
            SizedBox(height: 16.0),
            
            // ✅ WSZYSTKIE ĆWICZENIA (bez limitu)
            Text(
              "Exercises:",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            
            ...session.exercises.map((exercise) => 
              _buildFullExerciseRow(exercise)
            ).toList(),
            
            SizedBox(height: 16.0),
            
            // ✅ PRZYCISK SZCZEGÓŁÓW
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WorkoutCardInfo(
                        trainingSession: session,
                      ),
                    ),
                  );
                },
                child: Text("View Detailed Stats"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ DOMYŚLNY WIDOK KARTY (dla RecentWorkoutsSection)
  Widget _buildCardView() {
    return Container(
      padding: EdgeInsets.all(16.0),
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
        
        closedBuilder: (context, action) => Card(
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                    Expanded( 
                      child: Text(
                        _getWorkoutTitle() ?? "Workout",
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
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 80,
                  ),
                  child: widget.trainingSession.exercises.length > 1
                    ? _buildCompactExerciseList()
                    : _buildFullExerciseList(), 
                ),
              ],
            ),
          ),
        ),
        openBuilder: (context, action) => WorkoutCardInfo(
          trainingSession: widget.trainingSession,
        ),
      ),
    );
  }

  // ✅ POMOCNICZE METODY DLA PEŁNEGO WIDOKU
  String? _getWorkoutTitleForSession(TrainingSession session) {
    final exercisePlans = ref.watch(exercisePlanProvider);
    
    if (exercisePlans.isEmpty) {
      return session.exercise_table_name?.isNotEmpty == true 
          ? session.exercise_table_name 
          : "Workout #${session.id}";
    }

    try {
      final matchingPlan = exercisePlans.firstWhere(
        (plan) => plan.id == session.exerciseTableId,
      );
      return matchingPlan.exercise_table;
    } catch (e) {
      return session.exercise_table_name?.isNotEmpty == true 
          ? session.exercise_table_name 
          : "Workout #${session.id}";
    }
  }

  int _getTotalSetsForSession(TrainingSession session) {
    return session.exercises
        .map((ex) => ex.sets.length)
        .fold(0, (sum, sets) => sum + sets);
  }

  int _getTotalRepsForSession(TrainingSession session) {
    return session.exercises
        .map(
          (ex) => ex.sets
              .map((set) => set.actualReps)
              .fold(0, (sum, reps) => sum + reps),
        )
        .fold(0, (sum, reps) => sum + reps);
  }

  Widget _buildFullExerciseRow(exercise) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withAlpha(100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
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
                
                if (imageUrl == null || imageUrl.isEmpty) {
                  return Icon(
                    Icons.fitness_center,
                    size: 25,
                    color: Theme.of(context).colorScheme.primary,
                  );
                }
                
                return ImageUtils.buildImage(
                  imageUrl: imageUrl,
                  context: context,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: Icon(
                    Icons.fitness_center,
                    size: 25,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              }(),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getExerciseName(exercise.exerciseId) ?? "Unknown Exercise",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "${exercise.sets.length} sets",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // statystyki z opisami
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
// widget z ćwiczeniami
  Widget _buildCompactExerciseList() {
    return Column(
         mainAxisSize: MainAxisSize.min, 
      children: [
        // ✅ POKAŻ PIERWSZE 2 ĆWICZENIA
        ...widget.trainingSession.exercises.take(2).map((exercise) => 
          _buildExerciseRow(exercise, isCompact: true)
        ),
        
      
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

//wszytskie ćwiczenia
Widget _buildFullExerciseList() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: widget.trainingSession.exercises
        .take(2) // max 2
        .map((exercise) => _buildExerciseRow(exercise, isCompact: false))
        .toList(),
  );
}

  // pojedynczy rząd ćwiczenia
  Widget _buildExerciseRow(exercise, {required bool isCompact}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: isCompact ? 4.0 : 8.0,
      ),
      child: Row(
        children: [
     
          Container(
            width: isCompact ? 30 : 40, 
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
                    fontSize: isCompact ? 11 : null, 
                  ),
                ),
                
                // ✅ NAZWA ĆWICZENIA
                Expanded(
                  child: Text(
                    _getExerciseName(exercise.exerciseId) ?? "Unknown Exercise",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: isCompact ? 12 : null,
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
