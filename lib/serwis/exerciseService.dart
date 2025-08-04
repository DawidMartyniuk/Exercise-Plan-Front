import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:hive/hive.dart';

class ExerciseService {
  static const String _boxName = 'exerciseBox';

  // ✅ WCZYTAJ PIERWSZE 100 ĆWICZEŃ Z JSON
  Future<List<Exercise>?> exerciseList({bool forceRefresh = false}) async {
    try {
      final box = await Hive.openBox<Exercise>(_boxName);

      // Jeśli nie ma danych lokalnie lub wymuszone odświeżenie
      if (box.isEmpty || forceRefresh) {
        print("📦 Ładowanie ćwiczeń z JSON...");
        try {
          final String jsonString = await rootBundle.loadString('assets/data/exercises.json');
          print("załadowano json długość ${jsonString.length}");

          final List<dynamic> jsonList = json.decode(jsonString);
          print("załadowano json długość listy ${jsonList.length}");
        }catch (e) {
          print("❌ Błąd ładowania JSON: $e");
          return null;
        }
        
        // Wczytaj JSON z assets
        final String jsonString = await rootBundle.loadString('assets/data/exercises.json');
        final List<dynamic> jsonList = json.decode(jsonString);
        
        // ✅ WEŹ TYLKO PIERWSZE 100 ĆWICZEŃ
        final limitedJsonList = jsonList.take(100).toList();
        
        // Konwertuj na Exercise obiekty
        final List<Exercise> exercises = limitedJsonList
            .map((json) => Exercise.fromJson(json))
            .where((exercise) => exercise.name.isNotEmpty) // Filtruj puste
            .toList();

        // Wyczyść box i zapisz nowe dane
        await box.clear();
        for (final exercise in exercises) {
          await box.add(exercise);
        }

        print("✅ Zapisano ${exercises.length} ćwiczeń lokalnie");
        return exercises;
      }

      // Pobierz z lokalnej bazy
      final exercises = box.values.toList();
      print("📱 Wczytano ${exercises.length} ćwiczeń z lokalnej bazy");
      return exercises;

    } catch (e) {
      print("❌ Błąd ładowania ćwiczeń: $e");
      return null;
    }
  }

  // ✅ WYCZYŚĆ LOKALNĄ BAZĘ
  Future<void> clearLocalExercises() async {
    try {
      final box = await Hive.openBox<Exercise>(_boxName);
      await box.clear();
      print("🗑️ Wyczyszczono lokalną bazę ćwiczeń");
    } catch (e) {
      print("❌ Błąd czyszczenia bazy: $e");
    }
  }

  // ✅ DODAJ WIĘCEJ ĆWICZEŃ (np. następne 100)
  Future<void> loadMoreExercises({int skip = 100, int take = 100}) async {
    try {
      final box = await Hive.openBox<Exercise>(_boxName);
      
      final String jsonString = await rootBundle.loadString('lib/data/exercises.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      // Weź następne ćwiczenia
      final moreExercises = jsonList
          .skip(skip)
          .take(take)
          .map((json) => Exercise.fromJson(json))
          .where((exercise) => exercise.name.isNotEmpty)
          .toList();

      for (final exercise in moreExercises) {
        await box.add(exercise);
      }

      print("✅ Dodano ${moreExercises.length} kolejnych ćwiczeń");
    } catch (e) {
      print("❌ Błąd ładowania kolejnych ćwiczeń: $e");
    }
  }

  // ✅ POBIERZ STATYSTYKI
  Future<Map<String, int>> getExerciseStats() async {
    try {
      final box = await Hive.openBox<Exercise>(_boxName);
      final exercises = box.values.toList();

      final Map<String, int> bodyPartCount = {};
      final Map<String, int> equipmentCount = {};

      for (final exercise in exercises) {
        // Zlicz części ciała
        for (final bodyPart in exercise.bodyParts) {
          bodyPartCount[bodyPart] = (bodyPartCount[bodyPart] ?? 0) + 1;
        }
        
        // Zlicz sprzęt
        for (final equipment in exercise.equipments) {
          equipmentCount[equipment] = (equipmentCount[equipment] ?? 0) + 1;
        }
      }

      return {
        'total': exercises.length,
        'bodyParts': bodyPartCount.length,
        'equipments': equipmentCount.length,
      };
    } catch (e) {
      print("❌ Błąd pobierania statystyk: $e");
      return {};
    }
  }
}

