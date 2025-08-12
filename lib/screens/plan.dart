import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/CurrentWorkout.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/provider/ExercisePlanNotifier.dart';
import 'package:work_plan_front/provider/authProvider.dart';
import 'package:work_plan_front/provider/current_workout_plan_provider.dart';
import 'package:work_plan_front/provider/exerciseProvider.dart';
import 'package:work_plan_front/provider/wordoutTimeNotifer.dart';
import 'package:work_plan_front/screens/plan_creation.dart';
import 'package:work_plan_front/widget/plan/plan_list/plan_card_more_option.dart';
import 'package:work_plan_front/widget/plan/plan_list/plan_selected_list.dart';
import 'dart:async' show scheduleMicrotask, Timer;

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _PlanScreenState();
  }
}

void openPlanCreation(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => PlanCreation()));
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  Timer? _timer;
  bool isTimerRunning = false;
  int seconds = 0;

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() async {
      try {
        await ref.read(exercisePlanProvider.notifier).fetchExercisePlans();
        await ref.read(exerciseProvider.notifier).fetchExercises();
      } catch (e) {
        print("❌ Błąd ładowania danych w plan.dart: $e");
      }
    });
  }

  void OpenShowPlanScreen(BuildContext context, ExerciseTable plan, List<Exercise> filteredExercises) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => PlanSelectedList(
          plan: plan,
          exercises: filteredExercises,
          onStartWorkout: () {
            // Możesz dodać obsługę rozpoczęcia treningu
          },
        ),
      ),
    );
  }

  List<Exercise> getFilteredExercise(ExerciseTable plan, List<Exercise> allExercises) {
  final planExerciseIds = plan.rows.map((row) => row.exercise_number).toSet();
  
  print("🔍 Plan '${plan.exercise_table}' zawiera exerciseIds: $planExerciseIds");
  
  final filteredExercises = allExercises.where((ex) {
    return planExerciseIds.contains(ex.exerciseId);
  }).toList();
  
  print("✅ Znaleziono ${filteredExercises.length} ćwiczeń dla planu");
  return filteredExercises;
}

  void deletePlan(ExerciseTable plan, BuildContext context, int planID) {
    ref.read(exercisePlanProvider.notifier).deleteExercisePlan(planID);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Plan ${plan.exercise_table} deleted successfully."),
      ),
    );
  }

  void editPlan(ExerciseTable plan, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => PlanCreation(
          // exerciseTable: plan,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("in develop."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

final authResponse = ref.watch(authProviderLogin);
     if (authResponse == null) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withAlpha(127),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.login,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                'Please log in',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Log in to see your training calendar',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final timer = ref.watch(workoutProvider);
    final timerController = ref.watch(workoutProvider.notifier);
    final exercisePlans = ref.watch(exercisePlanProvider);
    
    // ✅ POPRAWKA: Obsłuż AsyncValue<List<Exercise>>
    final exerciseState = ref.watch(exerciseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 2,
      ),
      body: exerciseState.when(
        // ✅ LOADING STATE
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading exercises...'),
            ],
          ),
        ),
        
        // ✅ ERROR STATE
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Error loading exercises: $error'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(exerciseProvider.notifier).fetchExercises(forceRefresh: true);
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
        
        // ✅ DATA STATE - TUTAJ JEST LISTA ĆWICZEŃ
        data: (allExercises) => _buildPlanContent(
          context,
          exercisePlans,
          allExercises,
          timer,
          timerController,
        ),
      ),
    );
  }

  // ✅ WYDZIEL GŁÓWNĄ ZAWARTOŚĆ DO OSOBNEJ METODY
  Widget _buildPlanContent(
    BuildContext context,
    List<ExerciseTable> exercisePlans,
    List<Exercise> allExercises,
    dynamic timer,
    dynamic timerController,
  ) {
    void showPlanBottomSheet(
      BuildContext context,
      ExerciseTable plan,
      List<Exercise> allExercises,
    ) {
      final filteredExercises = getFilteredExercise(plan, allExercises);
      OpenShowPlanScreen(context, plan, filteredExercises);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Start Now",
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.add),
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              label: Text(
                "Start Empty Workout",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Create plan",
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => openPlanCreation(context),
              icon: Icon(Icons.add),
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              label: Text(
                "Create exercise plan",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              "Your plans",
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: 20),

          // ✅ WYŚWIETLANIE LISTY PLANÓW
          if (exercisePlans.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No plans available."),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => openPlanCreation(context),
                    child: Text("Create your first plan"),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              itemCount: exercisePlans.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final plan = exercisePlans[index];
                return Card(
                  color: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).toInt()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 16.0,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plan.exercise_table,
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            PlanCardMoreOption( 
                              onDeletePlan: () => deletePlan(plan, context, plan.id),
                              plan: plan,
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            plan.rows.map((row) => row.exercise_name).join(", "),
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).toInt()),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            ),
                            onPressed: () {
                              timerController.startTimer();
                              final filteredExercises = getFilteredExercise(plan, allExercises);
                              ref.read(currentWorkoutPlanProvider.notifier).state = Currentworkout(
                                plan: plan,
                                exercises: filteredExercises,
                              );
                              showPlanBottomSheet(context, plan, allExercises);
                            },
                            child: Text(
                              "Start workout",
                              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
