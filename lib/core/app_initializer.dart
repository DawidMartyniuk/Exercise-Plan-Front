import 'package:hive_flutter/hive_flutter.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/model/favorite_exercise.dart';
import 'package:work_plan_front/serwis/exerciseService.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/provider/exerciseProvider.dart';
import 'package:work_plan_front/provider/ExercisePlanNotifier.dart';
import 'package:work_plan_front/provider/TrainingSerssionNotifer.dart';

class AppInitializer {
  static Future<void> initialize() async {
    await initializeHive();
    await _ensureDataAvailable(); //  NOWA METODA
  }

  static Future<void> initializeHive() async{
    await Hive.initFlutter();

    if(!Hive.isAdapterRegistered(0)){
      Hive.registerAdapter(ExerciseAdapter());
    }
    if(!Hive.isAdapterRegistered(1)){
      Hive.registerAdapter(FavoriteExerciseAdapter());
    }
    print("✅ Hive zainicjalizowany");
  }

  // - SPRAWDŹ CZY DANE ISTNIEJĄ, JEŚLI NIE - ZAŁADUJ
  static Future<void> _ensureDataAvailable() async {
    try {
      final exerciseService = ExerciseService();
      
      //  SPRAWDŹ CZY MAMY DANE W STORAGE
      final hasExercises = await _hasExercisesInStorage();
      
      if (!hasExercises) {
        print("📥 Brak ćwiczeń w local storage - ładowanie z JSON...");
        await exerciseService.loadFromJsonAsset();
      } else {
        print("✅ Ćwiczenia już są w local storage");
      }
      
    } catch (e) {
      print("❌ Błąd _ensureDataAvailable: $e");
    }
  }

  //  SPRAWDŹ CZY MAMY DANE W HIVE
  static Future<bool> _hasExercisesInStorage() async {
    try {
      final box = await Hive.openBox<Exercise>('exercisebox');
      return box.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  //  ŁADOWANIE WSZYSTKICH DANYCH (dla splash screen)
  static Future<void> loadAllData(WidgetRef ref) async {
    print("📊 AppInitializer: Loading all data (persistent)...");
    
    try {
      await Future.wait([
        _loadExercises(ref),
        _loadExercisePlans(ref), 
        _loadTrainingSessions(ref),
      ]);
      
      print("✅ Wszystkie dane załadowane");
      
    } catch (e) {
      print("❌ Błąd loading: $e");
    }
  }

  static Future<void> _loadExercises(WidgetRef ref) async {
    try {
      print("🏃‍♀️ Ładowanie ćwiczeń...");
      await ref.read(exerciseProvider.notifier).fetchExercises();
      print("✅ Ćwiczenia załadowane");
    } catch (e) {
      print("❌ Błąd ładowania ćwiczeń: $e");
    }
  }

  static Future<void> _loadExercisePlans(WidgetRef ref) async {
    try {
      print("📋 Ładowanie planów treningowych...");
      await ref.read(exercisePlanProvider.notifier).fetchExercisePlans();
      print("✅ Plany treningowe załadowane");
    } catch (e) {
      print("❌ Błąd ładowania planów: $e");
    }
  }

  static Future<void> _loadTrainingSessions(WidgetRef ref) async {
    try {
      print("📈 Ładowanie sesji treningowych...");
      await ref.read(trainingSessionAsyncProvider.notifier).fetchSessions();
      print("✅ Sesje treningowe załadowane");
    } catch (e) {
      print("❌ Błąd ładowania sesji treningowych: $e");
    }
  }

  //  OPCJONALNE CZYSZCZENIE (TYLKO DLA DEBUGOWANIA)
  static Future<void> clearAllData() async {
    try {
      await Hive.deleteBoxFromDisk('favoriteExercisesBox');
      await Hive.deleteBoxFromDisk('exercisebox');
      await Hive.deleteBoxFromDisk('exercise_plans_cache');
      await Hive.deleteBoxFromDisk('training_sessions_cache');
      print("🗑️ Wyczyszczono wszystkie dane");
    } catch (e) {
      print("❌ Nie udało się wyczyścić danych: $e");
    }
  }
}