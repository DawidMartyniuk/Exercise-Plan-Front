import 'package:flutter/material.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class ProgressBar extends StatelessWidget {
 // final double progress;
  final int totalSteps;
  final int currentStep;
  final bool isReadOnly;

  const ProgressBar({
    super.key, 
    required this.totalSteps,
    required this.currentStep,
    this.isReadOnly = false, 
  });

  @override
  Widget build(BuildContext context) {
  if (isReadOnly) return Container();
  
  // ✅ POPRAWNE LICZENIE ZAZNACZONYCH CHECKBOX'ÓW
  int checkedSteps = 0;
  int totalExerciseSteps = 0;
  
  return Column(
      children: [
        //  STEP PROGRESS INDICATOR
        StepProgressIndicator(
          totalSteps: totalSteps > 0 ? totalSteps : 1,
          currentStep: currentStep,
          size: 8,
          padding: 0,
          selectedColor: Theme.of(context).colorScheme.primary,
          unselectedColor: Theme.of(context).colorScheme.outline.withAlpha(40), // bardziej wyrazisty
          roundedEdges: Radius.circular(4),
          gradientColor: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
              Colors.deepPurpleAccent, // dodany wyrazisty kolor
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // ✅ TEKST Z POSTĘPEM
        // Text(
        //   '$currentStep / $totalSteps completed',
        //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
        //     color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        //   ),
        // ),
      ],
    );
  }
}