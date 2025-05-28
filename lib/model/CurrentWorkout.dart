import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/model/exercise_plan.dart';

class Currentworkout {
  final ExerciseTable? plan;
  final List<Exercise> exercises;

  Currentworkout({
    required this.plan,
    required this.exercises,
  });
}