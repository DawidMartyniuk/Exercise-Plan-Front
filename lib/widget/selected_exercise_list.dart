import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';

class SelectedExerciseList extends StatefulWidget {
  final List<Exercise> exercises;
  final void Function(Exercise exercise) onDelete;

  const SelectedExerciseList({
    Key? key,
    required this.exercises,
    required this.onDelete,
  }) : super(key: key);

  @override
  _SelectedExerciseListState createState() => _SelectedExerciseListState();
}

class _SelectedExerciseListState extends State<SelectedExerciseList> {

  Map<String, List<Map<String, String>>> exerciseRows = {};


  void _addRow(String exerciseId) {
    setState(() {
      if (!exerciseRows.containsKey(exerciseId)) {
        // Jeśli tabela dla ćwiczenia nie istnieje, inicjalizuj ją z jednym wierszem
        exerciseRows[exerciseId] = [
          {"column1": "Step", "column2": "KG", "column3": "Reps"},
          {"column1": "", "column2": "", "column3": ""}
        ];
      }
      // Dodaj nowy wiersz
      exerciseRows[exerciseId]!.add({"column1": "", "column2": "", "column3": ""});
    });
  }

  // Usuń wiersz z tabeli dla konkretnego ćwiczenia
  void _removeRow(String exerciseId, int index) {
    setState(() {
      if (exerciseRows.containsKey(exerciseId) && exerciseRows[exerciseId]!.length > 1) {
        exerciseRows[exerciseId]!.removeAt(index);
      }
    });
  }

  // Pobierz dane tabeli dla konkretnego ćwiczenia
  List<Map<String, String>> _getTableData(String exerciseId) {
    return exerciseRows[exerciseId] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.exercises.length,
      itemBuilder: (context, index) {
        final exercise = widget.exercises[index];
        final exerciseId = exercise.id;

        if (!exerciseRows.containsKey(exerciseId)) {
              exerciseRows[exerciseId] = [
                {"column1": "Step", "column2": "KG", "column3": "Reps"}, // Wiersz tytułowy
                {"column1": "", "column2": "", "column3": ""} // Pusty wiersz do edycji
              ];
            }

        return Card(
          color: Theme.of(context).colorScheme.surface.withAlpha((0.9 * 255).toInt()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: Image.network(
                        exercise.gifUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        widget.onDelete(exercise);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    label: const Text("Notes"),
                    border: const UnderlineInputBorder(),
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Table(
                    border: TableBorder.symmetric(
                    inside: BorderSide.none,
                    outside: BorderSide.none,
                    ),
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                          "Column 1 Step",
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                          "Column 2 KG",
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                          "Column 3 Reps",
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    ..._getTableData(exercise.id).map((row) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  row["column1"] = value;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: "Enter value",
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  row["column2"] = value;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: "Enter value",
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  row["column3"] = value;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: "Enter value",
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => _addRow(exerciseId),
                        child: Text(
                          "Add Row",
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                       ElevatedButton(
                        onPressed: () {
                          if (_getTableData(exerciseId).length > 1) {
                            _removeRow(exerciseId, _getTableData(exerciseId).length - 1);
                          }
                        },
                        child: Text(
                          "Delete Row",
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}