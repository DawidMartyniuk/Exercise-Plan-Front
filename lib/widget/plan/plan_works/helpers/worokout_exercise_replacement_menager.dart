import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/reps_type.dart';

class WorkoutExerciseReplacementManager {
  final Map<String,Map<String, dynamic>> _pendingReplacementData ={};

//TODO : ABY PRZEDZIAŁ TEŻ ZAPAMIĘTYWALO
  // zapisz dane ćwiczenie przed zmiana 

  Map<String,dynamic> saveExerciseDataFromPlan({
    required String exerciseNumber,
    required ExerciseTable workingPlan,
  }) {
     print("💾 Saving exercise data for: $exerciseNumber");
    //znajduje ćwiczenie
    final exerciseRowData = workingPlan.rows.firstWhere(
      (rowData)=> 
      rowData.exercise_number == exerciseNumber,
      orElse:  () => throw Exception("Exercise $exerciseNumber not found in plan"),
      );

        final List<Map<String, dynamic>> savedSets = [];


      for(final row in exerciseRowData.data){
        final setData = {
          "colStep": row.colStep,
          "colKg": row.colKg,
          "colRepMin": row.colRepMin,
          "colRepMax": row.colRepMax,
          "isChecked": row.isChecked,
          "isFailure": row.isFailure,
          "isUserModified": row.isUserModified,
          "weightType": row.weightType.toDbString(),
        };
        savedSets.add(setData);
          print("  💾 Saved Set ${row.colStep}: ${row.colKg}kg x ${row.colRepMin}-${row.colRepMax} reps, checked: ${row.isChecked}");
      }
      final result = {
        "exerciseName": exerciseRowData.exercise_name,
        "notes": exerciseRowData.notes,
        "repType" : exerciseRowData.rep_type.toDbString(),
        "sets": savedSets,
        "timestamp" : DateTime.now().millisecondsSinceEpoch,
      };
      return result;
      //Developer: Show Running Extension
  }
    /// Zastępuje ćwiczenie w planie nowym, przywracając dane
  void replaceExerciseInPlan({
    required String oldExerciseNumber,
    required Exercise newExercise, // ✅ ZMIEŃ Z newExerciseNumber na newExercise
    required ExerciseTable workingPlan,
    required Map<String, dynamic> savedData,
    required VoidCallback onStateChanged,
  }) {
    print("🔄 Replacing exercise $oldExerciseNumber with ${newExercise.name} (${newExercise.id})");
    
    // Znajdź indeks ćwiczenia do zastąpienia
    final exerciseIndex = workingPlan.rows.indexWhere(
      (rowData) => rowData.exercise_number == oldExerciseNumber,
    );
    
    if (exerciseIndex == -1) {
      print("❌ Exercise $oldExerciseNumber not found in plan, cannot replace");
      return;
    }

    final List<Map<String, dynamic>> savedSets = (savedData["sets"] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    // Stwórz nowe wiersze danych z zapisanych informacji
    final List<ExerciseRow> newRows = [];

    for (int i = 0; i < savedSets.length; i++) {
      final setData = savedSets[i];

      final newRow = ExerciseRow(
        colStep: i + 1, // Przenumeruj serie
        colKg: setData["colKg"] ?? 0,
        colRepMin: setData["colRepMin"] ?? 0,
        colRepMax: setData["colRepMax"] ?? setData["colRepMin"] ?? 0,
        isChecked: setData["isChecked"] ?? false,
        isFailure: setData["isFailure"] ?? false,
        isUserModified: setData["isUserModified"] ?? false,
        rowColor: (setData["isChecked"] ?? false) 
            ? const Color.fromARGB(255, 103, 189, 106) 
            : Colors.transparent,
      );
      newRows.add(newRow);
      print("  🔄 Restored Set ${newRow.colStep}: ${newRow.colKg}kg x ${newRow.colRepMin}-${newRow.colRepMax} reps, checked: ${newRow.isChecked}");
    }
    
    // ✅ STWÓRZ NOWE DANE ĆWICZENIA Z EXERCISE OBIEKTU
    final newExerciseRowData = ExerciseRowsData(
      exercise_name: newExercise.name, // ✅ Z EXERCISE OBIEKTU
      exercise_number: newExercise.id, // ✅ Z EXERCISE OBIEKTU
      notes: savedData["notes"]?.toString() ?? "",
      rep_type: RepsType.fromString(savedData["repType"]?.toString() ?? "single"),
      data: newRows,
    );
    
    // Zastąp ćwiczenie w planie
    workingPlan.rows[exerciseIndex] = newExerciseRowData;
    
    print("✅ Exercise replaced successfully:");
    print("  - Old: $oldExerciseNumber");
    print("  - New: ${newExercise.name} (${newExercise.id})");
    print("  - Sets transferred: ${newRows.length}");
    print("  - Notes transferred: '${newExerciseRowData.notes}'");
    
    onStateChanged();
  }
  void storePendingData(String exerciseNumber, Map<String, dynamic> savedData) {
    _pendingReplacementData[exerciseNumber] = savedData;
    print("📦 Stored pending replacement data for: $exerciseNumber");
  }
   Map<String, dynamic>? getPendingData(String exerciseNumber) {
    return _pendingReplacementData[exerciseNumber];
  }
  void clearPendingData(String exerciseNumber) {
    _pendingReplacementData.remove(exerciseNumber);
    print("🗑️ Cleared pending data for: $exerciseNumber");
  }
   bool hasPendingData(String exerciseNumber) {
    return _pendingReplacementData.containsKey(exerciseNumber);
  }
  void logExerciseReplacementInfo({
    required String exerciseNumber,
    required ExerciseTable workingPlan,
  }) {
    print("🔍 Exercise replacement info for: $exerciseNumber");
    
    try {
      final exerciseRowData = workingPlan.rows.firstWhere(
        (rowData) => rowData.exercise_number == exerciseNumber,
      );
      
      print("  - Exercise name: ${exerciseRowData.exercise_name}");
      print("  - Rep type: ${exerciseRowData.rep_type}");
      print("  - Notes: '${exerciseRowData.notes}'");
      print("  - Sets count: ${exerciseRowData.data.length}");
      
      for (final row in exerciseRowData.data) {
        print("    Set ${row.colStep}: ${row.colKg}kg x ${row.colRepMin}-${row.colRepMax}, checked: ${row.isChecked}");
      }
    } catch (e) {
      print("  ❌ Exercise not found: $e");
    }
  }
  void clearAllPendingData() {
    final count = _pendingReplacementData.length;
    _pendingReplacementData.clear();
    print("🗑️ Cleared all pending replacement data ($count items)");
  }
    bool canReplaceExercise({
    required String exerciseNumber,
    required ExerciseTable workingPlan,
  }) {
    try {
      final exerciseRowData = workingPlan.rows.firstWhere(
        (rowData) => rowData.exercise_number == exerciseNumber,
      );
      
      final hasData = exerciseRowData.data.isNotEmpty;
      print("🔍 Can replace exercise $exerciseNumber: $hasData");
      return hasData;
    } catch (e) {
      print("⚠️ Cannot replace exercise $exerciseNumber: $e");
      return false;
    }
  }


}