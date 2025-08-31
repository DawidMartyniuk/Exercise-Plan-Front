import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/provider/exerciseProvider.dart';

mixin PlanHelpers {

  // ✅ FORMATOWANIE
  String formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0) return "${hours}h ${remainingMinutes}m";
    return "${remainingMinutes}m";
  }

  String formatWeight(double weight) {
    return "${weight.toInt()}kg";
  }

  // ✅ POBIERANIE DANYCH ĆWICZEŃ
  String getExerciseName(String exerciseId, WidgetRef ref) {
    final exerciseState = ref.watch(exerciseProvider);
    
    return exerciseState.when(
      data: (exercises) {
        try {
          final exercise = exercises.firstWhere((ex) => ex.exerciseId == exerciseId);
          return exercise.name;
        } catch (e) {
          return "Unknown Exercise";
        }
      },
      error: (error, stackTrace) => "Error Loading",
      loading: () => "Loading...",
    );
  }

  String? getExerciseImageUrl(String exerciseId, WidgetRef ref) {
    final exerciseState = ref.watch(exerciseProvider);
    
    return exerciseState.when(
      data: (exercises) {
        try {
          final exercise = exercises.firstWhere((ex) => ex.exerciseId == exerciseId);
          return exercise.gifUrl?.isNotEmpty == true ? exercise.gifUrl : null;
        } catch (e) {
          return null;
        }
      },
      error: (error, stackTrace) => null,
      loading: () => null,
    );
  }
  

  // ✅ OBLICZENIA PLANU
  int getTotalSets(ExerciseTable plan) {
    return plan.rows.fold(0, (sum, rowData) => sum + rowData.data.length);
  }

  int getCompletedSets(ExerciseTable plan) {
    return plan.rows.fold(0, (sum, rowData) {
      return sum + rowData.data.where((row) => row.isChecked).length;
    });
  }

  double getProgressPercentage(ExerciseTable plan) {
    final total = getTotalSets(plan);
    final completed = getCompletedSets(plan);
    if (total == 0) return 0.0;
    return (completed / total) * 100;
  }

  // ✅ WALIDACJA
  bool isPlanValid(ExerciseTable plan) {
    return plan.rows.isNotEmpty && plan.rows.every((rowData) => rowData.data.isNotEmpty);
  }

  String? validateExerciseRow(String step, String kg, String reps) {
    if (step.isEmpty || kg.isEmpty || reps.isEmpty) {
      return "All fields must be filled";
    }
    
    final stepValue = int.tryParse(step);
    final kgValue = double.tryParse(kg);
    final repsValue = int.tryParse(reps);
    
    if (stepValue == null || stepValue <= 0) {
      return "Step must be a positive number";
    }
    if (kgValue == null || kgValue < 0) {
      return "Weight must be a non-negative number";
    }
    if (repsValue == null || repsValue <= 0) {
      return "Reps must be a positive number";
    }
    
    return null;
  }
}