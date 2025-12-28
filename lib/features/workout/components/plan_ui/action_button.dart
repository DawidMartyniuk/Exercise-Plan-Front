import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/features/workout/screens/plan_works.dart';

class ActionButton extends StatelessWidget {
  final bool isReadOnly;
  final bool isWorkoutMode;
  // final VoidCallback onAddExercises;
  final VoidCallback addMultipleExercisesToPlan;
  final VoidCallback onEndWorkout;
  final Exercise exercises;
  final ExerciseTable plan; // ZASTĄP DYNAMIC ODPOWIEDNIM MODELEM
  // Removed BuildContext context; context is available in build()

  const ActionButton({super.key, 
    required this.isReadOnly,
    required this.isWorkoutMode,
    required this.exercises,
    //required this.onAddExercises,
    required this.addMultipleExercisesToPlan,
    required this.onEndWorkout,
    required this.plan,
  });

@override
  Widget build(BuildContext context) {
    return
     _buildActionButtons(context);
  }

  Widget _buildActionButtons(BuildContext context) {
  if (isReadOnly && !isWorkoutMode) {
    // TRYB PODGLĄDU - TYLKO PRZYCISK STARTU TRENINGU
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => PlanWorks(
                    plan: plan,
                    exercises: [exercises],
                    isReadOnly: false,
                    isWorkoutMode: true,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.fitness_center),
            label: const Text("Start Workout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  } else if (isWorkoutMode) {
    //  TRYB TRENINGU - WSZYSTKIE PRZYCISKI TRENINGOWE
    return Column(
      children: [
        //  POJEDYNCZY PRZYCISK DODAWANIA ĆWICZEŃ
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: addMultipleExercisesToPlan, //  UŻYJ METODY MULTI-SELECT
            icon: const Icon(Icons.add),
            label: const Text("Add Exercises"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
         
        //  PRZYCISK ZAKOŃCZ TRENING
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onEndWorkout,
            label: const Text("End Workout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  } else {
    //  TRYB EDYCJI PLANU - PRZYCISKI EDYCYJNE
    return Column(
      children: [
        //  POJEDYNCZY PRZYCISK DODAWANIA ĆWICZEŃ
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: addMultipleExercisesToPlan, //  UŻYJ METODY MULTI-SELECT
            icon: const Icon(Icons.add),
            label: const Text("Add Exercises"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        //  START WORKOUT
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => PlanWorks(
                    plan: plan, // assuming 'plan' has a property 'plan' of type ExerciseTable
                    exercises: [exercises], // update as needed to pass correct exercises
                    isReadOnly: false,
                    isWorkoutMode: true,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.fitness_center),
            label: const Text("Start Workout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
  }
