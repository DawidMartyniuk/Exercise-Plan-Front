import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/favorite_exercise.dart';
import 'package:hive/hive.dart';

class FavoriteExerciseNotifier extends StateNotifier<Set<String>> {
  static const String boxName = 'favoriteExercisesBox';
  Box<FavoriteExercise>? _box;

  FavoriteExerciseNotifier() : super(<String>{}) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _box = await Hive.openBox<FavoriteExercise>(boxName);
      loadFavorites();
    } catch (e) {
      print('Error initializing favorites box: $e');
    }
  }

  void loadFavorites() {
    if (_box != null) {
      final favoriteIds = _box!.values.map((fav) => fav.exerciseId).toSet();
      state = favoriteIds;
    }
  }

  Future<void> toggleFavorite(String exerciseId) async {
    if (_box == null) return;

    try {
      if (state.contains(exerciseId)) {
        // Usuń z ulubionych
        final key = _box!.keys.firstWhere(
          (key) => _box!.get(key)?.exerciseId == exerciseId,
          orElse: () => null,
        );
        if (key != null) {
          await _box!.delete(key);
        }
        state = Set.from(state)..remove(exerciseId);
      } else {
        // Dodaj do ulubionych
        final favoriteExercise = FavoriteExercise(
          exerciseId: exerciseId,
          addedAt: DateTime.now(),
        );
        await _box!.add(favoriteExercise);
        state = Set.from(state)..add(exerciseId);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  bool isFavorite(String exerciseId) {
    return state.contains(exerciseId);
  }

  Future<void> clearAllFavorites() async {
    if (_box == null) return;
    
    try {
      await _box!.clear();
      state = <String>{};
    } catch (e) {
      print('Error clearing favorites: $e');
    }
  }
}

final favoriteExerciseProvider = StateNotifierProvider<FavoriteExerciseNotifier, Set<String>>((ref) {
  return FavoriteExerciseNotifier();
});