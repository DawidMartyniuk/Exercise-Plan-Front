import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/CurrentWorkout.dart';
import 'package:work_plan_front/model/exercise_plan.dart';

final currentWorkoutPlanProvider = StateProvider<Currentworkout?>((ref) => null);