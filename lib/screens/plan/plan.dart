import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/current_workout.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/provider/exercise_plan_notifier.dart';
import 'package:work_plan_front/provider/auth_provider.dart';
import 'package:work_plan_front/provider/current_workout_plan_provider.dart';
import 'package:work_plan_front/provider/exercise_provider.dart';
import 'package:work_plan_front/provider/plan_groups_notifier.dart';
import 'package:work_plan_front/provider/wordout_time_notifer.dart';
import 'package:work_plan_front/screens/plan/plan_group_widget.dart';
import 'package:work_plan_front/screens/plan/widget/dialog_to_add_group.dart';
import 'package:work_plan_front/screens/plan_creation.dart';
import 'package:work_plan_front/widget/plan/plan_works/plan_selected/plan_selected_list.dart';
import 'dart:async' show scheduleMicrotask, Timer;

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _PlanScreenState();
  }
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  final ScrollController _mainScrollController = ScrollController();
  Timer? _timer;
  bool isTimerRunning = false;
  int seconds = 0;

  bool _hasInitializedGroups = false;
  @override
  void initState() {
    super.initState();
    // Usunięto automatyczne odświeżanie/fetchowanie danych przy starcie
    scheduleMicrotask(() async {
      try {
        await ref.read(exercisePlanProvider.notifier).fetchExercisePlans();
        await ref.read(exerciseProvider.notifier).fetchExercises();
      } catch (e) {
        print("❌ Błąd ładowania danych w plan.dart: $e");
      }
    });
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  void openShowPlanScreen(
    BuildContext context,
    ExerciseTable plan,
    List<Exercise> filteredExercises,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (ctx) => PlanSelectedList(
              plan: plan,
              exercises: filteredExercises,
              onStartWorkout: () {
                // Możesz dodać obsługę rozpoczęcia treningu
              },
              isReadOnly: false,
              isWorkoutMode: true,
            ),
      ),
    );
  }

  List<Exercise> getFilteredExercise(
    ExerciseTable plan,
    List<Exercise> allExercises,
  ) {
    final planExerciseIds = plan.rows.map((row) => row.exercise_number).toSet();

    print(
      "🔍 Plan '${plan.exercise_table}' zawiera exerciseIds: $planExerciseIds",
    );

    final filteredExercises =
        allExercises.where((ex) {
          return planExerciseIds.contains(ex.exerciseId);
        }).toList();

    print("✅ Znaleziono ${filteredExercises.length} ćwiczeń dla planu");
    return filteredExercises;
  }

  void deletePlan(ExerciseTable plan, BuildContext context, int planID) {
    if (!context.mounted) {
      print("❌ Context is not mounted - cannot delete plan");
      return;
    }

    ref.read(planGroupsProvider.notifier).removePlanFromGroups(plan, '');

    // POTEM USUŃ Z BACKENDU
    ref
        .read(exercisePlanProvider.notifier)
        .deleteExercisePlan(planID)
        .then((_) {
          // ✅ SUKCES - plan usunięty
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Plan ${plan.exercise_table} deleted successfully.",
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        })
        .catchError((error) {
          // ✅ BŁĄD - przywróć plan do grup
          print("❌ Błąd usuwania planu: $error");
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Failed to delete plan: $error"),
                backgroundColor: Colors.red,
              ),
            );
          }

          //  Przywróć plan do oryginalnej grupy
        });
  }

  void openPlanCreation(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (ctx) => PlanCreation())).then((_) {
      //  PO POWROCIE RESETUJ FLAGĘ I WYMUŚ SPRAWDZENIE NOWYCH PLANÓW
      print("🔄 Powrót z tworzenia planu - resetuję flagę");
      _hasInitializedGroups = false;

      //  DELAY, ŻEBY DANE ZDĄŻYŁY SIĘ ZAŁADOWAĆ
      Future.delayed(Duration(milliseconds: 500), () {
        final exercisePlans = ref.read(exercisePlanProvider);
        if (exercisePlans.isNotEmpty) {
          ref
              .read(planGroupsProvider.notifier)
              .initializeWithPlans(exercisePlans);
          _hasInitializedGroups = true;
        }
      });
    });
  }

  // void editPlan(ExerciseTable plan, BuildContext context) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder:
  //           (ctx) => PlanCreation(
  //             // exerciseTable: plan,
  //           ),
  //     ),
  //   );
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(SnackBar(content: Text("in develop.")));
  // }

  void _openPlanForEditing(ExerciseTable plan) {
    print(
      "✏️ Opening plan for editing: ${plan.exercise_table} (ID: ${plan.id})",
    );

    // ✅ POBIERZ NAJNOWSZE DANE PRZED EDYCJĄ
    final currentPlans = ref.read(exercisePlanProvider);
    final currentPlan = currentPlans.firstWhere(
      (p) => p.id == plan.id,
      orElse: () => plan,
    );

    print("📊 Plan data before editing:");
    print("  - Widget plan title: '${plan.exercise_table}'");
    print("  - Provider plan title: '${currentPlan.exercise_table}'");
    print(
      "  - Using: ${currentPlan.exercise_table == plan.exercise_table ? 'SAME' : 'PROVIDER VERSION'}",
    );

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder:
                (ctx) => PlanCreation(
                  planToEdit: currentPlan,
                ), // ✅ PRZEKAŻ AKTUALNY PLAN
          ),
        )
        .then((_) {
          print("🔄 Powrót z edycji planu - pełne odświeżenie danych");
          _resetGroupsFlag();

          ref.read(exercisePlanProvider.notifier).fetchExercisePlans().then((
            _,
          ) {
            final refreshedPlans = ref.read(exercisePlanProvider);
            ref
                .read(planGroupsProvider.notifier)
                .initializeWithPlans(refreshedPlans);
          });
        });
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
              Icon(Icons.login, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Please log in',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                'Log in to see your training calendar',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
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
        loading: () => Center(),

        // ✅ ERROR STATE
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error loading exercises: $error'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(exerciseProvider.notifier)
                          .fetchExercises(forceRefresh: true);
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),

        // ✅ DATA STATE - TUTAJ JEST LISTA ĆWICZEŃ
        data:
            (allExercises) => _buildPlanContent(
              context,
              exercisePlans,
              allExercises,
              timer,
              timerController,
            ),
      ),
    );
  }

  Widget _createNewPlan() {
    return TextButton.icon(
      onPressed: () => openPlanCreation(context),
      icon: Icon(Icons.add),
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
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
    final planGroups = ref.watch(planGroupsProvider);
    if (!_hasInitializedGroups && exercisePlans.isNotEmpty) {
      print(
        "📋 Jednorazowa inicjalizacja grup z ${exercisePlans.length} planami...",
      );

      Future.microtask(() {
        ref
            .read(planGroupsProvider.notifier)
            .initializeWithPlans(exercisePlans);
      });

      _hasInitializedGroups = true;
      print("✅ Flaga inicjalizacji ustawiona na true");
    }

    // ✅ PROSTSZE SPRAWDZENIE - inicjalizuj jeśli brak grup ale są plany
    if (planGroups.isEmpty && exercisePlans.isNotEmpty) {
      print("📋 Pierwsza inicjalizacja grup...");
      Future.microtask(() {
        ref
            .read(planGroupsProvider.notifier)
            .initializeWithPlans(exercisePlans);
      });
    }

    void showPlanBottomSheet(
      BuildContext context,
      ExerciseTable plan,
      List<Exercise> allExercises,
    ) {
      final filteredExercises = getFilteredExercise(plan, allExercises);
      openShowPlanScreen(context, plan, filteredExercises);
    }

    return Listener(
      onPointerMove: (event) {
        // Przekaż pozycję do auto-scroll w każdej grupie
        PlanGroupWidget.globalPointerDy = event.position.dy;
        PlanGroupWidget.globalAutoScrollCallback?.call();
      },
      onPointerUp: (_) {
        PlanGroupWidget.globalPointerDy = null;
        PlanGroupWidget.globalStopAutoScrollCallback?.call();
      },
      child: ListView(
        controller: _mainScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
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
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
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
          SizedBox(width: double.infinity, child: _createNewPlan()),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your plans (${exercisePlans.length})",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddGroupDialog(context),
                icon: Icon(Icons.add, size: 18),
                label: Text("Add Group"),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
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
          else if (planGroups.isEmpty)
            Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Organizing plans into groups..."),
                  SizedBox(height: 8),
                  Text(
                    "Plans loaded: ${exercisePlans.length}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )
          else
            ...planGroups.map(
              (group) => PlanGroupWidget(
                key: ValueKey("group_${group.name}_${exercisePlans.length}"),
                group: group,
                allExercises: allExercises,
                onStartWorkout: (plan, filteredExercises) {
                  if (timerController.currentTime == 0) {
                    timerController.startTimer();
                  }
                  ref.read(currentWorkoutPlanProvider.notifier).state =
                      Currentworkout(plan: plan, exercises: filteredExercises);
                  showPlanBottomSheet(context, plan, allExercises);
                },
                onDeletePlan: deletePlan,
                onCreateNewPlan: () => openPlanCreation(context),
                mainScrollController: _mainScrollController,
              ),
            ),
        ],
      ),
    );
  }

  // ✅ DODAJ METODĘ DODAWANIA GRUP
  void _showAddGroupDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => buildAddGroupDialog(context, controller, ref),
    );
  }

  void _resetGroupsFlag() {
    print("🔄 Resetowanie flagi grup");
    _hasInitializedGroups = false;
  }
}
