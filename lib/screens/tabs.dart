import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/provider/ExercisePlanNotifier.dart';
import 'package:work_plan_front/provider/current_workout_plan_provider.dart';
import 'package:work_plan_front/screens/exercises.dart';
import 'package:work_plan_front/screens/start.dart';
import 'package:work_plan_front/screens/profil.dart';
import 'package:work_plan_front/screens/plan/plan.dart';
import 'package:work_plan_front/utils/workout_utils.dart';
import 'package:work_plan_front/widget/bottom_button_app_bar.dart';
import 'package:work_plan_front/provider/wordoutTimeNotifer.dart';
import 'package:work_plan_front/widget/plan/plan_list/plan_selected_list.dart';

class TabsScreen extends ConsumerStatefulWidget {
  final int selectedPageIndex;

  const TabsScreen({super.key, this.selectedPageIndex = 0});

  @override
  ConsumerState<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  int _selectedPageIndex = 0;
  //Timer? _timer;
  bool isTimerRunning = false;
 //  final isRunning = ref.watch(workoutProvider) > 0;
  int seconds = 0;

  final List<Widget> _pages = [
    Startscreen(),
    ExercisesScreen(),
    PlanScreen(),
    ProfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedPageIndex = widget.selectedPageIndex;
  }

  void _selectPage(int indexPage) {
    setState(() {
      _selectedPageIndex = indexPage;
    });
  }

  void activePlan() {
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {

    final timeValue = ref.watch(workoutProvider);
   // final timerController = ref.watch(workoutProvider.notifier);
    final isRunning = timeValue > 0;
    final curentWorkout = ref.watch(currentWorkoutPlanProvider);
    
   void _endWorkout(BuildContext context) {
    final currentWorkout = ref.read(currentWorkoutPlanProvider);
    if (currentWorkout?.plan != null) {
      // Resetuj plan w providerze z listą planów
      ref.read(exercisePlanProvider.notifier).resetPlanById(currentWorkout!.plan!.id);

      // Resetuj plan w currentWorkout (lokalnie)
      resetPlanRows(currentWorkout.plan!);
    }
    endWorkoutGlobal(context: context, ref: ref);
  }


    void backWorkout() {
      print('Back button pressed');
      if (curentWorkout != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (ctx) => PlanSelectedList(
                  exercises: curentWorkout.exercises,
                  plan: curentWorkout.plan!,
                ),
          ),
        );
      } else {
        print('Brak aktywnego planu treningowego!');
      }
    }

    return Scaffold(
      body: _pages[_selectedPageIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isRunning)
            BottomButtonAppBar(
              onBack: () {
                backWorkout();
              },
              onEnd: () => _endWorkout(context),
            ),
          BottomNavigationBar(
            selectedLabelStyle: TextStyle(),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainer.withAlpha((0.01 * 255).toInt()),
            selectedItemColor: Theme.of(context).colorScheme.onSurface,
            unselectedItemColor: Theme.of(
              context,
            ).colorScheme.secondary.withAlpha((0.95 * 255).toInt()),

            currentIndex: _selectedPageIndex,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,

            onTap: _selectPage,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.fitness_center),
                label: 'Exercises',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'Plan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
