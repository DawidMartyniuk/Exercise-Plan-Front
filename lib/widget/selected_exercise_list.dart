import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';

class SelectedExerciseList extends StatelessWidget {
  final List<Exercise> exercises;
  final void Function(Exercise exercise) onDelete;

  const SelectedExerciseList({
    Key? key,
    required this.exercises,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return Card(
          child: ListTile(
            title: Text(exercise.name),
            subtitle: Text("Body Part: ${exercise.bodyPart}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                onDelete(exercise);
              },
            ),
          ),
        );
      },
    );
  }
}