import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/serwis/saveExercisePlan.dart';
import 'package:work_plan_front/utils/tokenStorage.dart';

class ExercisePlanNotifier extends StateNotifier<ExercisePlan?> {
  ExercisePlanNotifier() : super(null);

  final ExerciseService _exerciseService = ExerciseService();

  // Pobierz wszystkie plany ćwiczeń z bazy danych
  Future<void> fetchExercisePlans() async {
    try {
      final exercisePlans = await _exerciseService.fetchExercises();
      if (exercisePlans.isNotEmpty) {
        state = exercisePlans.first; // Ustaw pierwszy plan jako aktywny (lub dostosuj logikę)
      }
      print("Fetched exercise plans: $exercisePlans");
    } catch (e) {
      print("Failed to fetch exercise plans: $e");
    }
  }
Future<void> initializeExercisePlan(Map<String, dynamic> exercisesData) async {
  final userId = await _getLoggedInUserId();
  if (userId == null) {
    print("User is not logged in.");
    return;
  }

  state = ExercisePlan(
    userId: userId,
    exercises: Map<String, List<Map<String, dynamic>>>.fromEntries(
      (exercisesData["exercises"] as List<dynamic>).map((exercise) {
        final exerciseTable = exercise["exercise_table"]?.toString() ?? "Unknown Exercise";
        final rawRows = exercise["rows"] as List<dynamic>;
    
        final rows = rawRows.map<Map<String, dynamic>>((row) {
          return {
            "exercise_name": row["exercise_name"]?.toString() ?? "Unknown Exercise",
            "notes": row["notes"]?.toString() ?? "",
            "data": (row["data"] as List).map<Map<String,dynamic>>((entry) => {
              "colStep": entry["colStep"] ?? "0",
              "colKg": entry["colKg"] ?? "0",
              "colRep": entry["colRep"] ?? "0",
            }).toList(),
          };
        }).toList();
    
        return MapEntry(exerciseTable, rows);
      }),
    ),
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

  // Zapisz nowy plan ćwiczeń do bazy danych
  // Future<void> saveExercisePlan(ExercisePlan exercisePlan) async {
  //   try {
  //     await _exerciseService.saveExercisePlan(exercisePlan);
  //     state = exercisePlan; // Ustaw zapisany plan jako aktywny
  //     print("Exercise plan saved successfully!");
  //   } catch (e) {
  //     print("Failed to save exercise plan: $e");
  //   }
  // }

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