import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:hive/hive.dart';
import "package:work_plan_front/theme/app_constants.dart";

class ExerciseService {
  static const String _boxName = AppConstants.exerciseBoxName; // ✅ UŻYJ STAŁEJ

  // ✅ WCZYTAJ ĆWICZENIA Z DYNAMICZNYMI LIMITAMI
  Future<List<Exercise>?> exerciseList({bool forceRefresh = false}) async {
    try {
      final box = await Hive.openBox<Exercise>(_boxName);
      final appConstants = AppConstants(); // ✅ POBIERZ INSTANCJĘ

     
      if (box.isEmpty || forceRefresh) {
        print("📦 Ładowanie ćwiczeń z JSON...");
        
        try {
          final String jsonString = await rootBundle.loadString('assets/data/exercises.json');
          print("załadowano json długość ${jsonString.length}");

          final List<dynamic> jsonList = json.decode(jsonString);
          print("załadowano json długość listy ${jsonList.length}");

          // ✅ UŻYJ DYNAMICZNYCH WARTOŚCI Z AppConstants
          final limitedJsonList = jsonList
              .skip(appConstants.exerciseStart)  // ✅ DYNAMICZNY START
              .take(appConstants.exerciseBatchSize)  // ✅ DYNAMICZNY ROZMIAR
              .toList();

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

          print("✅ Zapisano ${exercises.length} ćwiczeń lokalnie (${appConstants.exerciseStart}-${appConstants.exerciseLimit})");
          return exercises;
          
        } catch (e) {
          print("❌ Błąd ładowania JSON: $e");
          return null;
        }
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

  // ✅ POZOSTAŁE METODY BEZ ZMIAN...
  Future<void> clearLocalExercises() async {
    try {
      final box = await Hive.openBox<Exercise>(_boxName);
      await box.clear();
      print("🗑️ Wyczyszczono lokalną bazę ćwiczeń");
    } catch (e) {
      print("❌ Błąd czyszczenia bazy: $e");
    }
  }

  Future<void> loadMoreExercises({int? skip, int? take}) async {
    try {
      final box = await Hive.openBox<Exercise>(_boxName);
      final appConstants = AppConstants();
      
      final String jsonString = await rootBundle.loadString('assets/data/exercises.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      final skipCount = skip ?? box.length;
      final takeCount = take ?? appConstants.exerciseBatchSize;
      
      // Weź następne ćwiczenia
      final moreExercises = jsonList
          .skip(skipCount)
          .take(takeCount)
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

  Future<Map<String, int>> getExerciseStats() async {
    try {
      final box = await Hive.openBox<Exercise>(_boxName);
      final exercises = box.values.toList();
      final appConstants = AppConstants();

      return {
        'total': exercises.length,
        'configuredLimit': appConstants.exerciseLimit,
        'configuredStart': appConstants.exerciseStart,
        'batchSize': appConstants.exerciseBatchSize,
      };
    } catch (e) {
      print("❌ Błąd pobierania statystyk: $e");
      return {};
    }
  }
}

