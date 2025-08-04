import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/provider/ExercisePlanNotifier.dart';
import 'package:work_plan_front/provider/TrainingSerssionNotifer.dart';
import 'package:work_plan_front/provider/exerciseProvider.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard.dart';

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
        await ref.read(exercisePlanProvider.notifier).fetchExercisePlans();
        await ref.read(exerciseProvider.notifier).fetchExercises();
        
        // ✅ DODAJ EXPLICITE WYWOŁANIE fetchSessions
        await ref.read(completedTrainingSessionProvider.notifier).fetchSessions(forceRefresh: true);
        
      } catch (e) {
        print("❌ Błąd ładowania danych w recent_workout_section.dart: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("🔍 RecentWorkoutsSection: Wywołuję ref.watch()...");
  
    // ✅ ZWYKŁA LISTA - bez .when()
    final trainingSessions = ref.watch(completedTrainingSessionProvider);

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
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Start your first workout to see it here',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ HEADER
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Workouts',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
             
            ],
          ),
        ),
        
        // ✅ LISTA SESJI
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: trainingSessions.length > 5 ? 5 : trainingSessions.length,
          itemBuilder: (context, index) {
            final session = trainingSessions[index];
            return WorkoutCard(trainingSession: session);
          },
        ),
      ],
    );
  }
}

