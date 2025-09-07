import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/screens/exercise_info/widget/exercise_image.dart';
import 'package:work_plan_front/screens/exercise_info/widget/instruction_list_widget.dart';

class InstructionsTab extends StatelessWidget {
  const InstructionsTab({super.key, required this.exercise});
  
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ MNIEJSZY OBRAZEK ĆWICZENIA
          ExerciseImageWidget(
            imageUrl: exercise.gifUrl ?? '',
            height: 200,
            isLarge: true,
          ),

          const SizedBox(height: 24),

          // ✅ LISTA INSTRUKCJI
          InstructionListWidget(instructions: exercise.instructions),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}