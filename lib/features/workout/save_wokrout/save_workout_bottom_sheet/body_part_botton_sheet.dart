import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/provider/current_workout_plan_provider.dart';
import 'package:work_plan_front/shared/utils/exercise_untils.dart';

class BodyPartInfoBottomSheet extends ConsumerWidget {
  final String title;
  final String info;

  const BodyPartInfoBottomSheet({
    super.key,
    required this.title,
    required this.info,
  });



  @override
  Widget build(BuildContext context,WidgetRef ref) {

     final currentWorkout = ref.watch(currentWorkoutPlanProvider);
    final performedExercises = getPerformedExercises(currentWorkout);
  
  Map<BodyPart, double> bodyPartsInfo(String info) {
  final Map<BodyPart, double> bodyPartsInfo = {};

  for (final ex in performedExercises) {
    final bodyPart = BodyPart.values.firstWhereOrNull(
      (part) => part.displayNameBodyPart() == ex.bodyPart,
    );
    if (bodyPart != null) {
      double value = 0;
      if (info == 'weight') {
        value = ex.sets.fold(0, (sum, set) => sum + (set.kg ?? 0));
      } else if (info == 'reps') {
        value = ex.sets.fold(0, (sum, set) => sum + ((set.colRepMin + set.colRepMax) ~/ 2));
      }
      bodyPartsInfo[bodyPart] = (bodyPartsInfo[bodyPart] ?? 0) + value;
    }
  }
  return bodyPartsInfo;
};

    

    return SingleChildScrollView(
      child: Container(
        height: 400,
        child: Column(
          children: [
             Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
               info == 'weight' ? 'Partie ciała i suma ciężarów' : 'Partie ciała i suma powtórzeń',
               
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: BodyPart.values.length,
                itemBuilder: (context, index) {
                  final infoMap = bodyPartsInfo(info); // info = 'weight' lub 'reps'
                  final bodyPart = BodyPart.values[index];
                  //if ((exercisesCount[bodyPart] ?? 0) == 0) {
                  
                      if ((infoMap[bodyPart] ?? 0) == 0) {
                    return const SizedBox.shrink();
                  }
                  var card = Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                    leading: Image.asset(
                      '/bodyParts/${bodyPart.name}.png',
                      width: 40,
                      height: 40,
                    ),
                    title: Text(
                      bodyPart.displayNameBodyPart(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Text(
                        '${infoMap[bodyPart] ?? 0}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.info_outline),
                      ],
                    ),
                    ),
                  );
                  return card;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}