import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/serwis/exerciseService.dart';
import 'package:work_plan_front/theme/app_constants.dart';

class ExerciseNotifier extends StateNotifier<AsyncValue<List<Exercise>>> {
  ExerciseNotifier() : super(const AsyncValue.loading());

  final ExerciseService _exerciseService = ExerciseService();

  Future<void> fetchExercises({bool forceRefresh = false}) async {
    try {
      state = const AsyncValue.loading();
      
      final exercises = await _exerciseService.exerciseList(forceRefresh: forceRefresh);
      
      if (exercises != null && exercises.isNotEmpty) {
        state = AsyncValue.data(exercises);
        print("✅ Provider: Załadowano ${exercises.length} ćwiczeń");
      } else {
        state = AsyncValue.data([]);
        print("⚠️ Provider: Brak ćwiczeń do załadowania");
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      print("❌ Provider: Błąd ładowania ćwiczeń: $e");
    }
  }
  
  Future<void> loadMoreExercises() async {
    try {
      final currentState = state;
      if (currentState is AsyncData<List<Exercise>>) {
        final currentCount = currentState.value.length;
        
        // ✅ SPRAWDŹ CZY NIE PRZEKROCZONO LIMITU
        if (currentCount >= AppConstants.exerciseMaxLimit) {
          print("⚠️ Osiągnięto maksymalny limit ćwiczeń: ${AppConstants.exerciseMaxLimit}");
          return;
        }
        
        await _exerciseService.loadMoreExercises(
          skip: currentCount,
          take: AppConstants().exerciseBatchSize,
        );
        
        // Odśwież dane
        await fetchExercises();
      }
    } catch (e) {
      print("❌ Błąd ładowania kolejnych ćwiczeń: $e");
    }
  }

  void clearExercises() async {
    try {
      await _exerciseService.clearLocalExercises();
      state = const AsyncValue.data([]);
      print("🗑️ Provider: Wyczyszczono ćwiczenia");
    } catch (e) {
      print("❌ Provider: Błąd czyszczenia: $e");
    }
  }

  Future<Map<String, int>> getStats() async {
    return await _exerciseService.getExerciseStats();
  }
}

final exerciseProvider = StateNotifierProvider<ExerciseNotifier, AsyncValue<List<Exercise>>>(
  (ref) => ExerciseNotifier(),
);