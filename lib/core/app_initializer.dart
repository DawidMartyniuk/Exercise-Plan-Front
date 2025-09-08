import 'package:hive_flutter/hive_flutter.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/model/favorite_exercise.dart';
import 'package:work_plan_front/serwis/exerciseService.dart';
import 'dart:async';

class AppInitializer {
  // inicjalizuje wszytskie serwisy 
  static Future<void> initialize() async {
    await initializeHive();
    await _preloadExercises();  
  }

  //inicjalizuje baze danych hive i rejestruje adaptery
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
  //wczytuje ćwiczenia 
  static Future<void> _preloadExercises()async{
    try {
      print("🔄 Wstępne ładowanie ćwiczeń...");
      final exerciseService = ExerciseService();
      final exercises = await exerciseService.exerciseList(forceRefresh: true);
      print("🚀 Załadowano ${exercises?.length ?? 0} ćwiczeń przy starcie");
    } catch (e) {
      print("❌ Błąd ładowania ćwiczeń przy starcie: $e");
    } 
  }

   static Future<void> clearCacheInDebug() async {
    try {
      await Hive.deleteBoxFromDisk('favoriteExercisesBox');
      await Hive.deleteBoxFromDisk('exerciseBox');
      print("🗑️ Wyczyszczono cache Hive");
    } catch (e) {
      print("ℹ️ Nie udało się wyczyścić cache: $e");
    }
  }


}