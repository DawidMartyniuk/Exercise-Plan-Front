import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/provider/ExercisePlanNotifier.dart';
import 'package:work_plan_front/screens/exercises.dart';
import 'package:work_plan_front/screens/plan.dart';
import 'package:work_plan_front/widget/selected_exercise_list.dart';
import 'package:collection/collection.dart';

class PlanCreation extends ConsumerStatefulWidget {
  const PlanCreation({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _StatePlanCreation();
  }
}

class _StatePlanCreation extends ConsumerState<PlanCreation> {
  List<Exercise> selectedExercise = [];
  Map<String, List<Map<String, String>>> Function()? _getTableData;

  var exerciseLenght = 0;
  String exerciseTableTitle = ""; // Zmienna do przechowywania tytułu planu

  void addExercise() async {}

  void _saveTabelData() async {
    if (_getTableData != null) {
      final tableData = _getTableData!();

      // Rozwiń dane i zgrupuj wg exercise_name i notes
      final allRows =
          tableData.entries
              .expand((entry) => entry.value)
              .where(
                (row) =>
                    row["exercise_name"] != null &&
                    row["exercise_name"]!.trim().isNotEmpty,
              )
              .toList();

      final grouped = groupBy<Map<String, String>, String>(
        allRows,
        (row) => "${row["exercise_name"]}|||${row["notes"]}",
      );

      final groupedList =
          grouped.entries.map((entry) {
            final keyParts = entry.key.split("|||");
            return {
              "exercise_name": keyParts[0],
              "notes": keyParts[1],
              "data":
                  entry.value
                      .map(
                        (row) => {
                          "colStep": int.tryParse(row["colStep"] ?? "0") ?? 0,
                          "colKg": int.tryParse(row["colKg"] ?? "0") ?? 0,
                          "colRep": int.tryParse(row["colRep"] ?? "0") ?? 0,
                        },
                      )
                      .toList(),
            };
          }).toList();

      final payload = [
        {
          "exercise_table":
              exerciseTableTitle.isNotEmpty
                  ? exerciseTableTitle
                  : "Default Title",
          "rows": groupedList,
        },
      ];

      print("Dane wysyłane do backendu: $payload"); // Debugowanie

      final exercisePlanNotifier = ref.read(exercisePlanProvider.notifier);
      await exercisePlanNotifier.initializeExercisePlan({"exercises": payload});

      try {
        await exercisePlanNotifier.saveExercisePlan();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Plan saved successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PlanScreen()),
          );
        }
      } catch (e) {
        print("Failed to save exercise plan: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save exercise plan. Please try again."),
          ),
        );
      }
    } else {
     print("No table data available.");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("No table data available."),
        backgroundColor: Colors.orange,
      ),
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("log workout"),
        actions: [
          IconButton(onPressed: _saveTabelData, icon: const Icon(Icons.save)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  exerciseTableTitle = value; // Aktualizuj zmienną klasy
                  print("Updated exerciseTableTitle: $exerciseTableTitle");
                });
              },
              decoration: InputDecoration(
                labelText: "Plan Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                  selectedExercise.isEmpty
                      ? Center(
                        child: Text(
                          "No exercises added yet.",
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      )
                      : SelectedExerciseList(
                        onGetTableData: (getterFunction) {
                          _getTableData = () {
                            final tableData = getterFunction();
                            final updatedTitle =
                                exerciseTableTitle; // upewniamy się, że pobieramy aktualny tytuł
                            return tableData.map((exerciseId, rows) {
                              return MapEntry(exerciseId, [
                                {"exercise_table": updatedTitle},
                                ...rows,
                              ]);
                            });
                          };
                        },

                        exercises: selectedExercise,
                        onDelete: (exercise) {
                          setState(() {
                            selectedExercise.remove(exercise);
                          });
                        },
                      ),
            ),
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () async {
                    final newExercise = await Navigator.of(
                      context,
                    ).push<Exercise>(
                      MaterialPageRoute(builder: (ctx) => ExercisesScreen()),
                    );
                    if (newExercise != null) {
                      print('Adding exercise: ${newExercise.name}');
                      setState(() {
                        selectedExercise.add(newExercise);
                      });
                    }
                  },
                  child: Text("Add Exercise"),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension GroupByExtension<E> on List<E> {
  Map<K, List<E>> groupFoldBy<K>(K Function(E) keyFn) {
    final map = <K, List<E>>{};
    for (var element in this) {
      final key = keyFn(element);
      map.putIfAbsent(key, () => []).add(element);
    }
    return map;
  }
}
