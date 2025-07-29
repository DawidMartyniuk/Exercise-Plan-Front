import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/TrainingSesions.dart';
import 'package:work_plan_front/model/User.dart';
import 'package:work_plan_front/provider/ExercisePlanNotifier.dart';
import 'package:work_plan_front/provider/TrainingSerssionNotifer.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard.dart';

class RecentWorkoutsSection extends ConsumerStatefulWidget {
  const RecentWorkoutsSection({super.key});

  @override
  _RecentWorkoutsSectionState createState() => _RecentWorkoutsSectionState();
}

class _RecentWorkoutsSectionState extends ConsumerState<RecentWorkoutsSection> {

  @override
  void initState() {
    super.initState();
    // Pobierz sesje przy starcie
    Future.microtask(() async {
      await ref.read(completedTrainingSessionProvider.notifier).fetchSessions();
      await ref.read(exercisePlanProvider.notifier).fetchExercisePlans();
    
    });
  }

  @override
  Widget build(BuildContext context) {
    final trainingSessions = ref.watch(completedTrainingSessionProvider);

     print("🔍 RecentWorkoutsSection build() wywołane");
  print("🔍 trainingSessions.length: ${trainingSessions.length}");
  print("🔍 trainingSessions.isEmpty: ${trainingSessions.isEmpty}");
  print("🔍 trainingSessions: $trainingSessions");

    if (trainingSessions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(5.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.fitness_center, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Brak ukończonych treningów',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
     
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: trainingSessions.length > 5 ? 5 : trainingSessions.length, // Maksymalnie 5 ostatnich
          itemBuilder: (context, index) {
            final session = trainingSessions[index];
            return WorkoutCard(trainingSession: session);
          },
        ),
      ],
    );
  }
}

