import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/provider/exercise_plan_notifier.dart';
import 'package:work_plan_front/provider/training_serssion_notifer.dart';
import 'package:work_plan_front/provider/exercise_provider.dart';
import 'package:work_plan_front/features/home/workoutCard/workout_card_compact.dart';

class RecentWorkoutsSection extends ConsumerStatefulWidget {
  const RecentWorkoutsSection({super.key});

  @override
  ConsumerState<RecentWorkoutsSection> createState() => _RecentWorkoutsSectionState();
}

class _RecentWorkoutsSectionState extends ConsumerState<RecentWorkoutsSection> {

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() async {
      try {
        // Sprawdź czy dane już są załadowane zanim wywołasz fetch
        final exercisePlans = ref.read(exercisePlanProvider);
        if (exercisePlans.isEmpty) {
          await ref.read(exercisePlanProvider.notifier).fetchExercisePlans();
        }

        final exercises = ref.read(exerciseProvider);

        final trainingSessions = ref.read(trainingSessionAsyncProvider).maybeWhen(
          data: (sessions) => sessions,
          orElse: () => null,
        );
        if (trainingSessions == null || trainingSessions.isEmpty) {
          await ref.read(trainingSessionAsyncProvider.notifier).fetchSessions(forceRefresh: true);
        }
      } catch (e) {
        print("❌ Błąd ładowania danych w recent_workout_section.dart: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("🔍 RecentWorkoutsSection: Wywołuję ref.watch()...");
  
    //  UŻYJ ASYNCVALUE DO OBSŁUGI STANÓW ŁADOWANIA
    final trainingSessionsAsync = ref.watch(trainingSessionAsyncProvider);
    
    return trainingSessionsAsync.when(
      //  KÓŁKO ŁADOWANIA
      loading: () => Container(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Loading workouts...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // ✅ BŁĄD ŁADOWANIA
      error: (error, stackTrace) => Container(
        padding: EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error loading workouts',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    ref.read(trainingSessionAsyncProvider.notifier).fetchSessions(forceRefresh: true);
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      
      // ✅ DANE ZAŁADOWANE
      data: (trainingSessions) {
        print("🔍 RecentWorkoutsSection build() wywołane");
        print("🔍 trainingSessions.length: ${trainingSessions.length}");

        if (trainingSessions.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.fitness_center, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No completed workouts yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Start your first workout to see it here!',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final sortedSessions = List.of(trainingSessions)
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

        // ✅ POKAŻ KARTY TRENINGÓW
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top:8),
                child: Text(
                  'Recent Workouts',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: sortedSessions.length > 20 ? 20 : sortedSessions.length, //  MAKSYMALNIE 5 KART
                separatorBuilder: (context, index) => SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final session = sortedSessions[index];
                  return WorkoutCard(
                    trainingSession: session,
                    showAsFullScreen: false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

