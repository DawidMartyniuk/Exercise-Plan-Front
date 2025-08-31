import 'package:flutter/material.dart';
import 'package:work_plan_front/model/reps_type.dart';
import 'package:work_plan_front/model/weight_type.dart';

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
  ExerciseTable copyWithRows(List<ExerciseRowsData> newRows) {
    return ExerciseTable(
      id: this.id,
      exercise_table: this.exercise_table,
      rows: newRows,
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
  final RepsType rep_type;

  ExerciseRowsData({
    required this.exercise_name,
    required this.exercise_number,
    required this.notes,
    required this.data,
    required this.rep_type,
  });

  Map<String, dynamic> toJson() {
    return {
      'exercise_name': exercise_name,
      'exercise_number': exercise_number,
      'rep_type': rep_type.toDbString(),
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
      rep_type: json['rep_type'] != null
          ? RepsType.fromString(json['rep_type'])
          : RepsType.single,
      notes: json['notes'] ?? "",
      data:
          dataJson
              .map((row) => ExerciseRow.fromJson(row as Map<String, dynamic>))
              .toList(),
    );
  }

  
  ExerciseRowsData copyWithData(List<ExerciseRow> newData) {
    return ExerciseRowsData(
      exercise_number: this.exercise_number,
      exercise_name: this.exercise_name,
      rep_type: this.rep_type,
      data: newData,
      notes: this.notes,
    );
  }
  
  ExerciseRowsData copyWith({
    String? exercise_number,
    String? exercise_name,
    List<ExerciseRow>? data,
    RepsType? rep_type,
    String? notes,
  }) {
    return ExerciseRowsData(
      exercise_number: exercise_number ?? this.exercise_number,
      exercise_name: exercise_name ?? this.exercise_name,
      rep_type: this.rep_type,
      data: data ?? this.data,
      notes: notes ?? this.notes,
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
  int colRepMin;
  int colRepMax;
  final WeightType weightType;
  bool isChecked;
  Color? rowColor;
  bool isFailure;
  bool isUserModified; 

  ExerciseRow({
    required this.colStep,
    required this.colKg,
    required this.colRepMin,
    int? colRepMax ,
    this.weightType = WeightType.kg,
    this.isChecked = false,
    this.isFailure = false,
    this.rowColor,
    this.isUserModified = false,
  }) : colRepMax = colRepMax ?? colRepMin;

  ExerciseRow copyWith({
    int? colStep,
    int? colKg,
    int? colRepMin,
    int? colRepMax,
    bool? isChecked,
    bool? isFailure,
    Color? rowColor,
    WeightType? weightType,
    bool? isUserModified,
  }) {
    return ExerciseRow(
      colStep: colStep ?? this.colStep,
      colKg: colKg ?? this.colKg,
      colRepMin: colRepMin ?? this.colRepMin,
      colRepMax: colRepMax ?? this.colRepMax,
      isChecked: isChecked ?? this.isChecked,
      isFailure: isFailure ?? this.isFailure,
      rowColor: rowColor ?? this.rowColor,
      weightType: weightType ?? this.weightType,
      isUserModified: isUserModified ?? this.isUserModified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'colStep': colStep,
      'colKg': colKg,
      'colRepMin': colRepMin,
      'colRepMax': colRepMax,
      'weight_type': weightType.toDbString(),
      'isChecked': isChecked,
      'isFailure': isFailure,
      };
  }

  factory ExerciseRow.fromJson(Map<String, dynamic> json) {
    return ExerciseRow(
      colStep: json['colStep'] ?? 0,
      colKg: json['colKg'] ?? 0,
      colRepMin: json['colRepMin'] ?? 0,
      colRepMax: json['colRepMax'] ?? json['colRepMin'] ?? 0,
      weightType: json['weight_type'] != null
          ? WeightType.fromString(json['weight_type'])
          : WeightType.kg,
      isChecked: json['isChecked'] ?? false,
      isFailure: json['isFailure'] ?? false,
    );
  }

  


   String getFormattedWeight() {
    return weightType.formatWeight(colKg.toDouble(), decimals: 0);
  }

  double getWeightInUnit(WeightType targetUnit) {
    return weightType.convertTo(colKg.toDouble(), targetUnit);
  }

  @override
  String toString() {
    return 'ExerciseRow(colStep: $colStep, colKg: $colKg, colRepMin: $colRepMin, colRepMax: $colRepMax, weightType: $weightType, isChecked: $isChecked, isFailure: $isFailure, rowColor: $rowColor)';
  }
}
