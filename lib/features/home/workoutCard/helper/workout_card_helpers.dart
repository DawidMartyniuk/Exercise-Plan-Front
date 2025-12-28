import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/training_session.dart';
import 'package:work_plan_front/provider/exercise_plan_notifier.dart';
import 'package:work_plan_front/provider/auth_provider.dart';
import 'package:work_plan_front/provider/exercise_provider.dart';

mixin WorkoutCardHelpers {
  
  // ✅ FORMATOWANIE DURATION (ZOSTAJE TUTAJ)
  String formatDuration(int durationInSeconds) {
    final hours = durationInSeconds ~/ 3600;
    final minutes = (durationInSeconds % 3600) ~/ 60;
    final seconds = durationInSeconds % 60;
    
    if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else if (minutes > 0) {
      return "${minutes}m ${seconds}s";
    } else {
      return "${seconds}s";
    }
  }

  // ✅ OBLICZENIA STATYSTYK
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

  // ✅ POBIERANIE DANYCH Z PROVIDERÓW
  String getUserName(WidgetRef ref) {
    try {
      final authResponse = ref.watch(authProviderLogin);
      return authResponse?.user.name ?? 'User';
    } catch (e) {
      print("❌ Error getting user name: $e");
      return 'User';
    }
  }

  String? getWorkoutTitle(TrainingSession session, WidgetRef ref) {
    try {
      final exercisePlans = ref.watch(exercisePlanProvider);
      
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
}