import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';

class ExerciseInfoScreen extends ConsumerStatefulWidget{
  const ExerciseInfoScreen({super.key,required this.exercise});

  final Exercise exercise;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ExerciseInfoScreenState();
  }
}
class _ExerciseInfoScreenState extends ConsumerState<ExerciseInfoScreen>{

  

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
      return Scaffold( 
        appBar: AppBar(
          title: Text(exercise.name),
          ),
          );
  }

}