import "package:flutter/material.dart";

class SaveWorkoutStatsRow extends StatelessWidget {
  final int hoursSelected;
  final int minutesSelected;
  final int weightSelected;
  final int allReps;
  final VoidCallback showTimePickerSheet;
  final VoidCallback showBodyPartExercisePickerSheet;
  final VoidCallback showWeightInfoSheet;
  final VoidCallback showBodyPartRepsPickerSheet;
  final VoidCallback showRepsInfoSheet;

  const SaveWorkoutStatsRow({
    super.key,
    required this.hoursSelected,
    required this.minutesSelected,
    required this.weightSelected,
    required this.allReps,
    required this.showTimePickerSheet,
    required this.showBodyPartExercisePickerSheet,
    required this.showWeightInfoSheet,
    required this.showBodyPartRepsPickerSheet,
    required this.showRepsInfoSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.timer_sharp,
                  size: 50,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () {},
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: showTimePickerSheet,
                child: Text(
                  ' $hoursSelected h $minutesSelected min',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Kolumna 2: ciężar
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: showBodyPartExercisePickerSheet,
                child: Icon(
                  Icons.fitness_center,
                  size: 50,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: showWeightInfoSheet,
                child: Text(
                  '$weightSelected kg',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Kolumna 3: powtórzenia
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            //_showBodyPartRepsPickerSheet
            children: [
              GestureDetector(
                onTap: showBodyPartRepsPickerSheet,
                child: Icon(
                  Icons.repeat,
                  size: 50,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: showRepsInfoSheet,
                child: Text(
                  '$allReps ',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
