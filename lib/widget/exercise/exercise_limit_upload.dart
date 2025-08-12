import 'package:flutter/material.dart';
import 'package:work_plan_front/theme/app_constants.dart';

class ExerciseLimitUpload extends StatefulWidget {
  final int exerciseLimit;
  final int exerciseStart;
  const ExerciseLimitUpload({
    super.key,
    required this.exerciseLimit,
    required this.exerciseStart,
  });

  @override
  State<ExerciseLimitUpload> createState() => _ExerciseLimitUploadState();
}

class _ExerciseLimitUploadState extends State<ExerciseLimitUpload> {
  late int selectedExerciseLimit;
  late int selectedExerciseStart;

  @override
  void initState() {
    super.initState();
    selectedExerciseLimit = widget.exerciseLimit;
    selectedExerciseStart = widget.exerciseStart;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Selected exercises upLoad",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16), 
              ),
              child: Text(
                'Start: $selectedExerciseStart - Limit: $selectedExerciseLimit',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ✅ KOLUMNA START
                Column(
                  children: [
                    Text(
                      "Start",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 80,
                      height: 120,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 40,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedExerciseStart = index; // ✅ BEZPOŚREDNI INDEX
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            // ✅ POKAŻ LICZBY OD 0 DO 999
                            if (index < 0 || index >= 1000) return null;
                            return Center(
                              child: Text(
                                index.toString(), // ✅ BEZPOŚREDNIA WARTOŚĆ
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: index == selectedExerciseStart 
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: index == selectedExerciseStart 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                        controller: FixedExtentScrollController(
                          initialItem: selectedExerciseStart, // ✅ BEZPOŚREDNIA WARTOŚĆ
                        ),
                      ),
                    ),
                  ],
                ),

                // ✅ KOLUMNA LIMIT
                Column(
                  children: [
                    Text(
                      "Limit",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 80,
                      height: 120,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 40,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            // ✅ LIMIT ZACZYNA OD 50 (lub więcej niż start)
                            selectedExerciseLimit = index + 50;
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            // ✅ POKAŻ LICZBY OD 50 DO 1050
                            if (index < 0 || index >= 1000) return null;
                            final value = index + 50; // ✅ WARTOŚĆ OD 50
                            return Center(
                              child: Text(
                                value.toString(),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: value == selectedExerciseLimit 
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: value == selectedExerciseLimit 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                        controller: FixedExtentScrollController(
                          initialItem: selectedExerciseLimit - 50, // ✅ POZYCJA STARTOWA
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ✅ PRZYCISK ZATWIERDZENIA
            ElevatedButton(
              onPressed: () { 
                if (selectedExerciseLimit <= selectedExerciseStart) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Limit must be greater than start value'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                AppConstants().updateExerciseRange(
                  start: selectedExerciseStart,
                  limit: selectedExerciseLimit,
                );

                // ✅ ZWRÓĆ WYBRANE WARTOŚCI
                Navigator.pop(context, {
                  'start': selectedExerciseStart,
                  'limit': selectedExerciseLimit,
                  'update': true,
                });
              },
              
                child: Text(
                  'Zatwierdź',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              
            ),
          ],
        ),
      ),
    );
  }
}
