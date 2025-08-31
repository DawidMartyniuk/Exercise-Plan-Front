import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/TrainingSesions.dart';
import 'package:work_plan_front/provider/ExercisePlanNotifier.dart';
import 'package:work_plan_front/provider/authProvider.dart';
import 'package:work_plan_front/provider/exerciseProvider.dart';

mixin WorkoutCardHelpers {
  // ✅ FORMATOWANIE
  String formatDuration(int durationMinutes) {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) return "${hours}h ${minutes}m";
    return "${minutes}m";
  }

  String getDaysAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    if (difference == 0) return "Today";
    if (difference == 1) return "Yesterday";
    return "$difference days ago";
  }


  int getTotalSets(TrainingSession session) {
    return session.exercises
        .map((ex) => ex.sets.length)
        .fold(0, (sum, sets) => sum + sets);
  }

  int getTotalReps(TrainingSession session) {
    return session.exercises
        .map((ex) => ex.sets
            .map((set) => set.actualReps)
            .fold(0, (sum, reps) => sum + reps))
        .fold(0, (sum, reps) => sum + reps);
  }
  int getTotalExercises(TrainingSession session) {
    return session.exercises.length;
  }

  // ✅ POBIERANIE DANYCH
  String getUserName(WidgetRef ref) {
    try {
      final authResponse = ref.watch(authProviderLogin);
      return authResponse?.user?.name ?? 'User';
    } catch (e) {
      print("❌ Error getting user name: $e");
      return 'User';
    }
  }

  String? getWorkoutTitle(TrainingSession session, WidgetRef ref) {
    try {
      final exercisePlans = ref.watch(exercisePlanProvider);
      
      // ✅ SPRAWDŹ CZY session.exerciseTableId NIE JEST NULL
      if (session.exerciseTableId == null) {
        return session.exercise_table_name?.isNotEmpty == true 
            ? session.exercise_table_name 
            : "Workout #${session.id ?? 'Unknown'}";
      }
      
      if (exercisePlans.isEmpty) {
        return session.exercise_table_name?.isNotEmpty == true 
            ? session.exercise_table_name 
            : "Workout #${session.id ?? 'Unknown'}";
      }

      try {
        final matchingPlan = exercisePlans.firstWhere(
          (plan) => plan.id == session.exerciseTableId,
        );
        return matchingPlan.exercise_table;
      } catch (e) {
        return session.exercise_table_name?.isNotEmpty == true 
            ? session.exercise_table_name 
            : "Workout #${session.id ?? 'Unknown'}";
      }
    } catch (e) {
      print("❌ Error getting workout title: $e");
      return "Workout #${session.id ?? 'Unknown'}";
    }
  }

  String? getExerciseName(String exerciseId, WidgetRef ref) {
    final exerciseState = ref.watch(exerciseProvider);
    return exerciseState.when(
      data: (allExercise) {
        try {
          final exercise = allExercise.firstWhere((ex) => ex.exerciseId == exerciseId);
          return exercise.name;
        } catch (e) {
          return "Unknown Exercise";
        }
      },
      error: (_, __) => null,
      loading: () => "Loading...",
    );
  }

  String? getExerciseImage(String exerciseId, WidgetRef ref) {
    final exerciseData = ref.watch(exerciseProvider);
    return exerciseData.when(
      data: (allExercise) {
        try {
          final exercise = allExercise.firstWhere((ex) => ex.exerciseId == exerciseId);
          return exercise.gifUrl ?? '';
        } catch (e) {
          return '';
        }
      },
      error: (_, __) => '',
      loading: () => '',
    );
  }

  String getProfileImage(WidgetRef ref) {
    final authResponse = ref.watch(authProviderLogin);
    return authResponse?.user.avatar ?? '';
  }

  // int getTotalSets(TrainingSession trainingSession) {
  //   return trainingSession.exercises
  //       .map((ex) => ex.sets.length)
  //       .fold(0, (sum, sets) => sum + sets);
  // }

  // int getTotalReps(TrainingSession trainingSession) {
  //   return trainingSession.exercises
  //       .map(
  //         (ex) => ex.sets
  //             .map((set) => set.actualReps)
  //             .fold(0, (sum, reps) => sum + reps),
  //       )
  //       .fold(0, (sum, reps) => sum + reps);
  // }
  
}