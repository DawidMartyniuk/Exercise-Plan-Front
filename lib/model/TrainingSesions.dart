import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise_plan.dart';

class TrainingSession {
  final int exerciseTableId;
  final DateTime startedAt;
  final int duration;
  final bool completed;
  final double totalWeight;
  final String description;
  final String imageBase64;
  final List<CompletedExercise> exercises;

  TrainingSession({
    required this.exerciseTableId,
    required this.startedAt,
    required this.duration,
    required this.completed,
    required this.totalWeight,
    required this.description,
    required this.imageBase64,
    required this.exercises,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      exerciseTableId: json['exercise_table_id'],
      startedAt: DateTime.parse(json['started_at']),
      duration: json['duration'],
      completed: json['completed'],
      totalWeight: (json['total_weight'] as num).toDouble(),
      description: json['description'],
      imageBase64: json['image_base64'],
      exercises: (json['exercises'] as List)
          .map((ex) => CompletedExercise.fromJson(ex))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'exercise_table_id': exerciseTableId,
    'started_at': startedAt.toIso8601String(),
    'duration': duration,
    'completed': completed,
    'total_weight': totalWeight,
    'description': description,
    'image_base64': imageBase64,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

}

class CompletedExercise {
  final String exerciseId;
  final String notes;
  final List<CompletedSet> sets;

  CompletedExercise({
    required this.exerciseId,
    required this.notes,
    required this.sets,
  });

  factory CompletedExercise.fromJson(Map<String, dynamic> json) {
    return CompletedExercise(
      exerciseId: json['exercise_id'],
      notes: json['notes'],
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
class CompletedSet {
  final int colStep;
  final int actualKg;
  final int actualReps;
  final bool completed;
  final bool toFailure;

  CompletedSet({
    required this.colStep,
    required this.actualKg,
    required this.actualReps,
    required this.completed,
    required this.toFailure,
  });

  factory CompletedSet.fromJson(Map<String, dynamic> json) {
    return CompletedSet(
      colStep: json['colStep'],
      actualKg: json['actual_kg'],
      actualReps: json['actual_reps'],
      completed: json['completed'],
      toFailure: json['to_failure'],
    );
  }

  Map<String, dynamic> toJson() => {
    'colStep': colStep,
    'actual_kg': actualKg,
    'actual_reps': actualReps,
    'completed': completed,
    'to_failure': toFailure,
  };
}