import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/TrainingSesions.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard/components/workout_header.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard/components/workout_stats.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard/workout_card_helpers.dart';
//import 'package:work_plan_front/screens/home_dashboard/workoutCard/components/workout_info_summary.dart';
//import 'package:work_plan_front/screens/home_dashboard/workoutCard/components/exercise_list_view.dart';
import 'package:work_plan_front/screens/home_dashboard/workout_info/exercise_list_view.dart';
import 'package:work_plan_front/screens/home_dashboard/workout_info/workout_info_summary.dart';

class WorkoutCardInfo extends ConsumerWidget with WorkoutCardHelpers {
  final TrainingSession trainingSession;

  const WorkoutCardInfo({
    Key? key,
    required this.trainingSession,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Details'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ HEADER - UŻYJ ISTNIEJĄCY KOMPONENT
              WorkoutHeader(
                userName: getUserName(ref),
                date: trainingSession.startedAt,
                showMoreIcon: true,
              ),
              
              SizedBox(height: 8.0),
              
              // ✅ TYTUŁ TRENINGU
              Row(
                children: [
                  Expanded(
                    child: Text(
                      getWorkoutTitle(trainingSession, ref) ?? "Workout Session",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 8.0),
              
              SizedBox(height: 8.0),
              Divider(color: Theme.of(context).dividerColor),
              
              // ✅ WORKOUT SUMMARY - NOWY KOMPONENT
              WorkoutInfoSummary(trainingSession: trainingSession),
              
              SizedBox(height: 30),
              
              // ✅ LISTA ĆWICZEŃ - NOWY KOMPONENT
              ExerciseListView(trainingSession: trainingSession),
              
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}