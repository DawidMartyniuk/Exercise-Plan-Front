import 'package:flutter/material.dart';

class ExerciseHeader extends StatelessWidget {
  final Widget headerCellTextStep;
  final Widget headerCellTextKg;
  final Widget headerCellTextReps;

  const ExerciseHeader({
    Key? key,
    required this.headerCellTextStep,
    required this.headerCellTextKg,
    required this.headerCellTextReps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      children: [
        TableRow(
          children: [
            headerCellTextStep,
            headerCellTextKg,
            headerCellTextReps,
            Container(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Widget headerCellText(BuildContext context, String text) {
  return Container(
    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
    padding: const EdgeInsets.all(8.0),
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    ),
  );
}