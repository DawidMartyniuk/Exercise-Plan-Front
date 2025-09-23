import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/services/exerciseService.dart';
import 'package:work_plan_front/theme/app_constants.dart';

class ExerciseNotifier extends StateNotifier<AsyncValue<List<Exercise>>> {
  final ExerciseService _exerciseService;

  ExerciseNotifier(this._exerciseService) : super(const AsyncValue.loading()) {
    fetchExercises();
  }

  // ✅ DODAJ METODĘ RESETOWANIA
  Future<void> resetAndFetch() async {
    try {
      state = const AsyncValue.loading();
     // await _exerciseService.clearCache();
      await fetchExercises();
    } catch (e) {
      print("❌ Reset failed: $e");
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> fetchExercises({bool forceRefresh = false}) async {
      if (!forceRefresh && state.hasValue && state.value != null && state.value!.isNotEmpty) {
    print("✅ Ćwiczenia już są w providerze, nie pobieram ponownie");
    return;
  }
    try {
      print("🔄 ExerciseNotifier: Fetching exercises...");
      
      if (forceRefresh) {
        state = const AsyncValue.loading();
      }
      
      final exercises = await _exerciseService.getExercises();
      state = AsyncValue.data(exercises);
      print("✅ ExerciseNotifier: Loaded ${exercises.length} exercises");
    } catch (e) {
      print("❌ Provider: Błąd ładowania ćwiczeń: $e");
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  // ✅ USUŃ - TA METODA NIE ISTNIEJE W SERVICE
  // Future<void> loadMoreExercises() async {
  //   // USUNIĘTO - BRAK IMPLEMENTACJI W SERVICE
  // }

  // ✅ ZMIEŃ NAZWĘ METODY
  // Future<void> clearExercises() async {
  //   try {
  //     await _exerciseService.clearCache(); // ✅ UŻYJ ISTNIEJĄCEJ METODY
  //     state = const AsyncValue.data([]);
  //     print("🗑️ Provider: Wyczyszczono ćwiczenia");
  //   } catch (e) {
  //     print("❌ Provider: Błąd czyszczenia: $e");
  //   }
  // }

  // ✅ USUŃ - TA METODA NIE ISTNIEJE W SERVICE
  // Future<Map<String, int>> getStats() async {
  //   return await _exerciseService.getExerciseStats();
  // }
}

// ✅ DODAJ PROVIDER DLA SERVICE
final exerciseServiceProvider = Provider<ExerciseService>((ref) {
  return ExerciseService();
});

// ✅ POPRAW PROVIDER
final exerciseProvider = StateNotifierProvider<ExerciseNotifier, AsyncValue<List<Exercise>>>(
  (ref) => ExerciseNotifier(ref.read(exerciseServiceProvider)),
);