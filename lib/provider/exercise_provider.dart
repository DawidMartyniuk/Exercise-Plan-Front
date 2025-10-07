import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/services/exerciseService.dart';
import 'package:work_plan_front/theme/app_constants.dart';
import 'package:work_plan_front/utils/token_storage.dart' as TokenStorage;

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
  if (!forceRefresh &&
      state.hasValue &&
      state.value != null &&
      state.value!.isNotEmpty) {
    print("✅ Ćwiczenia już są w providerze, nie pobieram ponownie");
    return;
  }
  try {
    print("🔄 ExerciseNotifier: Fetching exercises...");

    if (forceRefresh) {
      state = const AsyncValue.loading();
    }
    final userId = await TokenStorage.getUserId();
    print("🔄 [ExerciseProvider] Otwieram box user_exercises_$userId");
    final userBox = await Hive.openBox<Exercise>('user_exercises_$userId');
    final userExercises = userBox.values.toList();

    // Domyślne ćwiczenia (np. z assets/data/exercises.json lub innego boxa)
    final defaultExercises = await _exerciseService.getExercises();

    // Połącz, unikając duplikatów po exerciseId
    final allExercisesMap = {
      for (var e in defaultExercises) e.exerciseId: e,
      for (var e in userExercises) e.exerciseId: e,
    };
    final allExercises = allExercisesMap.values.toList();

    print("✅ [ExerciseProvider] Wczytano ${allExercises.length} ćwiczeń (łącznie domyślne + usera)");

    state = AsyncValue.data(allExercises);
    print("✅ ExerciseNotifier: Loaded ${allExercises.length} exercises");
  } catch (e) {
    print("❌ Provider: Błąd ładowania ćwiczeń: $e");
    state = AsyncValue.error(e, StackTrace.current);
  }
}

}

// ✅ DODAJ PROVIDER DLA SERVICE
final exerciseServiceProvider = Provider<ExerciseService>((ref) {
  return ExerciseService();
});

// ✅ POPRAW PROVIDER
final exerciseProvider =
    StateNotifierProvider<ExerciseNotifier, AsyncValue<List<Exercise>>>(
      (ref) => ExerciseNotifier(ref.read(exerciseServiceProvider)),
    );
