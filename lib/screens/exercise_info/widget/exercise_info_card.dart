import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/screens/exercise_info/widget/info_row.dart';

class ExerciseInfoCard extends StatelessWidget {
  const ExerciseInfoCard({super.key, required this.exercise});
  
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            InfoRowWidget(
              label: 'Body Parts:',
              value: exercise.bodyParts.isNotEmpty 
                  ? exercise.bodyParts.join(', ') 
                  : 'Not specified',
              icon: Icons.accessibility_new,
              iconColor: Colors.blue,
            ),
            _buildDivider(context),
            InfoRowWidget(
              label: 'Equipment:',
              value: exercise.equipments.isNotEmpty 
                  ? exercise.equipments.join(', ') 
                  : 'Body weight',
              icon: Icons.fitness_center,
              iconColor: Colors.green,
            ),
            _buildDivider(context),
            InfoRowWidget(
              label: 'Target Muscles:',
              value: exercise.targetMuscles.isNotEmpty 
                  ? exercise.targetMuscles.join(', ') 
                  : 'Not specified',
              icon: Icons.my_location,
              iconColor: Colors.red,
            ),
            if (exercise.secondaryMuscles.isNotEmpty) ...[
              _buildDivider(context),
              InfoRowWidget(
                label: 'Secondary Muscles:',
                value: exercise.secondaryMuscles.join(', '),
                icon: Icons.radio_button_unchecked,
                iconColor: Colors.orange,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Divider(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        thickness: 1,
      ),
    );
  }
}