import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/utils/token_storage.dart';

class ExerciseService {
  static const String _boxName = 'exercisebox';

  // ✅ NOWA METODA - ŁADOWANIE Z PLIKU JSON
  Future<List<Exercise>> loadFromJsonAsset() async {
    try {
      print("📄 Ładowanie ćwiczeń z assets/data/exercises.json...");
      
      // ✅ ZAŁADUJ PLIK JSON
      final String jsonString = await rootBundle.loadString('assets/data/exercises.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      
      print("📊 Znaleziono ${jsonData.length} ćwiczeń w pliku JSON");
      
      // ✅ PRZEKONWERTUJ NA OBIEKTY EXERCISE
      final exercises = <Exercise>[];
      
      for (int i = 0; i < jsonData.length; i++) {
        try {
          final exerciseData = jsonData[i] as Map<String, dynamic>;
          
          // ✅ SPRAWDŹ CZY DANE SĄ KOMPLETNE
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
      
      // ✅ ZAPISZ DO CACHE
      await _saveToCache(exercises);
      
      return exercises;
      
    } catch (e) {
      print("❌ Błąd ładowania z JSON: $e");
      return [];
    }
  }

  // ✅ ZAPISZ DO CACHE
  Future<void> _saveToCache(List<Exercise> exercises) async {
    try {
      final box = await Hive.openBox<Exercise>(_boxName);
      await box.clear();
      
      for (final exercise in exercises) {
        await box.add(exercise);
      }
      
      print("💾 Zapisano ${exercises.length} ćwiczeń do cache");
      
    } catch (e) {
      print("❌ Błąd zapisywania do cache: $e");
    }
  }

  // ✅ ZMODYFIKOWANA METODA GŁÓWNA
  Future<List<Exercise>> getExercises() async {
    try {
      final box = await Hive.openBox<Exercise>(_boxName);
      
      // ✅ SPRAWDŹ CACHE
      if (box.isNotEmpty) {
        final exercises = box.values.toList();
        print("📱 Loaded ${exercises.length} exercises from cache");
        
        // ✅ SPRAWDŹ CZY DANE SĄ PRAWIDŁOWE
        if (exercises.isNotEmpty && exercises.first.name.isNotEmpty) {
          return exercises;
        } else {
          print("⚠️ Cache zawiera nieprawidłowe dane - przeładowuję z JSON");
        }
      }
      
      print("📥 Cache pusty lub uszkodzony, ładowanie z JSON...");
      return await loadFromJsonAsset();
      
    } catch (e) {
      print("❌ Błąd w getExercises: $e");
      
      // ✅ FALLBACK - ZAWSZE SPRÓBUJ ZAŁADOWAĆ Z JSON
      print("🔄 Fallback: ładowanie z JSON");
      return await loadFromJsonAsset();
    }
  }

  // ✅ POZOSTAŁE METODY BEZ ZMIAN
  Future<void> clearCache() async {
    try {
      await Hive.deleteBoxFromDisk(_boxName);
      print("🗑️ Hive cache cleared successfully");
    } catch (e) {
      print("❌ Error clearing cache: $e");
    }
  }
}

