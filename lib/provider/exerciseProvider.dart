import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/serwis/exerciseService.dart';

class ExerciseNotifier extends StateNotifier<List<Exercise>?> {
  ExerciseNotifier() : super(null);

  final ExerciseService _exerciseService = ExerciseService();

  // Pobieranie listy ćwiczeń z API
  Future<void> fetchExercises() async {
    final exercises = await _exerciseService.exerciseList();
    if (exercises != null) {
      state = exercises; // Ustawienie stanu na listę ćwiczeń
    } else {
      state = []; // Ustawienie pustej listy w przypadku błędu
    }
  }

  // Czyszczenie listy ćwiczeń
  void clearExercises() {
    state = [];
  }
}

// Provider dla ExerciseNotifier
final exerciseProvider = StateNotifierProvider<ExerciseNotifier, List<Exercise>?>(
  (ref) => ExerciseNotifier(),
);