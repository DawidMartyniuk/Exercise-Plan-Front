import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/widget/plan/plan_creation/helpers/selected_exercise_list_helpers.dart';

class ExerciseReplacementManager {
  final Map<String, Map<String, dynamic>> _pendingReplacementData = {};

  /// Zapisuje dane ćwiczenia przed zamianą
  Map<String, dynamic> saveExerciseData(
    String exerciseId,
    Map<String, List<TextEditingController>> kgControllers,
    Map<String, List<TextEditingController>> repMinControllers,
    Map<String, List<TextEditingController>> repMaxControllers,
    Map<String, TextEditingController> notesControllers, {
    String? repType, // <-- dodaj opcjonalnie
  }) {
    final List<Map<String, String>> savedSets = [];
    final String savedNotes = notesControllers[exerciseId]?.text ?? "";

    print("💾 Saving exercise data for: $exerciseId");

    final kgCtrlList = kgControllers[exerciseId] ?? [];
    final repMinCtrlList = repMinControllers[exerciseId] ?? [];
    final repMaxCtrlList = repMaxControllers[exerciseId] ?? [];

    final int setCount = [
      kgCtrlList.length,
      repMinCtrlList.length,
      repMaxCtrlList.length
    ].reduce((a, b) => a < b ? a : b);

    for (int i = 0; i < setCount; i++) {
      final kgValue = kgCtrlList[i].text;
      final repMinValue = repMinCtrlList[i].text;
      final repMaxValue = repMaxCtrlList[i].text;

      final Map<String, String> setData = <String, String>{
        "colStep": "${i + 1}",
        "colKg": kgValue,
        "colRepMin": repMinValue,
        "colRepMax": repMaxValue,
      };

      savedSets.add(setData);
      print("  💾 Saved Set ${i + 1}: ${kgValue}kg x $repMinValue-$repMaxValue reps");
    }

    String savedRepType = repType ??
      ((repMinCtrlList.isNotEmpty && repMaxCtrlList.isNotEmpty && repMinCtrlList[0].text != repMaxCtrlList[0].text)
        ? "range"
        : "single");

    final result = {
      "sets": savedSets,
      "notes": savedNotes,
      "rep_type": savedRepType, // <-- dodaj to!
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
    required Map<String, List<TextEditingController>> repMinControllers,
    required Map<String, List<TextEditingController>> repMaxControllers, // <-- dodaj
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
  "rep_type": savedData["rep_type"] ?? "single", // <-- dodaj to!
};
// DODAJ TO:
final repType = savedData["rep_type"] ?? "single";
final rows = exerciseRows[newExerciseId]?["rows"] as List<Map<String, String>>?;
if (rows != null) {
  for (final row in rows) {
    row["repsType"] = repType;
  }
}

    // Przywróć kontrolery
    _restoreControllers(
      newExerciseId,
      savedSets,
      savedNotes,
      notesControllers,
      kgControllers,
      repMinControllers,
      repMaxControllers, // <-- dodaj
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
    Map<String, List<TextEditingController>> repMinControllers,
    Map<String, List<TextEditingController>> repMaxControllers, // <-- dodaj
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
    kgControllers[exerciseId]?.forEach((c) => c.dispose());
    repMinControllers[exerciseId]?.forEach((c) => c.dispose());
    repMaxControllers[exerciseId]?.forEach((c) => c.dispose());

    kgControllers[exerciseId] = [];
    repMinControllers[exerciseId] = [];
    repMaxControllers[exerciseId] = [];

    for (int i = 0; i < savedSets.length; i++) {
      final kg = savedSets[i]["colKg"] ?? "0";
      final repMin = savedSets[i]["colRepMin"] ?? "0";
      final repMax = savedSets[i]["colRepMax"] ?? repMin;

      final kgController = TextEditingController(text: kg);
      final repMinController = TextEditingController(text: repMin);
      final repMaxController = TextEditingController(text: repMax);

      kgController.addListener(() =>
        updateRowCallback(exerciseId, i, "colKg", kgController.text));
      repMinController.addListener(() =>
        updateRowCallback(exerciseId, i, "colRepMin", repMinController.text));
      repMaxController.addListener(() =>
        updateRowCallback(exerciseId, i, "colRepMax", repMaxController.text));

      kgControllers[exerciseId]!.add(kgController);
      repMinControllers[exerciseId]!.add(repMinController);
      repMaxControllers[exerciseId]!.add(repMaxController);

      print("  ✅ Restored Set ${i + 1}: ${kg}kg x $repMin-$repMax reps");
    }

    print("✅ All controllers restored for exercise: $exerciseId");
  }

  /// Loguje dane przed zamianą
  void logReplacementData(
    Exercise exercise,
    Map<String, List<TextEditingController>> kgControllers,
    Map<String, List<TextEditingController>> repMinControllers,
    Map<String, List<TextEditingController>> repMaxControllers, // <-- dodaj ten argument!
    Map<String, TextEditingController> notesControllers,
  ) {
    final exerciseId = exercise.id;

    print("🔄 Replacing exercise: ${exercise.name}");
    SelectedExerciseListHelpers.logExerciseData(
      exerciseId,
      exercise,
      kgControllers: kgControllers,
      repMaxControllers: repMaxControllers, // <-- dodaj ten argument!
      repMinControllers: repMinControllers,
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