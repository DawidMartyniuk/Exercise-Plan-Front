import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/serwis/exercisePlan.dart';
import 'package:work_plan_front/utils/tokenStorage.dart';

class ExercisePlanNotifier extends StateNotifier<ExercisePlan?> {
  ExercisePlanNotifier() : super(null);

  final ExerciseService _exerciseService = ExerciseService();

  // Pobierz wszystkie plany ćwiczeń z bazy danych
  Future<void> fetchExercisePlans() async {
    try {
      final exercisePlans = await _exerciseService.fetchExercises();
      if (exercisePlans.isNotEmpty) {
        state = exercisePlans.first; 
      }
      print("Fetched exercise plans: $exercisePlans");
    } catch (e) {
      print("Failed to fetch exercise plans: $e");
    }
  } 

  //zapis 
Future<void> initializeExercisePlan(Map<String, dynamic> exercisesData) async {
  final userId = await _getLoggedInUserId();
  if (userId == null) {
    print("User is not logged in.");
    return;
  }

  final exercises = (exercisesData["exercises"] as List<dynamic>)
      .map((exercise) => ExerciseTable.fromJson(exercise as Map<String, dynamic>))
      .toList();

  state = ExercisePlan(
    userId: userId,
    exercises: exercises,
  );

  print("Exercise plan initialized for user $userId.");
}


  Future<void> saveExercisePlan() async {
    if (state == null) {
      print("No exercise plan to save.");
      return;
    }

    try {
      await _exerciseService.saveExercisePlan(state!);
      print("Exercise plan saved successfully!");
    } catch (e) {
      print("Failed to save exercise plan: $e");
    }
  }

  // Usuń plan ćwiczeń z bazy danych
  Future<void> deleteExercisePlan(String id) async {
    try {
      await _exerciseService.deleteExercise(id);
      state = null; // Wyczyść stan po usunięciu
      print("Exercise plan deleted successfully!");
    } catch (e) {
      print("Failed to delete exercise plan: $e");
    }
  }
   Future<String?> _getLoggedInUserId() async {
    final token = await getToken();
    if (token == null) {
      return null;
    }

    // Zakładamy, że token zawiera identyfikator użytkownika
    return token; // Możesz dostosować logikę, jeśli token zawiera inne dane
  }

  // Wyczyść bieżący plan ćwiczeń
  void clearExercisePlan() {
    state = null;
    print("Exercise plan cleared.");
  }
}

// Provider dla ExercisePlanNotifier
final exercisePlanProvider = StateNotifierProvider<ExercisePlanNotifier, ExercisePlan?>(
  (ref) => ExercisePlanNotifier(),
);