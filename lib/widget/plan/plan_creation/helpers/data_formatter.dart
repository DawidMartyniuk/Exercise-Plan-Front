import 'package:collection/collection.dart';

class DataFormatter {
  /// Formatuje dane tabeli dla kompatybilności z poprzednim kodem
  static Map<String, List<Map<String, String>>> formatTableData({
    required Map<String, List<Map<String, String>>> tableData,
    required String planTitle,
  }) {
    return tableData.map((exerciseId, rows) {
      return MapEntry(exerciseId, [
        {"exercise_table": planTitle},
        ...rows,
      ]);
    });
  }

  /// Formatuje dane planu do wysłania na backend
  static Map<String, dynamic> formatPlanData({
    required Map<String, List<Map<String, String>>> tableData,
    required String planTitle,
  }) {
    final allRows = tableData.entries
        .expand((entry) => entry.value)
        .where((row) => row["exercise_name"] != null && row["exercise_name"]!.trim().isNotEmpty)
        .toList();

    final grouped = groupBy<Map<String, String>, String>(
      allRows,
      (row) => "${row["exercise_name"]}|||${row["notes"] ?? ""}",
    );

    final groupedList = grouped.entries.map((entry) {
      final keyParts = entry.key.split("|||");
      final firstRow = entry.value.first;

      return {
        "exercise_name": keyParts[0],
        "exercise_number": firstRow["exercise_number"] ?? "1",
        "notes": keyParts.length > 1 ? keyParts[1] : "",
        "data": entry.value.map((row) {
          return {
            "colStep": int.tryParse(row["colStep"] ?? "0") ?? 0,
            "colKg": _parseWeight(row["colKg"] ?? "0"),
            "colRep": int.tryParse(row["colRep"] ?? "0") ?? 0,
          };
        }).toList(),
      };
    }).toList();

    return {
      "exercises": [
        {
          "exercise_table": planTitle.isNotEmpty ? planTitle : "Plan treningowy",
          "rows": groupedList,
        },
      ],
    };
  }

  /// Formatuje dane z formularza do formatu używanego przez SelectedExerciseList
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
    
    // Sprawdź czy zawiera kropkę (liczba dziesiętna)
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
        final reps = int.tryParse(row["colRep"] ?? "0") ?? 0;
        
        if (kg > 0 && reps > 0) {
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