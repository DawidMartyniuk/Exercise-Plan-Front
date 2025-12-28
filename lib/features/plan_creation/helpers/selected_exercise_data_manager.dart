import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/features/plan_creation/helpers/selected_exercise_list_helpers.dart';

class SelectedExerciseDataManager {
  Map<String, Map<String, dynamic>> exerciseRows = {};
  Map<String, TextEditingController> notesControllers = {};
  Map<String, List<TextEditingController>> kgControllers = {};
  Map<String, List<TextEditingController>> repMinControllers = {};
  Map<String, List<TextEditingController>> repMaxControllers = {};

  //  POPRAWIONA INICJALIZACJA
  void initializeExerciseData(
    Exercise exercise,
    Function(String, int, String, String) updateRowCallback, {
    List<Map<String, String>>? initialRows,
    String? initialNotes,
    String? repType,
  }) {
    final exerciseId = exercise.id;

    if (exerciseRows.containsKey(exerciseId)) {
      print("🔄 Exercise data already exists for ${exercise.name}");
      return;
    }

    print("🆕 Initializing exercise data for: ${exercise.name}");

    // Jeśli przekazano initialRows (np. z planu), użyj ich, w przeciwnym razie domyślny set
    final rows = initialRows ?? [
      {
        "colStep": "1",
        "colKg": "0",
        "colRepMin": "0",
        "colRepMax": "0",
        "repsType": repType ?? "single"
      }
    ];

    exerciseRows[exerciseId] = {
      "exerciseName": exercise.name,
      "notes": initialNotes ?? "",
      "rows": rows,
      "rep_type": repType ?? (rows.isNotEmpty ? (rows[0]["repsType"] ?? "single") : "single"),
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
  void setRepsTypeForExercise(String exerciseId, String repsType) {
  if (!exerciseRows.containsKey(exerciseId)) return;
  final rows = exerciseRows[exerciseId]!["rows"] as List<Map<String, String>>;
  for (final row in rows) {
    row["repsType"] = repsType;
  }
  exerciseRows[exerciseId]!["rep_type"] = repsType; // <- zapisz globalnie!
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
      print("⚠️ Exercise $exerciseId not initialized, initializing now...");
      final exercise = exercises.firstWhere(
        (e) => e.id == exerciseId,
        orElse: () {
          print("❌ Exercise $exerciseId not found in exercises list!");
          throw Exception("Exercise $exerciseId not found");
        },
      );
      initializeExerciseData(exercise, updateRowCallback);
    }

    if (!exerciseRows.containsKey(exerciseId) || exerciseRows[exerciseId] == null) {
      print("❌ Exercise data is null for $exerciseId");
      return;
    }

    if (!exerciseRows.containsKey(exerciseId)) {
      final exercise = exercises.firstWhere((e) => e.id == exerciseId);
      initializeExerciseData(exercise, updateRowCallback);
    }
    final exerciseData = exerciseRows[exerciseId]!;
    if (exerciseData["rows"] == null) {
      print("❌ Exercise rows are null for $exerciseId, initializing...");
      exerciseData["rows"] = <Map<String, String>>[];
    }
    
    final rows = exerciseRows[exerciseId]!["rows"] as List<Map<String, String>>;
    final newSetNumber = rows.length + 1;
    
    final newSet = SelectedExerciseListHelpers.generateNewSetFromLast(rows, newSetNumber);
    rows.add(newSet);
    // zabezpieczenie inicjalizatorów 
    if (kgControllers[exerciseId] == null) {
      print("⚠️ KG controllers null for $exerciseId, initializing...");
      kgControllers[exerciseId] = [];
    }
    if (repMinControllers[exerciseId] == null) {
      print("⚠️ RepMin controllers null for $exerciseId, initializing...");
      repMinControllers[exerciseId] = [];
    }
    if (repMaxControllers[exerciseId] == null) {
      print("⚠️ RepMax controllers null for $exerciseId, initializing...");
      repMaxControllers[exerciseId] = [];
    }

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
    if (!exerciseRows.containsKey(exerciseId) || exerciseRows[exerciseId] == null) {
      print("❌ Cannot update: exercise $exerciseId not found or null");
      return;
    }
    
    final exerciseData = exerciseRows[exerciseId]!;
    if (exerciseData["rows"] == null) {
      print("❌ Cannot update: exercise rows are null for $exerciseId");
      return;
    }
    
    final rows = exerciseData["rows"] as List<Map<String, String>>;
    if (rowIndex >= rows.length || rowIndex < 0) {
      print("❌ Cannot update: invalid row index $rowIndex for exercise $exerciseId");
      return;
    }
    
    try {
      rows[rowIndex][field] = value;
      
      // AUTOMATYCZNIE AKTUALIZUJ REPS TYPE Z ZABEZPIECZENIAMI
      // if (field == "colRepMin" || field == "colRepMax") {
      //   final repMinStr = rows[rowIndex]["colRepMin"] ?? "0";
      //   final repMaxStr = rows[rowIndex]["colRepMax"] ?? "0";
      //   final repMin = int.tryParse(repMinStr) ?? 0;
      //   final repMax = int.tryParse(repMaxStr) ?? 0;
      //   rows[rowIndex]["repsType"] = (repMin != repMax) ? "range" : "single";
      //   print("🔄 Updated repsType for $exerciseId set ${rowIndex + 1}: ${rows[rowIndex]["repsType"]}");
      // }
      
      print("📝 Updated $exerciseId set ${rowIndex + 1}: $field = '$value'");
    } catch (e) {
      print("❌ Error updating row value: $e");
    }
  }

  //  USUŃ SET Z POPRAWNYMI NAZWAMI
  void removeRow(String exerciseId, int index) {
    print("🗑️ Removing row $index from exercise: $exerciseId");
    
    if (!exerciseRows.containsKey(exerciseId) || exerciseRows[exerciseId] == null) {
      print("❌ Exercise $exerciseId not found or null");
      return;
    }
    
    final exerciseData = exerciseRows[exerciseId]!;
    if (exerciseData["rows"] == null) {
      print("❌ Exercise rows are null for $exerciseId");
      return;
    }
    
    final rows = exerciseData["rows"] as List<Map<String, String>>;
    
    if (!SelectedExerciseListHelpers.canRemoveSet(rows)) {
      print("❌ Cannot remove set - minimum one set required");
      return;
    }
    
    if (index >= rows.length || index < 0) {
      print("❌ Invalid index $index for exercise $exerciseId (max: ${rows.length - 1})");
      return;
    }

    //  USUŃ KONTROLERY Z ZABEZPIECZENIAMI
    if (kgControllers[exerciseId] != null && kgControllers[exerciseId]!.length > index) {
      kgControllers[exerciseId]![index].dispose();
      kgControllers[exerciseId]!.removeAt(index);
    }

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
    print("  📊 Remaining sets: ${rows.length}");
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