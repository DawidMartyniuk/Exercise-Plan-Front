import 'package:hive_flutter/hive_flutter.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/model/favorite_exercise.dart';
import 'package:work_plan_front/serwis/exerciseService.dart';
import 'dart:async';

class AppInitializer {
  // inicjalizuje wszytskie serwisy 
  static Future<void> initialize() async {
    await initializeHive();
    
    // ✅ WYCZYŚĆ CACHE I ZAŁADUJ Z PLIKU JSON
    await _forceLoadFromJson();
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

  // ✅ NOWA METODA - WYMUŚ ŁADOWANIE Z JSON
  static Future<void> _forceLoadFromJson() async {
    try {
      print("🔄 Wymuszam ładowanie ćwiczeń z pliku JSON...");
      
      // ✅ WYCZYŚĆ STARY CACHE
      await clearCacheInDebug();
      
      final exerciseService = ExerciseService();
      
      // ✅ ZAŁADUJ Z PLIKU JSON
      final exercises = await exerciseService.loadFromJsonAsset();
      print("🚀 Załadowano ${exercises.length} ćwiczeń z pliku JSON");
      
    } catch (e) {
      print("❌ Błąd ładowania ćwiczeń z JSON: $e");
    } 
  }

  static Future<void> clearCacheInDebug() async {
    try {
      await Hive.deleteBoxFromDisk('favoriteExercisesBox');
      await Hive.deleteBoxFromDisk('exercisebox');
      print("🗑️ Wyczyszczono cache Hive");
    } catch (e) {
      print("ℹ️ Nie udało się wyczyścić cache: $e");
    } 
  }
}