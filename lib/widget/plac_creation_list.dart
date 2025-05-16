import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/screens/exercise_info.dart';

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
 final Map<String, TextEditingController> _notesControllers = {};


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
 void _openInfoExercise(Exercise exercise) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => (ExerciseInfoScreen(exercise: exercise)),
    );
  }
 List<Map<String, String>> _getTableData(String exerciseId) {
  return exerciseRows[exerciseId]?["rows"] ?? [];
}

Map<String, List<Map<String, String>>> getTableData() {
  return exerciseRows.map((exerciseId, data) {
    final rawRows = data["rows"] as List<dynamic>? ?? [];
    final exerciseName = data["exerciseName"]?.toString() ?? "Unknown Exercise";
    final execiseNumber = exerciseId;
    final notes = data["notes"]?.toString() ?? "";
    final rows = rawRows.map((row) {
      final rowMap = Map<String, dynamic>.from(row);
      return {
        "exercise_name": exerciseName,
        "exercise_number": execiseNumber, 
        "notes": notes,
        "colStep": rowMap["colStep"]?.toString() ?? "0",
        "colKg": rowMap["colKg"]?.toString() ?? "0",
        "colRep": rowMap["colRep"]?.toString() ?? "0",
      };
    }).toList();
    return MapEntry(exerciseId, rows);
  });
}
_deleteExerciseForPlan(String exerciseId) {
  var exerciseForDelete =  widget.exercises.firstWhere((exerciseId) => exerciseId.id == exerciseId);
   setState(() {
      exerciseRows.remove(exerciseId);
     widget.onDelete(exerciseForDelete);
     _notesControllers.remove(exerciseId)?.dispose();
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
      _notesControllers.putIfAbsent(
    exerciseId,
    () => TextEditingController(text: exerciseRows[exerciseId]!["notes"] ?? ""),
    );

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
                  GestureDetector(
                    onTap: () {
                      _openInfoExercise(exercise);
                    },
                    child: ClipOval(
                      child: Image.network(
                        exercise.gifUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
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
                      _deleteExerciseForPlan(exerciseId);
                    },
                  ),
                ],
              ),
                const SizedBox(height: 10),
                TextField(
                  controller: _notesControllers[exerciseId],   
                    onChanged: (value) {
                      setState(() {
                        exerciseRows[exerciseId]!["notes"] = value; 
                      });
                    },
                  decoration: InputDecoration(
                    label: Text("Notes"),
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
                              keyboardType: TextInputType.number,
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
                              keyboardType: TextInputType.number,
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
                          _notesControllers.remove(exerciseId)?.dispose();
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
