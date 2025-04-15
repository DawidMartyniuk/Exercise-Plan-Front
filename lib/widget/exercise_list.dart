import 'package:flutter/material.dart';
import 'package:work_plan_front/data/exercise_data.dart';
import 'package:work_plan_front/model/exercise.dart';

class ExerciseList  extends StatefulWidget{
 const ExerciseList({
    super.key,
    required this.exercise,
  });
  final List<Exercise> exercise;
  
  @override
  State<StatefulWidget> createState() {
    return __ExerciseListState();
  }

}
class __ExerciseListState extends State<ExerciseList> {

  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.exercise.length,
      itemBuilder: (BuildContext context, int index) {
        final exercise = widget.exercise[index];
        return Card(
          child: ListTile(
            leading: Image.network(exercise.gifUrl, width: 50, height: 50),
            title: Text(exercise.name, style: Theme.of(context).textTheme.titleMedium),
          
            trailing: const Icon(Icons.arrow_forward),
          ),
        );
      },
    );
  }
 
}