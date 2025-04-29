import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/provider/ExercisePlanNotifier.dart';
import 'package:work_plan_front/screens/exercises.dart';
import 'package:work_plan_front/serwis/saveExercisePlan.dart';
import 'package:work_plan_front/utils/tokenStorage.dart';
import 'package:work_plan_front/widget/selected_exercise_list.dart';

class PlanCreation  extends ConsumerStatefulWidget{
  const PlanCreation({super.key});


  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
      return _StatePlanCreation();
  }
}
class _StatePlanCreation extends ConsumerState<PlanCreation>{

 List<Exercise> selectedExercise = [];
  Map<String, List<Map<String, String>>> Function()? _getTableData;
  
  var exerciseLenght = 0;
  late final Widget _exerciseList;
  String exerciseTableTitle = ""; // Zmienna do przechowywania tytułu planu


  void addExercise() async{

  }
void _saveTabelData() async {
  if (_getTableData != null) {
    final tableData = _getTableData!();

    // Przekształć dane na format oczekiwany przez backend
    final exercises = tableData.entries.map((entry) {
      final exerciseId = entry.key;
      final rows = entry.value;

      return {
        "exercise_table": exerciseTableTitle.isNotEmpty ? exerciseTableTitle : "Default Title", // Tytuł planu
       "rows": rows
          .where((row) => int.tryParse(row["colStep"] ?? "0") != 0)
          .map((row) => {
            "exercise_name": row["exercise_name"] ?? "Unknown Exercise",
            "notes": row["notes"] ?? "",
            "colStep": int.tryParse(row["colStep"] ?? "0") ?? 0,
            "colKg": int.tryParse(row["colKg"] ?? "0") ?? 0,
            "colRep": int.tryParse(row["colRep"] ?? "0") ?? 0,
          })
          .toList(),
      };
    }).toList();

    print("Dane wysyłane do backendu: $exercises"); // Debugowanie

    // Pobierz ExercisePlanNotifier
    final exercisePlanNotifier = ref.read(exercisePlanProvider.notifier);

    // Zainicjalizuj plan ćwiczeń
    await exercisePlanNotifier.initializeExercisePlan({
      "exercises": exercises,
    });

    // Zapisz plan ćwiczeń
    await exercisePlanNotifier.saveExercisePlan();
  } else {
    print("No table data available.");
  }
}

@override
Widget build(BuildContext context) {
  

  return Scaffold(
    appBar: AppBar(
      title: Text("log workout"),
      actions: [
        IconButton(
          onPressed: _saveTabelData,
          icon: const Icon(Icons.save),
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 24.0,
      ),
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
            child: selectedExercise.isEmpty
                ? Center(
                    child: Text(
                      "No exercises added yet.",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  )
                : SelectedExerciseList(
                    onGetTableData: (getterFunction) {
                      _getTableData = () {
                        final tableData = getterFunction();
                        // Dodaj exercise_table do każdego ćwiczenia
                        return tableData.map((exerciseId, rows) {
                          return MapEntry(exerciseId, [
                            {"exercise_table": exerciseTableTitle}, // Dodaj tytuł planu
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
                  final newExercise = await Navigator.of(context).push<Exercise>(
                    MaterialPageRoute(
                      builder: (ctx) => ExercisesScreen(),
                    ),
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
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withAlpha((0.2 * 255).toInt()),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );
}
}