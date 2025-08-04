import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/provider/ExercisePlanNotifier.dart';
import 'package:work_plan_front/screens/exercises.dart';
import 'package:work_plan_front/screens/tabs.dart';
import 'package:work_plan_front/widget/plan/plan_creation_list.dart';
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
  String exerciseTableTitle = ""; 

  void addExercise() async {}

  void _saveTabelData() async {
    if (_getTableData != null) {
      final tableData = _getTableData!();

      final allRows = tableData.entries
          .expand((entry) => entry.value)
          .where((row) => row["exercise_name"] != null && row["exercise_name"]!.trim().isNotEmpty)
          .toList();

      final grouped = groupBy<Map<String, String>, String>(
        allRows,
        (row) => "${row["exercise_name"]}|||${row["notes"]}",
      );

      final groupedList = grouped.entries.map((entry) {
        final keyParts = entry.key.split("|||");
        final firstRow = entry.value.first;
        print("Raw exercise_number: ${firstRow["exercise_number"]}");

        return {
          "exercise_name": keyParts[0],
          
         "exercise_number": firstRow["exercise_number"],
          "notes": keyParts[1],
          "data": entry.value.map((row) {
            return {
              "colStep": int.tryParse(row["colStep"] ?? "0") ?? 0,
              "colKg": int.tryParse(row["colKg"] ?? "0") ?? 0,
              "colRep": int.tryParse(row["colRep"] ?? "0") ?? 0,
            };
          }).toList(),
        };
      }).toList();

      // Poprawna konstrukcja payloadu
      final payload = {
        "exercises": [
          {
            "exercise_table": exerciseTableTitle.isNotEmpty ? exerciseTableTitle : "Default Title",
            "rows": groupedList,
          },
        ],
      };

      print("Payload wysyłany do backendu: $payload");

      final exercisePlanNotifier = ref.read(exercisePlanProvider.notifier);
      await exercisePlanNotifier.initializeExercisePlan(payload);
    

      try {
        final statusCode = await exercisePlanNotifier.saveExercisePlan(onlyThis: exercisePlanNotifier.state.last);
        if (statusCode == 200 || statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Plan zapisany pomyślnie!"),
                backgroundColor: Colors.green,
              ),
            );
             await ref.read(exercisePlanProvider.notifier).fetchExercisePlans();
             
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TabsScreen(selectedPageIndex: 2),
              ),
            );
          }
        } else {
          print("Nie udało się zapisać planu ćwiczeń: Status $statusCode");
          errorScaffoldMessage("Nie udało się zapisać planu ćwiczeń. Spróbuj ponownie.", Colors.red);
        }
      } catch (e) {
        errorScaffoldMessage("Nie udało się zapisać planu ćwiczeń. Spróbuj ponownie", Colors.red);
        print("Nie udało się zapisać planu ćwiczeń: $e");
      }
    } else {
      errorScaffoldMessage("Brak dostępnych dancyh tabeli", Colors.red);
    }
  }
  void errorScaffoldMessage(String message, Color color) {
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
  void _backScreen() {
  if (selectedExercise.isNotEmpty || exerciseTableTitle.isNotEmpty || selectedExercise.isEmpty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface, 
        title: Text(
          "Czy na pewno chcesz wrócić?",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          "Nie zapisano zmian.",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Anuluj",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              "Tak",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  } else {
    Navigator.of(context).pop();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _backScreen();
          
          },
        ),
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
                });
              },
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                labelText: "Plan Title",
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                border: OutlineInputBorder(),
              ),
            ),      
            const SizedBox(height: 20),
            Expanded(
              child: selectedExercise.isEmpty
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
                      MaterialPageRoute(
                        builder: (ctx) => ExercisesScreen(
                          isSelectionMode: true, // ✅ DODAJ TO!
                          title: 'Select Exercise for Plan', // ✅ DODAJ TO!
                        ),
                      ),
                    );
                    if (newExercise != null) {
                      print('Adding exercise: ${newExercise.name}');
                      setState(() {
                        selectedExercise.add(newExercise);
                      });
                    }
                  },
                  child: Text("Add Exercise", style:
                   Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface),
                    ),
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
