import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/widget/plan/plan_creation/helpers/selected_exercise_list_helpers.dart';
class SelectedExerciseDataManager {
  final Map<String, Map<String, dynamic>> exerciseRows = {};
  final Map<String, TextEditingController> notesControllers = {};
  final Map<String, List<TextEditingController>> kgControllers = {};
  final Map<String, List<TextEditingController>> repControllers = {};

  /// Inicjalizuje dane dla nowego ćwiczenia
  void initializeExerciseData(Exercise exercise, Function(String, int, String, String) updateRowCallback) {
    print("🆕 Initializing exercise data for: ${exercise.name} (ID: ${exercise.id})");
  
    if (exerciseRows.containsKey(exercise.id)) {
      print("⚠️ Exercise data already exists for: ${exercise.name}");
      return;
    }
  
    // Inicjalizuj dane ćwiczenia
    exerciseRows[exercise.id] = SelectedExerciseListHelpers.generateDefaultExerciseData(exercise);
  
    // Inicjalizuj kontrolery
    _initializeControllers(exercise.id, updateRowCallback);
  
    print("✅ Initialized exercise data for: ${exercise.name}");
  }

  /// Inicjalizuje kontrolery dla ćwiczenia
  void _initializeControllers(String exerciseId, Function(String, int, String, String) updateRowCallback) {
    // Notes controller
    if (!notesControllers.containsKey(exerciseId)) {
      notesControllers[exerciseId] = TextEditingController();
    }

    // KG controllers
    if (!kgControllers.containsKey(exerciseId)) {
      final kgController = TextEditingController(text: "0");
      kgController.addListener(() {
        updateRowCallback(exerciseId, 0, "colKg", kgController.text);
      });
      kgControllers[exerciseId] = [kgController];
    }

    // REP controllers
    if (!repControllers.containsKey(exerciseId)) {
      final repController = TextEditingController(text: "0");
      repController.addListener(() {
        updateRowCallback(exerciseId, 0, "colRep", repController.text);
      });
      repControllers[exerciseId] = [repController];
    }
  }

  /// Dodaje nowy set do ćwiczenia
  void addRow(String exerciseId, String exerciseName, List<Exercise> exercises, Function(String, int, String, String) updateRowCallback) {
    if (!exerciseRows.containsKey(exerciseId)) {
      final exercise = exercises.firstWhere((e) => e.id == exerciseId);
      initializeExerciseData(exercise, updateRowCallback);
    }
    
    final rows = exerciseRows[exerciseId]!["rows"] as List<Map<String, String>>;
    final newSetNumber = rows.length + 1;
    
    // Dodaj nowy set z skopiowanymi wartościami
    final newSet = SelectedExerciseListHelpers.generateNewSetFromLast(rows, newSetNumber);
    rows.add(newSet);

    // Dodaj nowe kontrolery
    final kgController = TextEditingController(text: newSet["colKg"]!);
    final repController = TextEditingController(text: newSet["colRep"]!);

    final currentIndex = rows.length - 1;
    kgController.addListener(() => 
      updateRowCallback(exerciseId, currentIndex, "colKg", kgController.text));
    repController.addListener(() => 
      updateRowCallback(exerciseId, currentIndex, "colRep", repController.text));

    kgControllers[exerciseId]!.add(kgController);
    repControllers[exerciseId]!.add(repController);

    print("✅ Added set $newSetNumber to $exerciseName");
  }

  /// Usuwa set z ćwiczenia
  void removeRow(String exerciseId, int index) {
    if (!exerciseRows.containsKey(exerciseId)) return;
    
    final rows = exerciseRows[exerciseId]!["rows"] as List<Map<String, String>>;
    if (!SelectedExerciseListHelpers.canRemoveSet(rows) || index >= rows.length) return;

    // Usuń kontrolery
    if (kgControllers[exerciseId] != null && kgControllers[exerciseId]!.length > index) {
      kgControllers[exerciseId]![index].dispose();
      kgControllers[exerciseId]!.removeAt(index);
    }

    if (repControllers[exerciseId] != null && repControllers[exerciseId]!.length > index) {
      repControllers[exerciseId]![index].dispose();
      repControllers[exerciseId]!.removeAt(index);
    }

    // Usuń set i zaktualizuj numery
    rows.removeAt(index);
    SelectedExerciseListHelpers.updateSetNumbers(rows);

    print("✅ Removed set ${index + 1} from exercise $exerciseId");
  }

  /// Aktualizuje wartość w secie
  void updateRowValue(String exerciseId, int rowIndex, String field, String value) {
    if (exerciseRows.containsKey(exerciseId)) {
      final rows = exerciseRows[exerciseId]!["rows"] as List<Map<String, String>>;
      if (rowIndex < rows.length) {
        rows[rowIndex][field] = value;
      }
    }
  }

  /// Aktualizuje notatki dla ćwiczenia
  void updateNotes(String exerciseId, String notes) {
    if (exerciseRows.containsKey(exerciseId)) {
      exerciseRows[exerciseId]!["notes"] = notes;
    }
  }

  /// Usuwa wszystkie dane ćwiczenia
  void deleteExerciseData(String exerciseId) {
    exerciseRows.remove(exerciseId);
    notesControllers.remove(exerciseId)?.dispose();

    if (kgControllers[exerciseId] != null) {
      for (var controller in kgControllers[exerciseId]!) {
        controller.dispose();
      }
      kgControllers.remove(exerciseId);
    }
    
    if (repControllers[exerciseId] != null) {
      for (var controller in repControllers[exerciseId]!) {
        controller.dispose();
      }
      repControllers.remove(exerciseId);
    }
  }

  /// Pobiera dane tabeli dla wszystkich ćwiczeń
  Map<String, List<Map<String, String>>> getTableData(List<Exercise> exercises) {
    print("🔍 Getting table data for ${exercises.length} exercises");
    
    final Map<String, List<Map<String, String>>> result = {};
    
    for (final exercise in exercises) {
      final exerciseId = exercise.id;
      if (exerciseRows.containsKey(exerciseId)) {
        final rows = (exerciseRows[exerciseId]?["rows"] as List<Map<String, String>>?) ?? [];
        result[exerciseId] = rows;
        print("  - ${exercise.name}: ${rows.length} sets");
      } else {
        print("  - ${exercise.name}: NO DATA");
      }
    }
    
    print("🔍 Returning data for ${result.length} exercises");
    return result;
  }

  /// Pobiera dane dla konkretnego ćwiczenia
  List<Map<String, String>> getExerciseTableData(String exerciseId) {
    return SelectedExerciseListHelpers.getExerciseTableData(exerciseId, exerciseRows);
  }

  /// Sprawdza czy ćwiczenie ma zainicjalizowane dane
  bool hasExerciseData(String exerciseId) {
    return SelectedExerciseListHelpers.hasInitializedData(exerciseId, exerciseRows);
  }

  /// Zwalnia wszystkie zasoby
  void dispose() {
    for (var controller in notesControllers.values) {
      controller.dispose();
    }

    for (var controllers in kgControllers.values) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }

    for (var controllers in repControllers.values) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
  }
}