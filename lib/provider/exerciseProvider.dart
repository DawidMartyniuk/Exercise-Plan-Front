import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/serwis/exerciseService.dart';
import 'package:hive/hive.dart';

class ExerciseNotifier extends StateNotifier<List<Exercise>?> {
  ExerciseNotifier() : super(null);

  final ExerciseService _exerciseService = ExerciseService();


Future<void> fetchExercises() async {
  final exercises = await _exerciseService.exerciseList();
  if (exercises != null) {
    print('Fetched exercises: ${exercises.length}');
    state = exercises; 
  } else {
    print('No exercises fetched'); 
    state = [];
  }
}


  void clearExercises() {
    state = [];
  }
}



final exerciseProvider = StateNotifierProvider<ExerciseNotifier, List<Exercise>?>(
  (ref) => ExerciseNotifier(),
);