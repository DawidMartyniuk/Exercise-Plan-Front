import 'package:work_plan_front/model/exercise_plan.dart';

mixin ExerciseCalculations {
  // ✅ OBLICZENIA VOLUME
  double calculateTotalVolume(ExerciseTable plan) {
    return plan.rows.fold(0.0, (total, rowData) {
      return total + rowData.data.fold(0.0, (sum, row) {
        if (row.isChecked) {
          return sum + (row.colKg * row.colRep);
        }
        return sum;
      });
    });
  }

  double calculateExerciseVolume(ExerciseRowsData exerciseData) {
    return exerciseData.data.fold(0.0, (sum, row) {
      if (row.isChecked) {
        return sum + (row.colKg * row.colRep);
      }
      return sum;
    });
  }

  // ✅ OBLICZENIA SERII
  int calculateTotalSets(ExerciseTable plan) {
    return plan.rows.fold(0, (total, rowData) => total + rowData.data.length);
  }

  int calculateCompletedSets(ExerciseTable plan) {
    return plan.rows.fold(0, (total, rowData) {
      return total + rowData.data.where((row) => row.isChecked).length;
    });
  }

  int calculateFailedSets(ExerciseTable plan) {
    return plan.rows.fold(0, (total, rowData) {
      return total + rowData.data.where((row) => row.isFailure).length;
    });
  }

  // ✅ OBLICZENIA POWTÓRZEŃ
  int calculateTotalReps(ExerciseTable plan) {
    return plan.rows.fold(0, (total, rowData) {
      return total + rowData.data.fold(0, (sum, row) {
        if (row.isChecked) {
          return sum + row.colRep;
        }
        return sum;
      });
    });
  }

  // ✅ PROGRESS CALCULATIONS
  double calculateProgressPercentage(ExerciseTable plan) {
    final totalSets = calculateTotalSets(plan);
    final completedSets = calculateCompletedSets(plan);
    
    if (totalSets == 0) return 0.0;
    return (completedSets / totalSets) * 100;
  }

  // ✅ ŚREDNIE WARTOŚCI
  double calculateAverageWeight(ExerciseTable plan) {
    final completedRows = plan.rows
        .expand((rowData) => rowData.data)
        .where((row) => row.isChecked)
        .toList();
    
    if (completedRows.isEmpty) return 0.0;
    
    final totalWeight = completedRows.fold(0.0, (sum, row) => sum + row.colKg);
    return totalWeight / completedRows.length;
  }

  double calculateAverageReps(ExerciseTable plan) {
    final completedRows = plan.rows
        .expand((rowData) => rowData.data)
        .where((row) => row.isChecked)
        .toList();
    
    if (completedRows.isEmpty) return 0.0;
    
    final totalReps = completedRows.fold(0, (sum, row) => sum + row.colRep);
    return totalReps / completedRows.length;
  }

  // ✅ WORKOUT DURATION
  Duration calculateWorkoutDuration(DateTime? startTime) {
    if (startTime == null) return Duration.zero;
    return DateTime.now().difference(startTime);
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // ✅ PERFORMANCE METRICS
  Map<String, dynamic> calculateWorkoutSummary(ExerciseTable plan) {
    return {
      'totalVolume': calculateTotalVolume(plan),
      'totalSets': calculateTotalSets(plan),
      'completedSets': calculateCompletedSets(plan),
      'failedSets': calculateFailedSets(plan),
      'totalReps': calculateTotalReps(plan),
      'averageWeight': calculateAverageWeight(plan),
      'averageReps': calculateAverageReps(plan),
      'progressPercentage': calculateProgressPercentage(plan),
      'exerciseCount': plan.rows.length,
    };
  }
}