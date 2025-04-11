import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/widget/body_part_grid_item.dart';

class ExercisesScreen extends ConsumerStatefulWidget{
  const ExercisesScreen({super.key});



  ///final List<Exercise> exercise;

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

  
class _ExercisesScreenState extends ConsumerState<ExercisesScreen>{

  void _onBodyPartSelected(BuildContext context, BodyPart bodyPart) {
    print('Selected body part: ${bodyPart.name}');

    // Możesz tutaj np. nawigować do innego ekranu
    // Navigator.of(context).push(...);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 kolumny
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3 / 2,
          ),
          children: [
            for (final bodyPart in BodyPart.values)
              BodyPartGridItem(
                bodyPart: bodyPart,
                onTap: () => _onBodyPartSelected(context, bodyPart),
              )
          ],
        ),
      ),
    );
  }
}