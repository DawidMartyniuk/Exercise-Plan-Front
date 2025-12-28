import 'package:work_plan_front/model/weight_type.dart';
import 'package:hive/hive.dart';

part 'training_session.g.dart';

@HiveType(typeId: 5)
class TrainingSession {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final int? exerciseTableId;
  @HiveField(2)
  final String? exercise_table_name;
  @HiveField(3)
  final DateTime startedAt;
  @HiveField(4)
  final int duration;
  @HiveField(5)
  final bool completed;
  @HiveField(6)
  final double totalWeight;
  @HiveField(7)
  final WeightType weightType;
  @HiveField(8)
  final String? description;
  @HiveField(9)
  final String? imageBase64;
  @HiveField(10)
  final List<CompletedExercise> exercises;

  TrainingSession({
   this.id,
    required this.exerciseTableId,
    required this.exercise_table_name,
    required this.startedAt,
    required this.duration,
    required this.completed,
    required this.totalWeight,
    this.weightType = WeightType.kg,
    required this.description,
    required this.imageBase64,
    required this.exercises,
  });

 factory TrainingSession.fromJson(Map<String, dynamic> json) {
  try {
    return TrainingSession(
      id: json['id'] as int?,
      exerciseTableId: json['exercise_table_id'] as int?,
      exercise_table_name: json['exercise_table_name'] as String?,
      startedAt: DateTime.parse(json['started_at'] ?? DateTime.now().toIso8601String()),
      duration: (json['duration'] as int?) ?? 0,
      completed: (json['completed'] == 1) || (json['completed'] == true),
      totalWeight: ((json['total_weight'] as num?) ?? 0).toDouble(),
      description: json['description'] as String?,
      imageBase64: json['image_base64'] as String?,
      exercises: (json['exercises'] as List<dynamic>? ?? [])
          .map((e) => CompletedExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  } catch (e) {
    print("❌ Błąd parsowania TrainingSession: $e");
    print("📄 JSON: $json");
    rethrow;
  }
}

  Map<String, dynamic> toJson() {
    final json = {
      'exercise_table_id': exerciseTableId,
      'exercise_table_name': exercise_table_name, // ✅ null → optional
      'started_at': startedAt.toIso8601String(),
      'duration': duration,
      'completed': completed ? 1 : 0, // ✅ bool → int
      'total_weight': totalWeight,
      'weight_type': weightType.toDbString(), // ✅ enum → string
      'description': description,
      'image_base64': imageBase64,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
    
    if (id != null) {
      json['id'] = id!;
    }
    
    return json;
  }

    String getFormattedTotalWeight() {
    return weightType.formatWeight(totalWeight);
  }

  double getTotalWeightInUnit(WeightType targetUnit) {
    return weightType.convertTo(totalWeight, targetUnit);
  }
}
@HiveType(typeId: 6)
class CompletedExercise {
  @HiveField(0)
  final String exerciseId;
  @HiveField(1)
  final String notes;
  @HiveField(2)
  final List<CompletedSet> sets;

  CompletedExercise({
    required this.exerciseId,
    required this.notes,
    required this.sets,
  });

  factory CompletedExercise.fromJson(Map<String, dynamic> json) {
    return CompletedExercise(
      exerciseId: json['exercise_id'],
      notes: json['notes'] ?? '', // ✅ null → empty string
      sets: (json['sets'] as List)
          .map((set) => CompletedSet.fromJson(set))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'exercise_id': exerciseId,
    'notes': notes,
    'sets': sets.map((s) => s.toJson()).toList(),
  };
}
@HiveType(typeId: 7)
class CompletedSet {
  @HiveField(0)
  final int colStep;
  @HiveField(1)
  final int actualKg;
  @HiveField(2)
  final int actualReps;
  @HiveField(3)
  final bool completed;
  @HiveField(4)
  final bool toFailure;
  @HiveField(5)                                                       
  final WeightType weightType;

  CompletedSet({
    required this.colStep,
    required this.actualKg,
    required this.actualReps,
    required this.completed,
    required this.toFailure,
    this.weightType = WeightType.kg,
  });


  factory CompletedSet.fromJson(Map<String, dynamic> json) {
    return CompletedSet(
      colStep: json['colStep'],
      actualKg: json['actual_kg'],
      actualReps: json['actual_reps'],
      weightType: json['weight_type'] != null 
          ? WeightType.fromString(json['weight_type']) 
          : WeightType.kg,
      completed: json['completed'] == 1, // ✅ int → bool
      toFailure: json['to_failure'] == 1, // ✅ int → bool
    );
  }

  Map<String, dynamic> toJson() => {
    'colStep': colStep,
    'actual_kg': actualKg,
    'actual_reps': actualReps,
    'weight_type': weightType.toDbString(),
    'completed': completed ? 1 : 0, // ✅ bool → int
    'to_failure': toFailure ? 1 : 0, // ✅ bool → int
  };

   String getFormattedWeight() {
    return weightType.formatWeight(actualKg.toDouble(), decimals: 0);
  }

  double getWeightInUnit(WeightType targetUnit) {
    return weightType.convertTo(actualKg.toDouble(), targetUnit);
  }
}