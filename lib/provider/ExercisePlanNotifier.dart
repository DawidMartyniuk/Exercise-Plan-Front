import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/User.dart';
import 'package:work_plan_front/utils/tokenStorage.dart';

class ExercisePlanNotifier extends StateNotifier<ExercisePlan?> {
  ExercisePlanNotifier() : super(null);

  // Pobierz identyfikator zalogowanego użytkownika
  Future<int?> _getLoggedInUserId() async {
    final token = await getToken();
    if (token == null) {
      print("No token found. User is not logged in.");
      return null;
    }

    // Przykład: Pobierz dane użytkownika z tokena lub API
    // W tym miejscu możesz dodać logikę do pobrania użytkownika na podstawie tokena
    // Na razie zakładamy, że token przechowuje identyfikator użytkownika
    final userId = int.tryParse(token); // Przykład: token to ID użytkownika
    return userId;
  }

  // Inicjalizuj plan ćwiczeń dla zalogowanego użytkownika
  Future<void> initializeExercisePlan(Map<String, List<Map<String, String>>> exercises) async {
    final userId = await _getLoggedInUserId();
    if (userId == null) {
      print("Cannot initialize exercise plan. User is not logged in.");
      return;
    }

    state = ExercisePlan(
      userId: userId.toString(),
      exercises: exercises,
    );

    print("Exercise plan initialized for user $userId.");
  }

  // Zapisz plan ćwiczeń
  Future<void> saveExercisePlan() async {
    if (state == null) {
      print("No exercise plan to save.");
      return;
    }

    // Przykład: Wyślij dane do API lub zapisz lokalnie
    print("Saving exercise plan: ${state!.toJson()}");
    // TODO: Dodaj logikę zapisu do API lub bazy danych
  }

  // Wyczyść plan ćwiczeń
  void clearExercisePlan() {
    state = null;
    print("Exercise plan cleared.");
  }
}

// Provider dla ExercisePlanNotifier
final exercisePlanProvider = StateNotifierProvider<ExercisePlanNotifier, ExercisePlan?>(
  (ref) => ExercisePlanNotifier(),
);