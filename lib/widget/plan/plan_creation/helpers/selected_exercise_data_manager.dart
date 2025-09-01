import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/widget/plan/plan_creation/helpers/selected_exercise_list_helpers.dart';

class SelectedExerciseDataManager {
  Map<String, Map<String, dynamic>> exerciseRows = {};
  Map<String, TextEditingController> notesControllers = {};
  Map<String, List<TextEditingController>> kgControllers = {};
  Map<String, List<TextEditingController>> repMinControllers = {};
  Map<String, List<TextEditingController>> repMaxControllers = {};

  //  POPRAWIONA INICJALIZACJA
  void initializeExerciseData(Exercise exercise, Function(String, int, String, String) updateRowCallback) {
    final exerciseId = exercise.id;
    
    if (exerciseRows.containsKey(exerciseId)) {
      print("🔄 Exercise data already exists for ${exercise.name}");
      return;
    }

    print("🆕 Initializing exercise data for: ${exercise.name}");
    
    exerciseRows[exerciseId] = {
      "exerciseName": exercise.name,
      "notes": "",
      "rows": [
        {
          "colStep": "1", 
          "colKg": "0", 
          "colRepMin": "0", //  ZMIENIONE z colRep
          "colRepMax": "0",
          "repsType": "single"
        }
      ]
    };
    
    if (!notesControllers.containsKey(exerciseId)) {
      notesControllers[exerciseId] = TextEditingController();
    }

    if (!kgControllers.containsKey(exerciseId)) {
      final kgController = TextEditingController(text: "0");
      kgController.addListener(() {
        updateRowCallback(exerciseId, 0, "colKg", kgController.text);
      });
      kgControllers[exerciseId] = [kgController];
    }

    //  ZMIENIONE z repControllers na repMinControllers
    if (!repMinControllers.containsKey(exerciseId)) {
      final repMinController = TextEditingController(text: "0");
      repMinController.addListener(() {
        updateRowCallback(exerciseId, 0, "colRepMin", repMinController.text); //  ZMIENIONE
      });
      repMinControllers[exerciseId] = [repMinController];
    }

    if (!repMaxControllers.containsKey(exerciseId)) {
      final repMaxController = TextEditingController(text: "0");
      repMaxController.addListener(() {
        updateRowCallback(exerciseId, 0, "colRepMax", repMaxController.text);
      });
      repMaxControllers[exerciseId] = [repMaxController];
    }
  }

  //  METODA DO ZWRACANIA DANYCH Z POPRAWNYMI NAZWAMI
  Map<String, List<Map<String, String>>> getTableData(List<Exercise> exercises) {
    final Map<String, List<Map<String, String>>> result = {};
    
    for (final exercise in exercises) {
      final exerciseId = exercise.id;
      final rows = exerciseRows[exerciseId]?["rows"] as List<Map<String, String>>? ?? [];
      
      final processedRows = rows.map((row) {
        return {
          "colStep": row["colStep"] ?? "1",
          "colKg": row["colKg"] ?? "0",
          "colRepMin": row["colRepMin"] ?? "0", //  ZMIENIONE z colRep
          "colRepMax": row["colRepMax"] ?? row["colRepMin"] ?? "0",
          "repsType": row["repsType"] ?? "single",
        };
      }).toList();
      
      result[exerciseId] = processedRows;
    }
    
    return result;
  }

  //  DODAJ BRAKUJĄCĄ METODĘ hasExerciseData
  bool hasExerciseData(String exerciseId) {
    return exerciseRows.containsKey(exerciseId);
  }

  //  DODAJ BRAKUJĄCĄ METODĘ getExerciseTableData
  List<Map<String, String>> getExerciseTableData(String exerciseId) {
    if (!exerciseRows.containsKey(exerciseId)) {
      return [];
    }
    
    final rows = exerciseRows[exerciseId]!["rows"] as List<Map<String, String>>?;
    return rows ?? [];
  }

  //  DODAJ BRAKUJĄCĄ METODĘ updateNotes
  void updateNotes(String exerciseId, String notes) {
    if (exerciseRows.containsKey(exerciseId)) {
      exerciseRows[exerciseId]!["notes"] = notes;
    }
  }

  //  DODAJ NOWY SET Z POPRAWNYMI NAZWAMI
  void addRow(String exerciseId, String exerciseName, List<Exercise> exercises, Function(String, int, String, String) updateRowCallback) {
    if (!exerciseRows.containsKey(exerciseId)) {
      final exercise = exercises.firstWhere((e) => e.id == exerciseId);
      initializeExerciseData(exercise, updateRowCallback);
    }
    
    final rows = exerciseRows[exerciseId]!["rows"] as List<Map<String, String>>;
    final newSetNumber = rows.length + 1;
    
    final newSet = SelectedExerciseListHelpers.generateNewSetFromLast(rows, newSetNumber);
    rows.add(newSet);

    //  ZMIENIONE NAZWY KONTROLERÓW
    final kgController = TextEditingController(text: newSet["colKg"]!);
    final repMinController = TextEditingController(text: newSet["colRepMin"]!); 
    final repMaxController = TextEditingController(text: newSet["colRepMax"] ?? newSet["colRepMin"]!);

    final currentIndex = rows.length - 1;
    kgController.addListener(() => 
      updateRowCallback(exerciseId, currentIndex, "colKg", kgController.text));
    repMinController.addListener(() => 
      updateRowCallback(exerciseId, currentIndex, "colRepMin", repMinController.text)); 
    repMaxController.addListener(() => 
      updateRowCallback(exerciseId, currentIndex, "colRepMax", repMaxController.text));

    kgControllers[exerciseId]!.add(kgController);
    repMinControllers[exerciseId]!.add(repMinController); 
    repMaxControllers[exerciseId]!.add(repMaxController);

    print("✅ Added set $newSetNumber to $exerciseName");
  }

   void updateRowValue(String exerciseId, int rowIndex, String field, String value) {
    if (exerciseRows.containsKey(exerciseId)) {
      final rows = exerciseRows[exerciseId]!["rows"] as List<Map<String, String>>;
      if (rowIndex < rows.length) {
        rows[rowIndex][field] = value;
        
        // ✅ AUTOMATYCZNIE AKTUALIZUJ REPS TYPE Z POPRAWNYMI NAZWAMI
        if (field == "colRepMin" || field == "colRepMax") {
          final repMin = int.tryParse(rows[rowIndex]["colRepMin"] ?? "0") ?? 0;
          final repMax = int.tryParse(rows[rowIndex]["colRepMax"] ?? "0") ?? 0;
          rows[rowIndex]["repsType"] = (repMin != repMax) ? "range" : "single";
          
          print("🔄 Updated repsType for $exerciseId set ${rowIndex + 1}: ${rows[rowIndex]["repsType"]}");
        }
        
        print("📝 Updated $exerciseId set ${rowIndex + 1}: $field = '$value'");
      }
    }
  }

  //  USUŃ SET Z POPRAWNYMI NAZWAMI
  void removeRow(String exerciseId, int index) {
    if (!exerciseRows.containsKey(exerciseId)) return;
    
    final rows = exerciseRows[exerciseId]!["rows"] as List<Map<String, String>>;
    if (!SelectedExerciseListHelpers.canRemoveSet(rows) || index >= rows.length) return;

    if (kgControllers[exerciseId] != null && kgControllers[exerciseId]!.length > index) {
      kgControllers[exerciseId]![index].dispose();
      kgControllers[exerciseId]!.removeAt(index);
    }

    //  ZMIENIONE z repControllers na repMinControllers
    if (repMinControllers[exerciseId] != null && repMinControllers[exerciseId]!.length > index) {
      repMinControllers[exerciseId]![index].dispose();
      repMinControllers[exerciseId]!.removeAt(index);
    }

    if (repMaxControllers[exerciseId] != null && repMaxControllers[exerciseId]!.length > index) {
      repMaxControllers[exerciseId]![index].dispose();
      repMaxControllers[exerciseId]!.removeAt(index);
    }

    rows.removeAt(index);
    SelectedExerciseListHelpers.updateSetNumbers(rows);

    print("✅ Removed set ${index + 1} from exercise $exerciseId");
  }

  //  USUŃ DANE ĆWICZENIA Z POPRAWNYMI NAZWAMI
  void deleteExerciseData(String exerciseId) {
    if (kgControllers[exerciseId] != null) {
      for (final controller in kgControllers[exerciseId]!) {
        controller.dispose();
      }
      kgControllers.remove(exerciseId);
    }

    //  z repControllers na repMinControllers
    if (repMinControllers[exerciseId] != null) {
      for (final controller in repMinControllers[exerciseId]!) {
        controller.dispose();
      }
      repMinControllers.remove(exerciseId);
    }

    if (repMaxControllers[exerciseId] != null) {
      for (final controller in repMaxControllers[exerciseId]!) {
        controller.dispose();
      }
      repMaxControllers.remove(exerciseId);
    }

    if (notesControllers[exerciseId] != null) {
      notesControllers[exerciseId]!.dispose();
      notesControllers.remove(exerciseId);
    }

    exerciseRows.remove(exerciseId);
  }

  void dispose() {
    for (final controllerList in kgControllers.values) {
      for (final controller in controllerList) {
        controller.dispose();
      }
    }
    
    //  ZMIENIONE z repControllers na repMinControllers
    for (final controllerList in repMinControllers.values) {
      for (final controller in controllerList) {
        controller.dispose();
      }
    }

    for (final controllerList in repMaxControllers.values) {
      for (final controller in controllerList) {
        controller.dispose();
      }
    }
    
    for (final controller in notesControllers.values) {
      controller.dispose();
    }

    kgControllers.clear();
    repMinControllers.clear(); //  ZMIENIONE
    repMaxControllers.clear();
    notesControllers.clear();
    exerciseRows.clear();
  }
}