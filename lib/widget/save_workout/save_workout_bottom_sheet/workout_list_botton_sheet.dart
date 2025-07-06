import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';

class WorkoutListBottonSheet extends StatelessWidget{
 // final List<String> workouts;
  final Function(String) onWorkoutSelected;
  //final List<Exercise> exercises;
  final List<Exercise> selectedExercises;
  final Map<BodyPart, int> exercisesCount;

  const WorkoutListBottonSheet({
    super.key,
    //required this.workouts,
    required this.onWorkoutSelected,
  //  required this.exercises,
    required this.selectedExercises,
    required this.exercisesCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Zaznaczone ćwiczenia:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...selectedExercises.map((ex) => ListTile(
                  leading: Icon(Icons.fitness_center),
                  title: Text(ex.name),
                  subtitle: Text("Partia: ${ex.bodyPart}"),
                )),
          ],
        ),
      ),
    );
  }
}