import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/widget/plan/plan_creation/helpers/selected_exercise_list_helpers.dart';

class ExerciseReplacementManager {
  final Map<String, Map<String, dynamic>> _pendingReplacementData = {};

  /// Zapisuje dane ćwiczenia przed zamianą
  Map<String, dynamic> saveExerciseData(
    String exerciseId,
    Map<String, List<TextEditingController>> kgControllers,
    Map<String, List<TextEditingController>> repMinControllers, // ✅ ZMIENIONE
    Map<String, TextEditingController> notesControllers,
  ) {
    final List<Map<String, String>> savedSets = [];
    final String savedNotes = notesControllers[exerciseId]?.text ?? "";
    
    print("💾 Saving exercise data for: $exerciseId");
    
    if (kgControllers[exerciseId] != null && repMinControllers[exerciseId] != null) {
      final kgCtrlList = kgControllers[exerciseId]!;
      final repCtrlList = repMinControllers[exerciseId]!;
      
      for (int i = 0; i < kgCtrlList.length && i < repCtrlList.length; i++) {
        final kgValue = kgCtrlList[i].text;
        final repValue = repCtrlList[i].text;
        
        final Map<String, String> setData = <String, String>{
          "colStep": "${i + 1}",
          "colRepMin": repValue, // ✅ ZMIENIONE z colRep
        "colRepMax": repValue, // ✅ DODAJ TO
    };
        
        savedSets.add(setData);
        print("  💾 Saved Set ${i + 1}: ${kgValue}kg x ${repValue} reps");
      }
    }
    
    final result = {
      "sets": savedSets,
      "notes": savedNotes,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };
    
    print("💾 Final saved data: $result");
    return result;
  }

  /// Przywraca dane do nowego ćwiczenia
  void restoreExerciseDataWithTransfer({
    required String newExerciseId,
    required String oldExerciseId,
    required Map<String, dynamic> savedData,
    required List<Exercise> exercises,
    required Map<String, Map<String, dynamic>> exerciseRows,
    required Map<String, TextEditingController> notesControllers,
    required Map<String, List<TextEditingController>> kgControllers,
    required Map<String, List<TextEditingController>> repControllers,
    required Function(String, int, String, String) updateRowCallback,
    required VoidCallback onStateChanged,
  }) {
    print("🔄 Transferring data from $oldExerciseId to $newExerciseId");
    print("🔄 Saved data to transfer: $savedData");
    
    final List<Map<String, String>> savedSets = SelectedExerciseListHelpers.safeConvertToMapList(savedData["sets"]);
    final String savedNotes = savedData["notes"]?.toString() ?? "";
    
    print("📊 Transferring ${savedSets.length} sets and notes: '$savedNotes'");
    
    // Przywróć dane ćwiczenia
    exerciseRows[newExerciseId] = {
      "exerciseName": exercises.firstWhere((e) => e.id == newExerciseId).name,
      "notes": savedNotes,
      "rows": savedSets,
    };
    
    // Przywróć kontrolery
    _restoreControllers(
      newExerciseId, 
      savedSets, 
      savedNotes,
      notesControllers,
      kgControllers,
      repControllers,
      updateRowCallback,
    );
    
    onStateChanged();
    print("✅ Data transferred successfully to new exercise ID: $newExerciseId");
  }

  /// Przywraca kontrolery z zapisanych danych
  void _restoreControllers(
    String exerciseId, 
    List<Map<String, String>> savedSets, 
    String savedNotes,
    Map<String, TextEditingController> notesControllers,
    Map<String, List<TextEditingController>> kgControllers,
    Map<String, List<TextEditingController>> repControllers,
    Function(String, int, String, String) updateRowCallback,
  ) {
    print("🔄 Restoring controllers for exercise: $exerciseId");
    print("🔄 Restoring ${savedSets.length} sets");

    // Przywróć notes controller
    if (notesControllers[exerciseId] != null) {
      notesControllers[exerciseId]!.text = savedNotes;
      print("  ✅ Restored notes controller");
    } else {
      notesControllers[exerciseId] = TextEditingController(text: savedNotes);
      print("  ✅ Created new notes controller");
    }

    // Wyczyść stare kontrolery
    if (kgControllers[exerciseId] != null) {
      for (var controller in kgControllers[exerciseId]!) {
        controller.dispose();
      }
    }
    if (repControllers[exerciseId] != null) {
      for (var controller in repControllers[exerciseId]!) {
        controller.dispose();
      }
    }

    // Utwórz nowe kontrolery
    kgControllers[exerciseId] = [];
    repControllers[exerciseId] = [];

    for (int i = 0; i < savedSets.length; i++) {
      final kg = savedSets[i]["colKg"] ?? "0";
      final reps = savedSets[i]["colRepMin"] ?? "0"; //  ZMIENIONE z colRep
      final repMax = savedSets[i]["colRepMax"] ?? reps;

      final kgController = TextEditingController(text: kg);
      final repController = TextEditingController(text: reps);

      kgController.addListener(() => 
        updateRowCallback(exerciseId, i, "colKg", kgController.text));
      repController.addListener(() => 
        updateRowCallback(exerciseId, i, "colRep", repController.text));

      kgControllers[exerciseId]!.add(kgController);
      repControllers[exerciseId]!.add(repController);

      print("  ✅ Restored Set ${i + 1}: ${kg}kg x ${reps} reps");
    }

    print("✅ All controllers restored for exercise: $exerciseId");
  }

  /// Loguje dane przed zamianą
  void logReplacementData(
    Exercise exercise,
    Map<String, List<TextEditingController>> kgControllers,
    Map<String, List<TextEditingController>> repMinControllers,
    Map<String, TextEditingController> notesControllers,
  ) {
    final exerciseId = exercise.id;
    
    print("🔄 Replacing exercise: ${exercise.name}");
    SelectedExerciseListHelpers.logExerciseData(
      exerciseId, 
      exercise,
      kgControllers: kgControllers,
      repControllers: repMinControllers, // ✅ZMIENIONE
      notesControllers: notesControllers,
    );
  }

  /// Przechowuje dane do późniejszego przywrócenia
  void storePendingData(String exerciseId, Map<String, dynamic> savedData) {
    _pendingReplacementData[exerciseId] = savedData;
  }

  /// Pobiera przechowane dane
  Map<String, dynamic>? getPendingData(String exerciseId) {
    return _pendingReplacementData[exerciseId];
  }

  /// Usuwa przechowane dane
  void clearPendingData(String exerciseId) {
    _pendingReplacementData.remove(exerciseId);
  }
}