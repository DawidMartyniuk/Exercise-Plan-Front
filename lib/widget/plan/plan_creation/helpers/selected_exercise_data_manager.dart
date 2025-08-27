import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/widget/plan/plan_creation/helpers/selected_exercise_list_helpers.dart';

class SelectedExerciseDataManager {
  // Existing controllers
  Map<String, Map<String, dynamic>> exerciseRows = {};
  Map<String, List<TextEditingController>> kgControllers = {};
  Map<String, List<TextEditingController>> repControllers = {};
  Map<String, TextEditingController> notesControllers = {};
  
  // ✅ NOWY KONTROLER DLA DRUGIEGO POLA REPS (MAX)
  Map<String, List<TextEditingController>> repMaxControllers = {};

  bool hasExerciseData(String exerciseId) {
    return exerciseRows.containsKey(exerciseId);
  }

  List<Map<String, String>> getExerciseTableData(String exerciseId) {
    return SelectedExerciseListHelpers.getExerciseTableData(exerciseId, exerciseRows);
  }

  Map<String, List<Map<String, String>>> getTableData(List<Exercise> exercises) {
    Map<String, List<Map<String, String>>> result = {};
    
    for (final exercise in exercises) {
      result[exercise.id] = getExerciseTableData(exercise.id);
    }
    
    return result;
  }

  void initializeExerciseData(Exercise exercise, Function(String, int, String, String) updateRowCallback) {
    final exerciseId = exercise.id;
    
    if (exerciseRows.containsKey(exerciseId)) {
      print("🔄 Exercise data already exists for ${exercise.name}");
      return;
    }

    print("🆕 Initializing exercise data for: ${exercise.name}");
    
    // Inicjalizuj dane ćwiczenia
    exerciseRows[exerciseId] = SelectedExerciseListHelpers.generateDefaultExerciseData(exercise);
    
    // Inicjalizuj kontroler notatek
    if (!notesControllers.containsKey(exerciseId)) {
      notesControllers[exerciseId] = TextEditingController();
    }

    // Inicjalizuj kontrolery dla pojedynczego setu
    if (!kgControllers.containsKey(exerciseId)) {
      final kgController = TextEditingController(text: "0");
      kgController.addListener(() {
        updateRowCallback(exerciseId, 0, "colKg", kgController.text);
      });
      kgControllers[exerciseId] = [kgController];
    }

    if (!repControllers.containsKey(exerciseId)) {
      final repController = TextEditingController(text: "0");
      repController.addListener(() {
        updateRowCallback(exerciseId, 0, "colRep", repController.text);
      });
      repControllers[exerciseId] = [repController];
    }

    // ✅ INICJALIZUJ KONTROLERY DLA REP MAX
    if (!repMaxControllers.containsKey(exerciseId)) {
      final repMaxController = TextEditingController(text: "0");
      repMaxController.addListener(() {
        updateRowCallback(exerciseId, 0, "colRepMax", repMaxController.text);
      });
      repMaxControllers[exerciseId] = [repMaxController];
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
    final repMaxController = TextEditingController(text: newSet["colRepMax"] ?? newSet["colRep"]!); // ✅ NOWY

    final currentIndex = rows.length - 1;
    kgController.addListener(() => 
      updateRowCallback(exerciseId, currentIndex, "colKg", kgController.text));
    repController.addListener(() => 
      updateRowCallback(exerciseId, currentIndex, "colRep", repController.text));
    repMaxController.addListener(() => 
      updateRowCallback(exerciseId, currentIndex, "colRepMax", repMaxController.text)); // ✅ NOWY

    kgControllers[exerciseId]!.add(kgController);
    repControllers[exerciseId]!.add(repController);
    repMaxControllers[exerciseId]!.add(repMaxController); // ✅ NOWY

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

    // ✅ USUŃ RÓWNIEŻ KONTROLER REP MAX
    if (repMaxControllers[exerciseId] != null && repMaxControllers[exerciseId]!.length > index) {
      repMaxControllers[exerciseId]![index].dispose();
      repMaxControllers[exerciseId]!.removeAt(index);
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

  /// Usuwa dane ćwiczenia
  void deleteExerciseData(String exerciseId) {
    // Usuń kontrolery kg
    if (kgControllers[exerciseId] != null) {
      for (final controller in kgControllers[exerciseId]!) {
        controller.dispose();
      }
      kgControllers.remove(exerciseId);
    }

    // Usuń kontrolery rep
    if (repControllers[exerciseId] != null) {
      for (final controller in repControllers[exerciseId]!) {
        controller.dispose();
      }
      repControllers.remove(exerciseId);
    }

    // ✅ USUŃ KONTROLERY REP MAX
    if (repMaxControllers[exerciseId] != null) {
      for (final controller in repMaxControllers[exerciseId]!) {
        controller.dispose();
      }
      repMaxControllers.remove(exerciseId);
    }

    // Usuń kontroler notatek
    if (notesControllers[exerciseId] != null) {
      notesControllers[exerciseId]!.dispose();
      notesControllers.remove(exerciseId);
    }

    // Usuń dane ćwiczenia
    exerciseRows.remove(exerciseId);
  }

  void dispose() {
    // Dispose wszystkich kontrolerów
    for (final controllerList in kgControllers.values) {
      for (final controller in controllerList) {
        controller.dispose();
      }
    }
    
    for (final controllerList in repControllers.values) {
      for (final controller in controllerList) {
        controller.dispose();
      }
    }

    // ✅ DISPOSE REP MAX KONTROLERÓW
    for (final controllerList in repMaxControllers.values) {
      for (final controller in controllerList) {
        controller.dispose();
      }
    }
    
    for (final controller in notesControllers.values) {
      controller.dispose();
    }

    kgControllers.clear();
    repControllers.clear();
    repMaxControllers.clear(); // ✅ NOWY
    notesControllers.clear();
    exerciseRows.clear();
  }
}