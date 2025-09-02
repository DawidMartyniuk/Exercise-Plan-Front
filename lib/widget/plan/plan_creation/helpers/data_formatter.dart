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

  ///  NAPRAWIONA METODA - formatuje dane planu do wysłania na backend
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
          "rep_type": exerciseRepTypes[exerciseId] ?? "range", //  DOMYŚLNIE range
          "data": rows.map((row) {
            final repValue = int.tryParse(row["colRep"] ?? "0") ?? 0;
            return {
              "colStep": int.tryParse(row["colStep"] ?? "0") ?? 0,
              "colKg": _parseWeight(row["colKg"] ?? "0"),
              "colRepMin": repValue,     //  ZMIENIONE z colRep na colRepMin
              "colRepMax": repValue,     //  DODANE - dla single będzie ta sama wartość
              "weight_unit": "kg",       //  DODANE
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

  ///  METODĘ Z NAZWAMI ĆWICZEŃ - ZGODNA Z BACKENDEM
 static Map<String, dynamic> formatPlanDataWithNames({
    required Map<String, List<Map<String, String>>> tableData,
    required String planTitle,
    required Map<String, String> exerciseNames,
    required Map<String, String> exerciseRepTypes,
    Map<String, String>? exerciseNotes, 
    required String weightType,
  }) {
    print("🔄 Formatting plan data with names...");

    final exercises = <Map<String, dynamic>>[];

    final groupedData = <String, List<Map<String, String>>>{};
    
    for (final entry in tableData.entries) {
      final exerciseId = entry.key;
      final rows = entry.value;
      
      if (groupedData.containsKey(exerciseId)) {
        groupedData[exerciseId]!.addAll(rows);
      } else {
        groupedData[exerciseId] = List.from(rows);
      }
    }

    final exerciseGroupedData = <String, List<List<Map<String, dynamic>>>>{};
    
    for (final entry in groupedData.entries) {
      final exerciseId = entry.key;
      final rows = entry.value;

      final formattedRows = rows.map((row) {
        final repMinValue = int.tryParse(row["colRepMin"] ?? "0") ?? 0;
        final repMaxValue = int.tryParse(row["colRepMax"] ?? row["colRepMin"] ?? "0") ?? repMinValue;
        
        return {
          "colStep": int.tryParse(row["colStep"] ?? "0") ?? 0,
          "colKg": _parseWeight(row["colKg"] ?? "0"),
          "colRepMin": repMinValue,
          "colRepMax": repMaxValue,
          "weight_unit": weightType,
        };
      }).toList();

      if (!exerciseGroupedData.containsKey(exerciseId)) {
        exerciseGroupedData[exerciseId] = [];
      }
      exerciseGroupedData[exerciseId]!.add(formattedRows);
    }

    for (final entry in exerciseGroupedData.entries) {
      final exerciseId = entry.key;
      final rowGroups = entry.value;

      for (final rows in rowGroups) {
        exercises.add({
          "exercise_table": planTitle,
          "rows": [
            {
              "exercise_name": exerciseNames[exerciseId] ?? "Unknown Exercise",
              "exercise_number": exerciseId,
              "notes": exerciseNotes?[exerciseId] ?? "", // ✅ DODAJ NOTATKI
              "rep_type": exerciseRepTypes[exerciseId] ?? "single", // ✅ DODAJ REP TYPE
              "data": rows,
            }
          ]
        });
      }
    }

    return {"exercises": exercises};
  }
  static Map<String, dynamic> formatPlanDataForUpdate({
    required String planTitle,
    required Map<String, List<Map<String, String>>> tableData,
    required Map<String, String> exerciseNames,
    required Map<String, String> exerciseRepTypes,
    required Map<String, String> exerciseNotes,
  }) {
    print("🔄 Formatting plan data for update...");
    print("  - Plan title: $planTitle");
    print("  - Exercises count: ${exerciseNames.length}");

    final rows = <Map<String, dynamic>>[];

    for (final entry in tableData.entries) {
      final exerciseId = entry.key;
      final exerciseRows = entry.value;

      print("  📋 Formatting exercise: $exerciseId");
      print("    - Name: ${exerciseNames[exerciseId]}");
      print("    - Sets count: ${exerciseRows.length}");
      print("    - Rep type: ${exerciseRepTypes[exerciseId]}");
      print("    - Notes: '${exerciseNotes[exerciseId]}'");

      final formattedData = exerciseRows.map((row) {
        final repMin = int.tryParse(row["colRepMin"] ?? "0") ?? 0;
        final repMax = int.tryParse(row["colRepMax"] ?? row["colRepMin"] ?? "0") ?? repMin;
        final step = int.tryParse(row["colStep"] ?? "1") ?? 1;
        final weight = _parseWeight(row["colKg"] ?? "0");

        return {
          "colStep": step,
          "colKg": weight,
          "colRepMin": repMin,
          "colRepMax": repMax,
          "weight_unit": "kg", // Można dodać obsługę preferencji użytkownika
        };
      }).toList();

      rows.add({
        "exercise_number": exerciseId,
        "exercise_name": exerciseNames[exerciseId] ?? "Unknown Exercise",
        "notes": exerciseNotes[exerciseId] ?? "",
        "rep_type": exerciseRepTypes[exerciseId] ?? "single",
        "data": formattedData,
      });
    }

    final result = {
      "exercise_table": planTitle,
      "rows": rows,
    };

    print("✅ Plan data formatted for update:");
    print("  - exercise_table: $planTitle");
    print("  - rows count: ${rows.length}");

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

