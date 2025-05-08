class ExercisePlan {
  final userId;
   final List<ExerciseTable> exercises;

  ExercisePlan({
    required this.userId,
    required this.exercises,
  });

   Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
    };
  }

  factory ExercisePlan.fromJson(Map<String, dynamic> json) {
    return ExercisePlan(
      userId: json["user_id"] ?? 0,
      exercises: (json['exercises'] as List<dynamic>)
          .map((exercise) => ExerciseTable.fromJson(exercise as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ExerciseTable {
  final int id;
  final String user_id;
  final String exercise_table;
  final List<ExerciseRowsData> rows;

  ExerciseTable({
    required this.id,
    required this.user_id,
    required this.exercise_table,
    required this.rows,
  });

   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user_id,
      'exercise_table': exercise_table,
      'rows': rows.map((row) => row.toJson()).toList(),
    };
  }

  factory ExerciseTable.fromJson(Map<String, dynamic> json) {
    return ExerciseTable(
      id: json['id'] ?? 0,
      user_id: json['user_id'] ?? "Unknown User",
      exercise_table: json['exercise_table'] ?? "Unknown Table",
      rows: (json['rows'] as List<dynamic>)
          .map((row) => ExerciseRowsData.fromJson(row as Map<String, dynamic>))
          .toList(),
    );
  }
 

}

class ExerciseRow {
  final int row_data_id;
  final int colStep;
  final int colKg;
  final int colRep;

  ExerciseRow({
    required this.row_data_id,
    required this.colStep,
    required this.colKg,
    required this.colRep,
  });

    Map<String, dynamic> toJson() {
    return {
      'row_data_id': row_data_id,
      'colStep': colStep,
      'colKg': colKg,
      'colRep': colRep,
    };
  }

  factory ExerciseRow.fromJson(Map<String, dynamic> json) {
    return ExerciseRow(
      row_data_id: json['row_data_id'] ?? 0,
      colStep: json['colStep'] ?? 0,
      colKg: json['colKg'] ?? 0,
      colRep: json['colRep'] ?? 0,
    );
  }
}

class ExerciseRowsData {
  final int exercise_id;
  final String exercise_name;
  final String notes;
   final List<ExerciseRow> data;

  ExerciseRowsData({
    required this.exercise_id,
    required this.exercise_name,
    required this.notes,
     required this.data,
  });

   Map<String, dynamic> toJson() {
    return {
      'exercise_id': exercise_id,
      'exercise_name': exercise_name,
      'notes': notes,
      'data': data.map((row) => row.toJson()).toList(),
    };
  }

   factory ExerciseRowsData.fromJson(Map<String, dynamic> json) {
    return ExerciseRowsData(
      exercise_id: json['exercise_id'] ?? 0,
      exercise_name: json['exercise_name'] ?? "Unknown Exercise",
      notes: json['notes'] ?? "",
       data: (json['data'] as List<dynamic>)
          .map((row) => ExerciseRow.fromJson(row as Map<String, dynamic>))
          .toList(),
    );
  }
}