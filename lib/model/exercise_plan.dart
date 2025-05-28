import 'package:flutter/material.dart';

class ExerciseTable {
  final int id;
  final String exercise_table;
  final List<ExerciseRowsData> rows;

  ExerciseTable({
    required this.id,
    required this.exercise_table,
    required this.rows,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise_table': exercise_table,
      'rows': rows.map((row) => row.toJson()).toList(),
    };
  }

  factory ExerciseTable.fromJson(Map<String, dynamic> json) {
    final rowsJson =
        (json['rows'] ?? json['rows_data']) as List<dynamic>? ?? [];
    return ExerciseTable(
      id: json['id'] ?? 0,
      exercise_table: json['exercise_table'] ?? "Unknown Table",
      rows:
          rowsJson
              .map(
                (row) => ExerciseRowsData.fromJson(row as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  @override
  String toString() {
    return 'ExerciseTable(id: $id, exercise_table: $exercise_table, rows: $rows)';
  }
}

class ExerciseRowsData {
  final String exercise_name;
  final String exercise_number;
  final String notes;
  final List<ExerciseRow> data;

  ExerciseRowsData({
    required this.exercise_name,
    required this.exercise_number,
    required this.notes,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'exercise_name': exercise_name,
      'exercise_number': exercise_number,
      'notes': notes,
      'data': data.map((row) => row.toJson()).toList(),
    };
  }

  factory ExerciseRowsData.fromJson(Map<String, dynamic> json) {
     print("Parsing exercise_number from backend: ${json['exercise_number']}");
    final dataJson = json['data'] as List<dynamic>? ?? [];
    return ExerciseRowsData(
      exercise_number: json['exercise_number']?.toString() ?? "Unknown Number",
      exercise_name: json['exercise_name'] ?? "Unknown Exercise",
      notes: json['notes'] ?? "",
      data:
          dataJson
              .map((row) => ExerciseRow.fromJson(row as Map<String, dynamic>))
              .toList(),
    );
  }
  @override
  String toString() {
    return 'ExerciseRowsData(exercise_name: $exercise_name, exercise_number: $exercise_number, notes: $notes, data: $data)';
  }
}

class ExerciseRow {
  final int colStep;
  int colKg;
  int colRep;

  bool isChecked;
  Color? rowColor;

  ExerciseRow({
    required this.colStep,
    required this.colKg,
    required this.colRep,
    this.isChecked = false,
    this.rowColor,
  });

  Map<String, dynamic> toJson() {
    return {'colStep': colStep, 'colKg': colKg, 'colRep': colRep};
  }

  factory ExerciseRow.fromJson(Map<String, dynamic> json) {
    return ExerciseRow(
      colStep: json['colStep'] ?? 0,
      colKg: json['colKg'] ?? 0,
      colRep: json['colRep'] ?? 0,
    );
  }


  @override
  String toString() {
    return 'ExerciseRow(colStep: $colStep, colKg: $colKg, colRep: $colRep)';
  }
}
