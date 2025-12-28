import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';

class SelectedExerciseListHelpers {
  /// Bezpieczna konwersja danych z dynamic do List<Map<String, String>>
  static List<Map<String, String>> safeConvertToMapList(dynamic data) {
    final List<Map<String, String>> result = [];
    
    if (data is List) {
      for (dynamic item in data) {
        if (item is Map) {
          final Map<String, String> convertedMap = {};
          item.forEach((key, value) {
            convertedMap[key.toString()] = value.toString();
          });
          result.add(convertedMap);
        }
      }
    }
    
    return result;
  }

  /// Sprawdza czy ćwiczenie ma zainicjalizowane dane
  static bool hasInitializedData(String exerciseId, Map<String, Map<String, dynamic>> exerciseRows) {
    return exerciseRows.containsKey(exerciseId) && exerciseRows[exerciseId] != null;
  }

  /// Pobiera listę setów dla danego ćwiczenia
  static List<Map<String, String>> getExerciseTableData(
    String exerciseId, 
    Map<String, Map<String, dynamic>> exerciseRows
  ) {
    if (!hasInitializedData(exerciseId, exerciseRows)) {
      return [];
    }
    
    try {
      final exerciseData = exerciseRows[exerciseId]!;
      final rows = exerciseData["rows"];
      if (rows == null) return [];
      
      return List<Map<String, String>>.from(rows);
    } catch (e) {
      print("❌ Error getting exercise table data: $e");
      return [];
    }
  }

  /// Generuje domyślne dane dla nowego ćwiczenia
  static Map<String, dynamic> generateDefaultExerciseData(Exercise exercise) {
    return {
      "exerciseName": exercise.name,
      "notes": "",
      "rows": [
        {"colStep": "1", "colKg": "0", "colRep": "0", "colRepMax": "0"}
      ]
    };
  }

  // ✅ POPRAWIONA METODA generateNewSetFromLast Z ZABEZPIECZENIAMI
  static Map<String, String> generateNewSetFromLast(List<Map<String, String>> rows, int setNumber) {
    print("🔄 Generating new set $setNumber from existing ${rows.length} sets");
    
    if (rows.isEmpty) {
      print("  📋 No existing sets, creating default set");
      return {
        "colStep": setNumber.toString(),
        "colKg": "0",
        "colRepMin": "0",
        "colRepMax": "0",
        "repsType": "single",
      };
    }
    
    try {
      final lastRow = rows.last;
      
      final newSet = {
        "colStep": setNumber.toString(),
        "colKg": lastRow["colKg"] ?? "0",
        "colRepMin": lastRow["colRepMin"] ?? "0",
        "colRepMax": lastRow["colRepMax"] ?? lastRow["colRepMin"] ?? "0",
        "repsType": lastRow["repsType"] ?? "single",
      };
      
      print("  📋 Generated set from last: $newSet");
      return newSet;
    } catch (e) {
      print("  ❌ Error generating set from last: $e, creating default");
      return {
        "colStep": setNumber.toString(),
        "colKg": "0",
        "colRepMin": "0",
        "colRepMax": "0",
        "repsType": "single",
      };
    }
  }

  /// Aktualizuje numery setów po usunięciu
  static void updateSetNumbers(List<Map<String, String>> rows) {
    try {
      for (int i = 0; i < rows.length; i++) {
        rows[i]["colStep"] = (i + 1).toString();
            }
    } catch (e) {
      print("❌ Error updating set numbers: $e");
    }
  }

  /// Sprawdza czy można usunąć set (musi zostać przynajmniej jeden)
  static bool canRemoveSet(List<Map<String, String>> rows) {
    return rows.length > 1;
  }

  /// Loguje dane ćwiczenia do konsoli
  static void logExerciseData(String exerciseId, Exercise exercise, {
    Map<String, List<TextEditingController>>? kgControllers,
    Map<String, List<TextEditingController>>? repMinControllers,
    Map<String, List<TextEditingController>>? repMaxControllers,
    Map<String, TextEditingController>? notesControllers,
  }) {
    print("🔍 Exercise Data for: ${exercise.name} (ID: $exerciseId)");
    
    if (kgControllers?[exerciseId] != null) {
      print("📊 KG values:");
      for (int i = 0; i < kgControllers![exerciseId]!.length; i++) {
        print("  Set ${i + 1}: ${kgControllers[exerciseId]![i].text}kg");
      }
    }

    // Logowanie repMin i repMax razem
    final repMinList = repMinControllers?[exerciseId];
    final repMaxList = repMaxControllers?[exerciseId];
    if (repMinList != null && repMaxList != null) {
      print("🔄 REP values (min-max):");
      final setCount = repMinList.length < repMaxList.length ? repMinList.length : repMaxList.length;
      for (int i = 0; i < setCount; i++) {
        print("  Set ${i + 1}: ${repMinList[i].text} - ${repMaxList[i].text} reps");
      }
    } else if (repMinList != null) {
      print("🔄 REP MIN values:");
      for (int i = 0; i < repMinList.length; i++) {
        print("  Set ${i + 1}: ${repMinList[i].text} reps");
      }
    } else if (repMaxList != null) {
      print("🔄 REP MAX values:");
      for (int i = 0; i < repMaxList.length; i++) {
        print("  Set ${i + 1}: ${repMaxList[i].text} reps");
      }
    }

    if (notesControllers?[exerciseId] != null) {
      print("💾 Notes: '${notesControllers![exerciseId]!.text}'");
    }
  }

  // ✅ DODAJ METODĘ DEBUG
  static void debugExerciseData(String exerciseId, Map<String, Map<String, dynamic>> exerciseRows) {
    print("🔍 Debug data for exercise: $exerciseId");
    
    if (!exerciseRows.containsKey(exerciseId)) {
      print("  ❌ Exercise not found in exerciseRows");
      return;
    }
    
    final exerciseData = exerciseRows[exerciseId];
    if (exerciseData == null) {
      print("  ❌ Exercise data is null");
      return;
    }
    
    print("  📊 Exercise data keys: ${exerciseData.keys.toList()}");
    print("  📝 Exercise name: ${exerciseData['exerciseName']}");
    print("  📝 Notes: '${exerciseData['notes']}'");
    
    final rows = exerciseData["rows"];
    if (rows == null) {
      print("  ❌ Rows are null");
    } else if (rows is List) {
      print("  📋 Rows count: ${rows.length}");
      for (int i = 0; i < rows.length; i++) {
        print("    Set ${i + 1}: ${rows[i]}");
      }
    } else {
      print("  ❌ Rows are not a List: ${rows.runtimeType}");
    }
  }
}