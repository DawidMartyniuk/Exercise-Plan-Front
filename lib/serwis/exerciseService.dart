import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:work_plan_front/model/exercise.dart';

class ExerciseService {
  static const String _boxName = 'exercisebox';

  // GŁÓWNA METODA - ZAWSZE Z LOCAL STORAGE
  Future<List<Exercise>> getExercises() async {
    try {
      final box = await Hive.openBox<Exercise>(_boxName);
      
      // ✅ SPRAWDŹ LOCAL STORAGE NAJPIERW
      if (box.isNotEmpty) {
        final exercises = box.values.toList();
        print("📱 Loaded ${exercises.length} exercises from local storage");
        return exercises;
      }
      
      // ✅ JEŚLI PUSTY - ZAŁADUJ Z JSON I ZAPISZ
      print("📥 Local storage pusty - ładowanie z JSON...");
      return await loadFromJsonAsset();
      
    } catch (e) {
      print("❌ Błąd getExercises: $e");
      // ✅ FALLBACK - ZAWSZE SPRÓBUJ Z JSON
      return await loadFromJsonAsset();
    }
  }

  //  ŁADOWANIE Z JSON I ZAPIS DO PERSISTENT STORAGE
  Future<List<Exercise>> loadFromJsonAsset() async {
    try {
      print("📄 Ładowanie ćwiczeń z assets/data/exercises.json...");
      
      final String jsonString = await rootBundle.loadString('assets/data/exercises.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      
      print("📊 Znaleziono ${jsonData.length} ćwiczeń w pliku JSON");
      
      final exercises = <Exercise>[];
      
      for (int i = 0; i < jsonData.length; i++) {
        try {
          final exerciseData = jsonData[i] as Map<String, dynamic>;
          
          if (exerciseData.containsKey('exerciseId') && 
              exerciseData.containsKey('name') &&
              exerciseData['exerciseId'] != null &&
              exerciseData['name'] != null) {
            
            final exercise = Exercise.fromJson(exerciseData);
            exercises.add(exercise);
          } else {
            print("⚠️ Pominięto niepełne ćwiczenie $i: ${exerciseData['name'] ?? 'unknown'}");
          }
          
        } catch (e) {
          print("❌ Błąd parsowania ćwiczenia $i: $e");
          continue;
        }
      }
      
      print("✅ Sparsowano ${exercises.length} prawidłowych ćwiczeń");
      
      // ✅ ZAPISZ DO PERSISTENT STORAGE
      await _saveToPersistentStorage(exercises);
      
      return exercises;
      
    } catch (e) {
      print("❌ Błąd ładowania z JSON: $e");
      return [];
    }
  }

  //  ZAPIS DO PERSISTENT STORAGE
  Future<void> _saveToPersistentStorage(List<Exercise> exercises) async {
    try {
      final box = await Hive.openBox<Exercise>(_boxName);
      
      // NIE CZYŚĆ - TYLKO ZASTĄP JEŚLI POTRZEBA
      if (box.isEmpty) {
        for (final exercise in exercises) {
          await box.add(exercise);
        }
        print("💾 Zapisano ${exercises.length} ćwiczeń do persistent storage");
      } else {
        print("📱 Ćwiczenia już są w persistent storage");
      }
      
    } catch (e) {
      print("❌ Błąd zapisu do persistent storage: $e");
    }
  }

  //  OPCJONALNE CZYSZCZENIE (TYLKO DLA DEBUGOWANIA)
  Future<void> clearPersistentStorage() async {
    try {
      final box = await Hive.openBox<Exercise>(_boxName);
      await box.clear();
      print("🗑️ Persistent storage wyczyszczony");
    } catch (e) {
      print("❌ Błąd czyszczenia storage: $e");
    }
  }

  //  FORCE REFRESH (GDY CHCESZ ODŚWIEŻYĆ Z JSON)
  Future<List<Exercise>> forceRefreshFromJson() async {
    try {
      await clearPersistentStorage();
      return await loadFromJsonAsset();
    } catch (e) {
      print("❌ Błąd force refresh: $e");
      return [];
    }
  }
}

