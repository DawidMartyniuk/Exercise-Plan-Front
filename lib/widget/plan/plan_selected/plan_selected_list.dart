import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/provider/current_workout_plan_provider.dart';
import 'package:work_plan_front/provider/wordoutTimeNotifer.dart';
import 'package:work_plan_front/screens/exercise_info.dart';
import 'package:expandable/expandable.dart';
import 'package:work_plan_front/provider/workout_plan_state_provider.dart';

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
  ScrollController? _scrollController;
  Map<int, bool> _expandedCards = {};
  bool _workoutStarted = false;
  Timer? _timer;
  int totalSteps = 0;

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
            orElse: () => ExerciseRowState(
              colStep: row.colStep,
              colKg: row.colKg,
              colRep: row.colRep,
              isChecked: row.isChecked,
              exerciseNumber: rowData.exercise_number,
            ),
          );
          row.colKg = match.colKg;
          row.colRep = match.colRep;
          row.isChecked = match.isChecked;
          row.rowColor = row.isChecked ? Colors.green : Colors.transparent;
        }
      }
    } else {
      for (final rowData in widget.plan.rows) {
        for (final row in rowData.data) {
          row.colKg = 0;
          row.colRep = 0;
          row.isChecked = false;
          row.rowColor = Colors.transparent;
        }
      }
    }
  }

  void _toogleRowChecked(ExerciseRow row, String exerciseNumber) {
    setState(() {
      row.isChecked = !row.isChecked;
      row.rowColor = row.isChecked ? Colors.green : Colors.transparent;
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
            exerciseNumber: exerciseNumber,
          ),
        );
    debugPrint('Zmieniono checkbox: $row');
    debugPrint('Zmieniono checkbox: $row, exerciseNumber: $exerciseNumber');
  }

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
            exerciseNumber: rowData.exercise_number, // <-- poprawka!
          ),
        );
      }
    }
    ref.read(workoutPlanStateProvider.notifier).setPlanRows(planId, rowStates);
    debugPrint('Zapisano stan checkboxów do providera: $rowStates');
  }

  void _endWorkout(BuildContext context) {
    final timerController = ref.read(workoutProvider.notifier);
    timerController.stopTimer();

    ref.read(currentWorkoutPlanProvider.notifier).state = null;
    ref.read(workoutPlanStateProvider.notifier).clearPlan(widget.plan.id);
    Navigator.of(context).pop();
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
      ;
    }

    final groupedData = <String, List<ExerciseRowsData>>{};
    for (final row in widget.plan.rows) {
      groupedData.putIfAbsent(row.exercise_name, () => []).add(row);
    }

    Widget headerCellText(BuildContext context, String text) {
      return Container(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
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
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            subject == "step"
                ? Text(
                  text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  ),
                )
                : TextField(
                  controller: TextEditingController(text: text),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (subject == "weight") {
                      _onKgChanged(row, value, exerciseNumber);
                    } else if (subject == "reps") {
                      _onRepChanged(row, value, exerciseNumber);
                    }
                  },
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
      );
    }
    List<TableRow> buildExerciseTableRows(List<ExerciseRowsData> exerciseRows) {
  final List<TableRow> rows = [];
  for (final exerciseRowsData in exerciseRows) {
    for (int idx = 0; idx < exerciseRowsData.data.length; idx++) {
      final row = exerciseRowsData.data[idx];
      final rowId = idx + 1;
      rows.add(
        TableRow(
          decoration: BoxDecoration(
            color: row.rowColor,
          ),
          children: [
            cellText(
              context,
              "$rowId",
              "step",
              row: row,
              exerciseNumber: exerciseRowsData.exercise_number,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () => _toogleRowChecked(
                  row,
                  exerciseRowsData.exercise_number,
                ),
                icon: Icon(
                  row.isChecked
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: Theme.of(context).colorScheme.onSurface,
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
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: ExpandableNotifier(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_downward,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: () {
                          _saveAllRowsToProvider();
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        widget.plan.exercise_table,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(width: 20),
                      Row(
                        children: [
                          Icon(
                            Icons.timelapse,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            getTime(context),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Text(
                        getCurrentStep().toString(),
                        // getCurrentStep().toString() / totalSteps.toString(),
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(width: 20),
                      TextButton(
                        onPressed: () {
                          _endWorkout(context);
                        },
                        child: Text(
                          "End Workout",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                      children:
                          groupedData.entries.map((entry) {
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

                            return Card(
                              color: Theme.of(context).colorScheme.surface
                                  .withAlpha((0.9 * 255).toInt()),
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 20,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _openInfoExercise(matchingExercise);
                                          },
                                          child: ClipOval(
                                            child:
                                                matchingExercise
                                                        .gifUrl
                                                        .isNotEmpty
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
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Text(
                                                        "brak",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                    ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            exerciseName,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge!.copyWith(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    if (firstRow.notes.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        child: Text(
                                          "Notes: ${firstRow.notes}",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall!.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.7),
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
                                            headerCellText(context, "Step"),
                                            headerCellText(context, "KG"),
                                            headerCellText(context, "Reps"),
                                            Container(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.1),
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Icon(
                                                Icons.check,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                        ...buildExerciseTableRows(exerciseRows),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
