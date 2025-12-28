
import 'package:hive/hive.dart';
import 'package:work_plan_front/model/exercise_plan.dart';

class ExercisePlanLocalService {
  static const String _boxName = 'plansBox';

  Future<void> savePlans(List<ExerciseTable> plans) async {
    final box = await Hive.openBox<ExerciseTable>(_boxName);
    await box.clear();
    for (final plan in plans) {
      await box.put(plan.id, plan);
    }
  }

  Future<List<ExerciseTable>> getPlans() async {
    final box = await Hive.openBox<ExerciseTable>(_boxName);
    return box.values.toList();
  }

  Future<void> deletePlan(int planId) async {
    final box = await Hive.openBox<ExerciseTable>(_boxName);
    await box.delete(planId);
  }
}