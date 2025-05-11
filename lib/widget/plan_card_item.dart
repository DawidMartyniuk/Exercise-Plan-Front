import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/exercise.dart';

class PlanCardItem extends StatelessWidget {
   final ExerciseTable plan;
 final List<Exercise> exercises;
  final VoidCallback? onStartWorkout;

  const PlanCardItem({
    super.key,
    required this.plan,
    required this.exercises,
    this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                plan.exercise_table,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: plan.rows.length, // plan to obiekt ExerciseTable
                itemBuilder: (context, index) {
                  final exerciseData = plan.rows[index]; // ExerciseRowsData
                  final matchingExercise = exercises.firstWhere(
                    (ex) {
                      final match = int.tryParse(ex.id) == int.tryParse(exerciseData.exercise_number);
                      print('Porównuję ex.id=${ex.id} z exerciseData.exercise_number=${exerciseData.exercise_number} → $match');
                      return match;
                    },
                    orElse: () => Exercise(
                      id: '',
                      name: 'Nieznane ćwiczenie',
                      bodyPart: '',
                      equipment: '',
                      gifUrl: '',
                      target: '',
                      secondaryMuscles: [],
                      instructions: [],
                    ),
                  );
                    // Szukaj ćwiczenia po nazwie


                    // final exercise = allExercises.firstWhere(
                    //   (ex) => ex.name.toLowerCase() == exerciseRow.exercise_name.toLowerCase(),
                    //   orElse: () => Exercise(
                    //     id: '',
                    //     name: exerciseRow.exercise_name,
                    //     bodyPart: '',
                    //     equipment: '',
                    //     gifUrl: '',
                    //     target: '',
                    //     secondaryMuscles: [],
                    //     instructions: [],
                    //   ),
                    // );
                    print("strona z URL gifem ${exerciseData.exercise_name}: ${matchingExercise.gifUrl}");
                    return Card(
                      color: Theme.of(context).colorScheme.surface.withAlpha((0.9 * 255).toInt()),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          
                          children: [
                            Row(
                              children: [
                                //Jeśli masz gifUrl w modelu, możesz dodać obrazek tutaj                               
                              ClipOval(                                
                                child: matchingExercise.gifUrl.isNotEmpty                                
                                    ? Image.network(
                                        matchingExercise.gifUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey[300],
                                        alignment: Alignment.center,
                                        child: const Text(
                                          "brak",
                                          style: TextStyle(fontSize: 12, color: Colors.black54),
                                        ),
                                      ),
                              ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    exerciseData.exercise_name,
                                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (exerciseData.notes.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  "Notes: ${exerciseData.notes}",
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                ),
                              ),
                            Table(
                              border: TableBorder.symmetric(
                                inside: BorderSide.none,
                                outside: BorderSide.none,
                              ),
                              columnWidths: const {
                                0: FlexColumnWidth(1),
                                1: FlexColumnWidth(1),
                                2: FlexColumnWidth(1),
                                3: FlexColumnWidth(1),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    Container(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Step",
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Container(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "KG",
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Container(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Reps",
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
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
                                ...exerciseData.data.asMap().entries.map((entry) {
                                  final row = entry.value;
                                  final rowId = entry.key + 1;
                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "$rowId",
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "${row.colKg}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "${row.colRep}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: 
                                          IconButton(
                                            onPressed: () {}, 
                                            icon: Icon(Icons.check_box)
                                            ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onStartWorkout,
                child: const Text("Zwin plan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}