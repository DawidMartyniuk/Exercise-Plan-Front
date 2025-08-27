
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/reps_type.dart';

final defaultRepsTypeProvider = StateProvider<RepsType>((ref) => RepsType.single);

final exerciseRepsTypeProvider = StateProvider.family<RepsType, String>((ref, exerciseId) {
  final defaultType = ref.read(defaultRepsTypeProvider);
  return defaultType;
});

final repsTypeForExerciseProvider = Provider.family<RepsType, String>((ref, exerciseId) {
  return ref.watch(exerciseRepsTypeProvider(exerciseId));
});