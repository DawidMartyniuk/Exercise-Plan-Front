import 'package:collection/collection.dart';
import 'package:work_plan_front/provider/repsTypeProvider.dart';

class DataFormatter {
  
  static Map<String, List<Map<String, String>>> formatTableData({
    required Map<String, List<Map<String, String>>> tableData,
    required String planTitle,
    required Map<String, String> exerciseRepTypes,
  }) {
    return tableData.map((exerciseId, rows) {
      return MapEntry(exerciseId, [
        {"exercise_table": planTitle},
        ...rows,
      ]);
    });
  }

  /// ✅ NAPRAWIONA METODA - formatuje dane planu do wysłania na backend
  static Map<String, dynamic> formatPlanData({
    required Map<String, List<Map<String, String>>> tableData,
    required String planTitle,
    required Map<String, String> exerciseRepTypes,
  }) {
    print("🔄 DataFormatter: Processing ${tableData.length} exercises");
    
    final List<Map<String, dynamic>> groupedList = [];
    
    tableData.forEach((exerciseId, rows) {
      print("  - Processing exercise $exerciseId with ${rows.length} sets");
      
      if (rows.isNotEmpty) {
        groupedList.add({
          "exercise_name": "Exercise $exerciseId",
          "exercise_number": exerciseId,
          "notes": "",
          "rep_type": exerciseRepTypes[exerciseId] ?? "range", // ✅ DOMYŚLNIE range
          "data": rows.map((row) {
            final repValue = int.tryParse(row["colRep"] ?? "0") ?? 0;
            return {
              "colStep": int.tryParse(row["colStep"] ?? "0") ?? 0,
              "colKg": _parseWeight(row["colKg"] ?? "0"),
              "colRepMin": repValue,     // ✅ ZMIENIONE z colRep na colRepMin
              "colRepMax": repValue,     // ✅ DODANE - dla single będzie ta sama wartość
              "weight_unit": "kg",       // ✅ DODANE
            };
          }).toList(),
        });
        print("    ✅ Added exercise with ${rows.length} sets");
      }
    });

    final result = {
      "exercises": [
        {
          "exercise_table": planTitle.isNotEmpty ? planTitle : "Plan treningowy",
          "rows": groupedList,
        },
      ],
    };
    
    print("📤 DataFormatter result:");
    print("  - exercise_table: ${result['exercises']?[0]['exercise_table']}");
    print("  - rows count: ${groupedList.length}");
    
    return result;
  }

  /// ✅ METODĘ Z NAZWAMI ĆWICZEŃ - ZGODNA Z BACKENDEM
  static Map<String, dynamic> formatPlanDataWithNames({
    required Map<String, List<Map<String, String>>> tableData,
    required String planTitle,
    required Map<String, String> exerciseNames,
    required Map<String, String> exerciseRepTypes,
  }) {
    print("🔄 DataFormatter: Processing ${tableData.length} exercises with names");
    print("🔍 exerciseRepTypes received: $exerciseRepTypes");
    
    final List<Map<String, dynamic>> groupedList = [];
    
    tableData.forEach((exerciseId, rows) {
      final exerciseName = exerciseNames[exerciseId] ?? "Unknown Exercise";
      final repType = exerciseRepTypes[exerciseId] ?? "range"; // ✅ DOMYŚLNIE range
      
      print("  - Processing exercise: $exerciseName ($exerciseId) with ${rows.length} sets");
      print("  - Rep type for $exerciseId: $repType");
    
      if (rows.isNotEmpty) {
        final exerciseData = {
          "exercise_name": exerciseName,
          "exercise_number": exerciseId,
          "notes": "",
          "rep_type": repType, // ✅ single lub range
          "data": rows.map((row) {
            final repMinValue = int.tryParse(row["colRepMin"] ?? "0") ?? 0; // ✅ ZMIENIONE z colRep
            final repMaxValue = int.tryParse(row["colRepMax"] ?? row["colRepMin"] ?? "0") ?? 0;
            
            return {
              "colStep": int.tryParse(row["colStep"] ?? "0") ?? 0,
              "colKg": _parseWeight(row["colKg"] ?? "0"),
              "colRepMin": repMinValue,    // ✅ BACKEND OCZEKUJE
              "colRepMax": repMaxValue,    // ✅ BACKEND OCZEKUJE
              "weight_unit": "kg",
            };
          }).toList(),
        };
      
        print("  - Exercise data structure: ${exerciseData.keys.toList()}");
        print("  - Rep type value: ${exerciseData['rep_type']}");
        print("  - First set data: ${(exerciseData['data'] as List).isNotEmpty ? (exerciseData['data'] as List)[0] : 'EMPTY'}");
      
        groupedList.add(exerciseData);
        print("    ✅ Added $exerciseName with ${rows.length} sets");
      }
    });

    final result = {
      "exercises": [
        {
          "exercise_table": planTitle.isNotEmpty ? planTitle : "Plan treningowy",
          "rows": groupedList,
        },
      ],
    };
    
    print("📤 DataFormatter final result:");
    print("  - exercise_table: ${result['exercises']?[0]['exercise_table']}");
    print("  - rows count: ${groupedList.length}");
    
    if (groupedList.isNotEmpty) {
      final firstExercise = groupedList[0];
      print("  - First exercise keys: ${firstExercise.keys.toList()}");
      print("  - First exercise rep_type: ${firstExercise['rep_type']}");
      if ((firstExercise['data'] as List).isNotEmpty) {
        final firstSet = (firstExercise['data'] as List)[0];
        print("  - First set keys: ${firstSet.keys.toList()}");
      }
    }
    
    return result;
  }

  static Map<String, List<Map<String, String>>> formatExerciseTableData({
    required Map<String, Map<String, dynamic>> exerciseRows,
    required Map<String, String> exerciseNames,
  }) {
    int exerciseCounter = 1;
    
    return exerciseRows.map((exerciseId, data) {
      final rawRows = data["rows"] as List<dynamic>? ?? [];
      final exerciseName = exerciseNames[exerciseId] ?? "Unknown Exercise";
      final notes = data["notes"]?.toString() ?? "";
      
      final rows = rawRows.map((row) {
        final rowMap = Map<String, dynamic>.from(row);
        return {
          "exercise_name": exerciseName,
          "exercise_number": exerciseId,
          "notes": notes,
          "colStep": rowMap["colStep"]?.toString() ?? "0",
          "colKg": rowMap["colKg"]?.toString() ?? "0",
          "colRep": rowMap["colRep"]?.toString() ?? "0",
        };
      }).toList();
      
      exerciseCounter++;
      return MapEntry(exerciseId, rows);
    });
  }

  /// Parsuje wagę obsługując zarówno int jak i double
  static dynamic _parseWeight(String weightStr) {
    final trimmed = weightStr.trim();
    if (trimmed.isEmpty) return 0;
    
    if (trimmed.contains('.')) {
      return double.tryParse(trimmed) ?? 0.0;
    } else {
      return int.tryParse(trimmed) ?? 0;
    }
  }

  /// Konwertuje dane z backendu do formatu używanego w aplikacji
  static Map<String, List<Map<String, String>>> parseBackendData(
    Map<String, dynamic> backendData
  ) {
    final exercises = backendData["exercises"] as List<dynamic>? ?? [];
    final result = <String, List<Map<String, String>>>{};
    
    for (final exercise in exercises) {
      final rows = exercise["rows"] as List<dynamic>? ?? [];
      final exerciseId = exercise["exercise_id"]?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      final formattedRows = rows.map((row) {
        final data = row["data"] as List<dynamic>? ?? [];
        return data.map((setData) => {
          "exercise_name": row["exercise_name"]?.toString() ?? "",
          "exercise_number": exerciseId,
          "notes": row["notes"]?.toString() ?? "",
          "colStep": setData["colStep"]?.toString() ?? "0",
          "colKg": setData["colKg"]?.toString() ?? "0",
          "colRep": setData["colRep"]?.toString() ?? "0",
        }).toList();
      }).expand((list) => list).toList();
      
      result[exerciseId] = formattedRows.cast<Map<String, String>>();
    }
    
    return result;
  }

  /// Waliduje dane przed formatowaniem
  static ValidationResult validateTableData(Map<String, List<Map<String, String>>> tableData) {
    final errors = <String>[];
    
    if (tableData.isEmpty) {
      errors.add("Brak danych ćwiczeń");
      return ValidationResult(isValid: false, errors: errors);
    }
    
    for (final entry in tableData.entries) {
      final exerciseId = entry.key;
      final rows = entry.value;
      
      if (rows.isEmpty) {
        errors.add("Ćwiczenie $exerciseId nie ma żadnych setów");
        continue;
      }
      
      bool hasValidSet = false;
      for (final row in rows) {
        final kg = double.tryParse(row["colKg"] ?? "0") ?? 0;
        final repsMin = int.tryParse(row["colRepMin"] ?? "0") ?? 0;
        final repsMax = int.tryParse(row["colRepMax"] ?? "0") ?? 0;

        if (kg > 0 && repsMin > 0 && repsMax > 0) {
          hasValidSet = true;
          break;
        }
      }
      
      if (!hasValidSet) {
        errors.add("Ćwiczenie $exerciseId musi mieć przynajmniej jeden set z wagą i powtórzeniami");
      }
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });
}

