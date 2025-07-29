import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/main.dart';
import 'package:work_plan_front/model/CurrentWorkout.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/provider/ExercisePlanNotifier.dart';
import 'package:work_plan_front/provider/current_workout_plan_provider.dart';
import 'package:work_plan_front/provider/wordoutTimeNotifer.dart';
import 'package:work_plan_front/screens/exercise_info.dart';
import 'package:expandable/expandable.dart';
import 'package:work_plan_front/provider/workout_plan_state_provider.dart';
import 'package:work_plan_front/screens/save_workout.dart';
import 'package:work_plan_front/utils/imge_untils.dart';
import 'package:work_plan_front/utils/workout_utils.dart';// ✅ DODAJ IMPORT
import 'package:work_plan_front/widget/plan/plan_list/plan_selected/plan_selected_appBar.dart';
import 'package:work_plan_front/widget/plan/plan_list/plan_selected/plan_selected_card.dart';
import 'package:work_plan_front/widget/plan/plan_list/plan_selected/plan_selected_details.dart';
import 'package:work_plan_front/widget/plan/widget/Info_bottom.dart';

class PlanSelectedList extends ConsumerStatefulWidget {
  final ExerciseTable plan;
  final List<Exercise> exercises;
  final VoidCallback? onStartWorkout;

  const PlanSelectedList({
    super.key,
    required this.plan,
    required this.exercises,
    this.onStartWorkout,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _PlanSelectedListState();
  }
}

class _PlanSelectedListState extends ConsumerState<PlanSelectedList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController? _scrollController;
  Map<int, bool> _expandedCards = {};
  bool _workoutStarted = false;
  Timer? _timer;
  int totalSteps = 0;

  final Map<String, TextEditingController> _kgControllers = {};
 final Map<String, TextEditingController> _repControllers = {};

  void _openInfoExercise(Exercise exercise) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => (ExerciseInfoScreen(exercise: exercise)),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    final planId = widget.plan.id;
    final savedRows = ref.read(workoutPlanStateProvider).getRows(planId);
    debugPrint('Odczytano z providera: $savedRows');
   


    if (savedRows.isNotEmpty) {
      for (final rowData in widget.plan.rows) {
        for (final row in rowData.data) {
          final match = savedRows.firstWhere(
            (e) =>
                e.colStep == row.colStep &&
                e.exerciseNumber == rowData.exercise_number,
            orElse:
                () => ExerciseRowState(
                  colStep: row.colStep,
                  colKg: row.colKg,
                  colRep: row.colRep,
                  isChecked: row.isChecked,
                  isFailure:row.isFailure,
                  exerciseNumber: rowData.exercise_number,
                ),
          );
          // print('initState: match dla row $row: $match');
          row.colKg = match.colKg;
          row.colRep = match.colRep;
          row.isChecked = match.isChecked;
          row.isFailure = match.isFailure;
          row.rowColor = row.isChecked ? Colors.green : Colors.transparent;
        }
      }
    } 
  }

  void _toogleRowChecked(ExerciseRow row, String exerciseNumber) {
    setState(() {
      row.isChecked = !row.isChecked;
      row.rowColor = row.isChecked ? const Color.fromARGB(255, 103, 189, 106) : Colors.transparent;
   //print('TOGGLE: $row');
    });
    ref
        .read(workoutPlanStateProvider.notifier)
        .updateRow(
          widget.plan.id,
          ExerciseRowState(
            colStep: row.colStep,
            colKg: row.colKg,
            colRep: row.colRep,
            isChecked: row.isChecked,
            isFailure: row.isFailure,
            exerciseNumber: exerciseNumber,
          ),
        );
    // Stwórz głęboką kopię planu z nowymi danymi
final newRows = widget.plan.rows
    .map((rowData) => rowData.copyWithData(
          rowData.data
              .map((row) => ExerciseRow(
                    colStep: row.colStep,
                    colKg: row.colKg,
                    colRep: row.colRep,
                    isChecked: row.isChecked,
                    isFailure: row.isFailure,
                    rowColor: row.rowColor,
                  ))
              .toList(),
        ))
    .toList();

final newPlan = widget.plan.copyWithRows(newRows);

ref.read(currentWorkoutPlanProvider.notifier).state = Currentworkout(
  plan: newPlan,
  exercises: widget.exercises,
);
    //print('Zmieniono checkbox: $row, isChecked: ${row.isChecked}');
    debugPrint('Zmieniono checkbox: $row');
    debugPrint('Zmieniono checkbox: $row, exerciseNumber: $exerciseNumber');
  }

  // void _endWorkout(BuildContext context) {
  //   endWorkoutGlobal(
  //   context: context,ref: ref
  //   );
   
  // }

  // Dodaj obsługę zmiany wartości kg/reps
  void _onKgChanged(ExerciseRow row, String value, String exerciseNumber) {
    setState(() {
      row.colKg = int.tryParse(value) ?? row.colKg;
    });
    ref
        .read(workoutPlanStateProvider.notifier)
        .updateRow(
          widget.plan.id,
          ExerciseRowState(
            colStep: row.colStep,
            colKg: row.colKg,
            colRep: row.colRep,
            isChecked: row.isChecked,
            isFailure: row.isFailure,
            exerciseNumber: exerciseNumber,
          ),
        );
  }

  void _onRepChanged(ExerciseRow row, String value, String exerciseNumber) {
    setState(() {
      row.colRep = int.tryParse(value) ?? row.colRep;
    });
    ref
        .read(workoutPlanStateProvider.notifier)
        .updateRow(
          widget.plan.id,
          ExerciseRowState(
            colStep: row.colStep,
            colKg: row.colKg,
            colRep: row.colRep,
            isChecked: row.isChecked,
            isFailure: row.isFailure,
            exerciseNumber: exerciseNumber,
          ),
        );
  }

  void _saveAllRowsToProvider() {
    final planId = widget.plan.id;
    final rowStates = <ExerciseRowState>[];
    for (final rowData in widget.plan.rows) {
      for (final row in rowData.data) {
        rowStates.add(
          ExerciseRowState(
            colStep: row.colStep,
            colKg: row.colKg,
            colRep: row.colRep,
            isChecked: row.isChecked,
            isFailure: row.isFailure,
            exerciseNumber: rowData.exercise_number, // <-- poprawka!
          ),
        );
      }
    }
    ref.read(workoutPlanStateProvider.notifier).setPlanRows(planId, rowStates);
    debugPrint('Zapisano stan checkboxów do providera: $rowStates');
    //Navigator.of(context).pop();
  }

   void _endWorkout(BuildContext context) {
    final currentWorkout = ref.read(currentWorkoutPlanProvider);
    if (currentWorkout?.plan != null) {
      // Resetuj plan w providerze z listą planów
      ref.read(exercisePlanProvider.notifier).resetPlanById(currentWorkout!.plan!.id);

      // Resetuj plan w currentWorkout (lokalnie)
      resetPlanRows(currentWorkout.plan!);
       for (final controller in _kgControllers.values) {
      controller.clear();
      }
      for (final controller in _repControllers.values) {
        controller.clear();
      }

    }
    endWorkoutGlobal(context: context, ref: ref);
     Navigator.of(context).pop();
  }

 
  
  int getAllReps() {
  return widget.plan.rows.fold(
    0,
    (sum, rowData) => sum + rowData.data
    .where((row) => row.isChecked)
    .fold( 0, (innerSum, row) => innerSum + row.colRep,
    ),
  );
}

 double getAllWeight() {
  return widget.plan.rows.fold(
    0,
    (sum, rowData) => sum + rowData.data
    .where((row) => row.isChecked)
    .fold(0,(innerSum, row) => innerSum + row.colKg * row.colRep,
    ),
  );
}
  void _savePlan() {
    final exerciseNames = widget.exercises.map((e) => e.name).toList();
    final timerController = ref.read(workoutProvider.notifier);


   final startHour  = timerController.startHour ?? 0; 
   final startMinute = timerController.startMinute ?? 0;

    Navigator.of(
      context,
    ).push(MaterialPageRoute(
      builder: (ctx) => SaveWorkout(
        allTime: ref.read(workoutProvider.notifier).currentTime,
        allReps:getAllReps(),
        allWeight: getAllWeight(),
        startHour: startHour,
        startMinute: startMinute,
        planName: widget.plan.exercise_table,
        onEndWorkout: () => _endWorkout(context),
    )));
  }

  String getTime(BuildContext context) {
    final timerController = ref.watch(workoutProvider.notifier);
    final time = timerController.currentTime;
    final duration = Duration(seconds: time);

    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final minutes = duration.inMinutes % 60;
    final hours = duration.inHours;

    String formattedMinutes =
        minutes < 10 ? '$minutes' : minutes.toString().padLeft(2, '0');
    String formattedTime;

    if (hours == 0 && minutes == 0) {
      formattedTime = "$seconds";
    } else if (hours == 0) {
      formattedTime = "$formattedMinutes:$seconds";
    } else {
      formattedTime = "$hours:$formattedMinutes:$seconds";
    }
    return formattedTime;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalSteps = widget.plan.rows.fold(
      0,
      (sum, rowData) => sum + rowData.data.length,
    );

    int getCurrentStep() {
      // Liczba zaznaczonych checkboxów (isChecked == true) w AKTUALNYCH WIERSZACH PLANU
      return widget.plan.rows
          .expand((rowData) => rowData.data)
          .where((row) => row.isChecked)
          .length;
      
    }

    final groupedData = <String, List<ExerciseRowsData>>{};
    for (final row in widget.plan.rows) {
      groupedData.putIfAbsent(row.exercise_name, () => []).add(row);
    }

    Widget headerCellText(BuildContext context, String text) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) {
              if (text == "Step") {
                return InfoBottomSheet(textInfo: "Here you have the set or step number for this exercise.");
              } else if (text == "Weight") {
                return InfoBottomSheet(textInfo: "Enter the weight you plan to use for this set.");
              } else if (text == "Reps") {
                return InfoBottomSheet(textInfo: "Type the number of repetitions for this set.");
              }
              return SizedBox.shrink();
            },
          );
        },
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

    Widget cellText(
      BuildContext context,
      String text,
      String subject, {
      bool bold = false,
      required ExerciseRow row,
      required String exerciseNumber,
    }) {
      final key = subject == "weight" 
      ? '${exerciseNumber}_${row.colStep}_kg'
      : '${exerciseNumber}_${row.colStep}_rep';
      final controller = subject == "weight" 
      ? _kgControllers[key]
      : _repControllers[key];


      if(row.isChecked) {
        if(controller != null && controller.text.isEmpty){
          controller.text = text; // Ustaw tekst tylko jeśli pole jest puste
        }
      } else {
        if(controller !=null && controller.text.isNotEmpty) {
          controller.clear(); // Wyczyść pole, jeśli checkbox nie jest zaznaczony
        }
      } 


     // print('cellText: $text, subject: $subject, row: $row, exerciseNumber: $exerciseNumber');
      return Padding(
        
        padding: const EdgeInsets.all(8.0),
        child:
            subject == "step"
                ? GestureDetector(
                  onTap:  () {
                      setState(() {
                        showModalBottomSheet(
                          context: context,
                          builder: (ctx) => InfoBottomSheet(textInfo: "Step or set number"),
                        );
                      });
                    },
                  child: TextField(
                      controller: TextEditingController(text: text),
                      readOnly: true,
                      enabled: false,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                )
                :TextField(
                    controller: row.isChecked == false
                        ? null
                        : subject == "weight"
                            ? _kgControllers['${exerciseNumber}_${row.colStep}_kg']
                            : _repControllers['${exerciseNumber}_${row.colStep}_rep'],
                    onChanged: (value) {
                      if (subject == "weight") {
                        _onKgChanged(row, value, exerciseNumber);
                      } else if (subject == "reps") {
                        _onRepChanged(row, value, exerciseNumber);
                      }
                    },
                    textAlign: TextAlign.center,
                    decoration: InputDecoration( 
                      hintText: text,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );

    }

    List<TableRow> buildExerciseTableRows(List<ExerciseRowsData> exerciseRows) {
      final List<TableRow> rows = [];
      for (final exerciseRowsData in exerciseRows) {
        for (int idx = 0; idx < exerciseRowsData.data.length; idx++) {
          final row = exerciseRowsData.data[idx];
          final rowId = idx + 1;

          final kgKey = '${exerciseRowsData.exercise_number}_${row.colStep}_kg';
          final repKey = '${exerciseRowsData.exercise_number}_${row.colStep}_rep';

          _kgControllers[kgKey]?.text = row.colKg.toString();
          _repControllers[repKey]?.text = row.colRep.toString();
          rows.add(
            TableRow(
              decoration: BoxDecoration(color: row.rowColor),
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
               
                    });
                  },
                  child: cellText(
                    context,
                    "$rowId",
                    "step",
                    row: row,
                    exerciseNumber: exerciseRowsData.exercise_number,
                  ),
                ),
                cellText(
                  context,
                  "${row.colKg}",
                  "weight",
                  row: row,
                  exerciseNumber: exerciseRowsData.exercise_number,
                ),
                cellText(
                  context,
                  "${row.colRep}",
                  "reps",
                  row: row,
                  exerciseNumber: exerciseRowsData.exercise_number,
                ),
                GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      if (row.isChecked) {
                        if (row.isFailure && row.rowColor == const Color.fromARGB(255, 12, 107, 15)) {
                          row.rowColor = const Color.fromARGB(255, 103, 189, 106);
                          row.isFailure = false;
                        } else {
                          row.rowColor = const Color.fromARGB(255, 12, 107, 15);
                          row.isFailure = true;
                        }
                        
                        ref.read(workoutPlanStateProvider.notifier).updateRow(
                          widget.plan.id,
                          ExerciseRowState(
                            colStep: row.colStep,
                            colKg: row.colKg,
                            colRep: row.colRep,
                            isChecked: row.isChecked,
                            isFailure: row.isFailure,
                            exerciseNumber: exerciseRowsData.exercise_number,
                          ),
                        );
                        final planId = widget.plan.id;
                        final savedRows = ref.read(workoutPlanStateProvider).getRows(planId);
                       // print('Po DOUBLE TAP, stan w providerze: $savedRows');
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      onPressed: () => _toogleRowChecked(row, exerciseRowsData.exercise_number),
                      icon: Icon(
                        row.isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      }
      return rows;
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const Drawer(
          child: PlanSelectedDetails(),
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            ExpandableNotifier(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      PlanSelectedAppBar(
                        onBack: () {
                          _saveAllRowsToProvider();
                          Navigator.pop(context);
                        },
                        planName: widget.plan.exercise_table,
                        getTime: getTime,
                        getCurrentStep: getCurrentStep,
                       // endWorkout: () => _endWorkout(context),
                        onSavePlan: () => _savePlan(),
                      ),
                      SizedBox(height: 10),
                      LinearProgressIndicator(
                        minHeight: 8,
                        value: getCurrentStep() / totalSteps,
                        color: Colors.red,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          children: [
                            ...groupedData.entries.map((entry) {
                              final exerciseName = entry.key;
                              final exerciseRows = entry.value;
                              final firstRow = exerciseRows.first;
            
                              final matchingExercise = widget.exercises
                                  .firstWhere(
                                    (ex) =>
                                        int.tryParse(ex.id) ==
                                        int.tryParse(firstRow.exercise_number),
                                    orElse:
                                        () => Exercise(
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
            
                              return PlanSelectedCard(
                                infoExercise:
                                    () => _openInfoExercise(matchingExercise),
                                // ✅ UŻYJ NetworkImage bezpośrednio
                                exerciseGif: ImageUtils.createImageProvider(matchingExercise.gifUrl),
                                exerciseName: exerciseName,
                                headerCellTextStep: headerCellText(
                                  context,
                                  "Step",
                                ),
                                headerCellTextKg: headerCellText(
                                  context,
                                   "Weight",
                                   ),
                                headerCellTextReps: headerCellText(
                                  context,
                                  "Reps",
                                ),
                                notes: firstRow.notes,
                                exerciseRows: buildExerciseTableRows(
                                  exerciseRows,
                                ),
                              );
                            }),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Dodaj akcję dodawania ćwiczenia
                              },
                              icon: Icon(Icons.add),
                              label: Text("Add Exercise"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _endWorkout(context),
                              child: Text("End Workout"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
             Positioned(
          left: 0,
          top: MediaQuery.of(context).size.height / 2 - 24,
          child: GestureDetector(
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            child: Container(
              width: 32,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
              ),
              child: const Icon(Icons.arrow_forward_ios),
            ),
          ),
        ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:work_plan_front/model/exercise_plan.dart';
// import 'package:work_plan_front/utils/image_utils.dart'; // ✅ DODAJ IMPORT

class PlanSelectedCard extends StatelessWidget {
  final VoidCallback? infoExercise;
  final ImageProvider? exerciseGif; // ✅ ZMIANA: ImageProvider? zamiast NetworkImage
  final String exerciseName;
  final Widget headerCellTextStep;
  final Widget headerCellTextKg;
  final Widget headerCellTextReps;
  final List<TableRow> exerciseRows;
  final String notes;

  const PlanSelectedCard({
    super.key,
    required this.infoExercise,
    this.exerciseGif, // ✅ ZMIANA: Opcjonalny ImageProvider
    required this.exerciseName,
    required this.headerCellTextStep,
    required this.headerCellTextKg,
    required this.headerCellTextReps,
    required this.notes,
    required this.exerciseRows,
  });

  @override
  Widget build(BuildContext context) {
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
                GestureDetector(
                  onTap: () {
                    infoExercise?.call();
                  },
                  child: ClipOval(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
                      ),
                      child: exerciseGif != null
                          ? Image(
                              image: exerciseGif!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholder(context);
                              },
                            )
                          : _buildPlaceholder(context),
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
              ],
            ),
            const SizedBox(height: 16),
            if (notes.isNotEmpty) ...[
              Text(
                'Notes: $notes',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Table(
              border: TableBorder.all(
                color: Theme.of(context).colorScheme.outline.withAlpha(50),
                width: 1,
              ),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(20),
                  ),
                  children: [
                    headerCellTextStep,
                    headerCellTextKg,
                    headerCellTextReps,
                    Container(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Done',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                ...exerciseRows,
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ DODAJ: Placeholder widget
  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
      ),
      child: Icon(
        Icons.fitness_center,
        color: Theme.of(context).colorScheme.primary,
        size: 24,
      ),
    );
  }
}
