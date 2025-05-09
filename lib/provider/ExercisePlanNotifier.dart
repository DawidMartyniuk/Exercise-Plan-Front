import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/serwis/exercisePlan.dart';
import 'package:work_plan_front/utils/tokenStorage.dart';

class ExercisePlanNotifier extends StateNotifier<List<ExerciseTable>> {

  ExercisePlanNotifier({required ExerciseService exerciseService})
      : _exerciseService = exerciseService,
        super([]);
        
   final ExerciseService _exerciseService;
 
Future<void> fetchExercisePlans() async {
  try {

    final exercisePlans = await _exerciseService.fetchExercises();

    
     print("Before assigning to state: ${exercisePlans.runtimeType}");
    state = [...exercisePlans];
    print("After assigning to state: ${state.runtimeType}");
    print("State updated successfully: $state");
  } catch (e) {
    print("Failed to fetch exercise plans: $e");
    state = [];
  }
}


  Future<void> initializeExercisePlan(Map<String, dynamic> exercisesData) async {
    final userId = await _getLoggedInUserId();
    if (userId == null) {
      print("User is not logged in.");
      return;
    }

    final exercises = (exercisesData["exercises"] as List<dynamic>)
        .map((exercise) => ExerciseTable.fromJson(exercise as Map<String, dynamic>))
        .toList();

    print("Adding exercises to state: $exercises");
    state = [...state, ...exercises];
    print("State after adding exercises: $state");

    print("Exercise plan initialized for user $userId.");
  }

  // Zapisz cały planr
 Future<int> saveExercisePlan() async {
  try {
    final statusCode = await _exerciseService.saveExercisePlan(state);
    print("Exercise plan saved successfully!");
    return statusCode;
  } catch (e) {
    print("Failed to save exercise plan: $e");
    rethrow;
  }
}

  // Usuń plan ćwiczeń po ID
  Future<void> deleteExercisePlan(int id) async {
    try {
      await _exerciseService.deleteExercise(id.toString());
      state = state.where((plan) => plan.id != id).toList();
      print("Exercise plan deleted successfully!");
    } catch (e) {
      print("Failed to delete exercise plan: $e");
    }
  }

  // Pobierz userId z tokena
  Future<String?> _getLoggedInUserId() async {
    final token = await getToken();
    return token;
  }

  // Wyczyść wszystkie plany
  void clearExercisePlans() {
    state = [];
    print("Exercise plans cleared.");
  }
}
final exerciseServiceProvider = Provider<ExerciseService>((ref) {
  return ExerciseService();
});

// Provider
final exercisePlanProvider =
    StateNotifierProvider<ExercisePlanNotifier, List<ExerciseTable>>((ref) {
  return ExercisePlanNotifier(exerciseService: ref.watch(exerciseServiceProvider));
});

