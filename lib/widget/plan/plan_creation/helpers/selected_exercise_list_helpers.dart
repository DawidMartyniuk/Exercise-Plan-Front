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
    return exerciseRows.containsKey(exerciseId);
  }

  /// Pobiera listę setów dla danego ćwiczenia
  static List<Map<String, String>> getExerciseTableData(
    String exerciseId, 
    Map<String, Map<String, dynamic>> exerciseRows
  ) {
    return (exerciseRows[exerciseId]?["rows"] as List<Map<String, String>>?) ?? [];
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

  /// Kopiuje wartości z ostatniego setu dla nowego setu
  static Map<String, String> generateNewSetFromLast(List<Map<String, String>> rows, int setNumber) {
    if (rows.isEmpty) {
      return {"colStep": "$setNumber", "colKg": "0", "colRep": "0", "colRepMax": "0"};
    }
    
    final lastRow = rows.last;
    return {
      "colStep": "$setNumber",
      "colKg": lastRow["colKg"] ?? "0",
      "colRep": lastRow["colRep"] ?? "0",
      "colRepMax": lastRow["colRepMax"] ?? "0",
    };
  }

  /// Aktualizuje numery setów po usunięciu
  static void updateSetNumbers(List<Map<String, String>> rows) {
    for (int i = 0; i < rows.length; i++) {
      rows[i]["colStep"] = "${i + 1}";
    }
  }

  /// Sprawdza czy można usunąć set (musi zostać przynajmniej jeden)
  static bool canRemoveSet(List<Map<String, String>> rows) {
    return rows.length > 1;
  }

  /// Loguje dane ćwiczenia do konsoli
  static void logExerciseData(String exerciseId, Exercise exercise, {
    Map<String, List<TextEditingController>>? kgControllers,
    Map<String, List<TextEditingController>>? repControllers,
    Map<String, TextEditingController>? notesControllers,
  }) {
    print("🔍 Exercise Data for: ${exercise.name} (ID: $exerciseId)");
    
    if (kgControllers?[exerciseId] != null) {
      print("📊 KG values:");
      for (int i = 0; i < kgControllers![exerciseId]!.length; i++) {
        print("  Set ${i + 1}: ${kgControllers[exerciseId]![i].text}kg");
      }
    }
    
    if (repControllers?[exerciseId] != null) {
      print("🔄 REP values:");
      for (int i = 0; i < repControllers![exerciseId]!.length; i++) {
        print("  Set ${i + 1}: ${repControllers[exerciseId]![i].text} reps");
      }
    }
    
    if (notesControllers?[exerciseId] != null) {
      print("💾 Notes: '${notesControllers![exerciseId]!.text}'");
    }
  }
}