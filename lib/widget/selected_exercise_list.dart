import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';

class SelectedExerciseList extends StatefulWidget {
  final List<Exercise> exercises;
  final void Function(Exercise exercise) onDelete;

  const SelectedExerciseList({
    Key? key,
    required this.exercises,
    required this.onDelete,
    required this.onGetTableData,
  }) : super(key: key);

  final void Function(Map<String, List<Map<String, String>>> Function()) onGetTableData;

  @override
  _SelectedExerciseListState createState() => _SelectedExerciseListState();
}

class _SelectedExerciseListState extends State<SelectedExerciseList> {
  Map<String, Map<String, dynamic>> exerciseRows = {};

  void _addRow(String exerciseId, String exerciseName) {
  setState(() {
    if (!exerciseRows.containsKey(exerciseId)) {
       print("Initializing exerciseRows for $exerciseId");
      exerciseRows[exerciseId] = {
        "exerciseName": exerciseName,
        "notes": "",
        "rows": [
          {"colStep": "1", "colKg": "0", "colRep": "0"} 
        ]
      };
    }
    final rows = exerciseRows[exerciseId]!["rows"] as List<Map<String, String>>;
    final currentRowCount = rows.length;
    final currentReps = rows.isNotEmpty ? rows[currentRowCount - 1]["colRep"] ?? "0" : "0";
    final currentKg = rows.isNotEmpty ? rows[currentRowCount - 1]["colKg"] ?? "0" : "0";
    rows.add({
      "colStep": "${currentRowCount + 1}",
      "colKg": currentKg,
      "colRep": currentReps,
    });
  });
}

 void _removeRow(String exerciseId, int index) {
    setState(() {
      if (exerciseRows.containsKey(exerciseId)) {
        final rows = exerciseRows[exerciseId]!["rows"] as List<Map<String, String>>;
        if (rows.length > 1) {
          rows.removeAt(index);
        }
      }
    });
  }
 List<Map<String, String>> _getTableData(String exerciseId) {
  return exerciseRows[exerciseId]?["rows"] ?? [];
}

Map<String, List<Map<String, String>>> getTableData() {
  return exerciseRows.map((exerciseId, data) {
     print("Processing exerciseId: $exerciseId, data: $data");
    final rows = data["rows"] as List<Map<String, String>>? ?? [];
    final exerciseName = data["exerciseName"] as String? ?? "Unknown Exercise";
    final notes = data["notes"] as String? ?? "";

   
    final rowsWithTitleAndNotes = [
      {"exerciseName": exerciseName}, // Tytuł ćwiczenia
      {"notes": notes},               // Notatki
      ...rows,                        
    ];

    return MapEntry(exerciseId, rowsWithTitleAndNotes);
  });
}

  @override
  void initState() {
    super.initState();
    widget.onGetTableData(getTableData);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.exercises.length,
      itemBuilder: (context, index) {
        final exercise = widget.exercises[index];
        final exerciseId = exercise.id;

         if (!exerciseRows.containsKey(exerciseId)) {
        exerciseRows[exerciseId] = {
          "exerciseName": exercise.name,
          "rows": [
            {"colStep": "1", "colKg": "0", "colRep": "0"}
          ]
        };
      }
       final exerciseName = exerciseRows[exerciseId]!["exerciseName"] as String;
      final rows = _getTableData(exerciseId);

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
                      exerciseName,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        exerciseRows.remove(exerciseId);
                        widget.onDelete(exercise);
                      });
                    },
                  ),
                ],
              ),
                const SizedBox(height: 10),
                TextField(
                    onChanged: (value) {
                      setState(() {
                        exerciseRows[exerciseId]!["notes"] = value; // Aktualizuj notatki
                      });
                    },
                  decoration: InputDecoration(
                    label: const Text("Notes"),
                    border: const UnderlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
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
                      children: [
                        Container(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1), // Kolor tła
                          padding: const EdgeInsets.all(8.0),
                         child: TextButton(
                            onPressed: () {
                              // Funkcja zmiany wartości dla "KG" (do dodania w przyszłości)
                            },
                            child: Text(
                              "Step",
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                          ),
                        ),
                        Container(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1), // Kolor tła
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            onPressed: () {
                              // Funkcja zmiany wartości dla "KG" (do dodania w przyszłości)
                            },
                            child: Text(
                              "KG",
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                          ),
                        ),
                        Container(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1), 
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            onPressed: () {
                           
                            },
                            child: Text(
                              "Reps",
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                   
                   ..._getTableData(exerciseId).asMap().entries.map((entry) {
                        final row = entry.value;
                        final rowId = entry.key + 1;
                        final rows = exerciseRows[exerciseId]!["rows"] as List<Map<String, String>>;
                        final currentRowCount = rows.length;
                        final currentReps = rows.isNotEmpty ? rows[currentRowCount - 1]["colRep"] ?? "0" : "0";
                        final currentKg = rows.isNotEmpty ? rows[currentRowCount - 1]["colKg"] ?? "0" : "0";
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
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  row["colKg"] = value;
                                });
                              },
                              decoration:  InputDecoration(
                                //hintText: " $currentKg",
                                hintText: row["colKg"] ?? "0",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                              ),
                              textAlign: TextAlign.center,
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
                                  row["colRep"] = value;
                                });
                              },
                              decoration:  InputDecoration(
                              //hintText: " $currentReps",
                              hintText: row["colRep"] ?? "0",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                              ),
                              textAlign: TextAlign.center,
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
                        onPressed: () => _addRow(exerciseId, exercise.name),
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
