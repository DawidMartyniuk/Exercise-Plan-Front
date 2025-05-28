import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/exercise.dart';
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

  void _openInfoExercise(Exercise exercise) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => (ExerciseInfoScreen(exercise: exercise)),
    );
  }

  void _startWorkout() {
    setState(() {
      _workoutStarted = true;
    });
  }

  void _toggleCardExpansion(int index) {
    setState(() {
      _expandedCards[index] = !(_expandedCards[index] ?? false);
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Przy inicjalizacji pobierz stan z providera i ustaw wartości wierszy
    final planId = widget.plan.id;
    final savedRows = ref.read(workoutPlanStateProvider).getRows(planId);
    if (savedRows.isNotEmpty) {
      for (final rowData in widget.plan.rows) {
        for (final row in rowData.data) {
          final match = savedRows.firstWhere(
            (e) => e.colStep == row.colStep,
            orElse: () => ExerciseRowState(
              colStep: row.colStep,
              colKg: row.colKg,
              colRep: row.colRep,
              isChecked: row.isChecked,
            ),
          );
          row.colKg = match.colKg;
          row.colRep = match.colRep;
          row.isChecked = match.isChecked;
          row.rowColor = row.isChecked ? Colors.green : Colors.transparent;
        }
      }
    }
  }

  void _toogleRowChecked(ExerciseRow row) {
    setState(() {
      row.isChecked = !row.isChecked;
      row.rowColor = row.isChecked ? Colors.green : Colors.transparent;
    });
    ref.read(workoutPlanStateProvider.notifier).updateRow(
      widget.plan.id,
      ExerciseRowState(
        colStep: row.colStep,
        colKg: row.colKg,
        colRep: row.colRep,
        isChecked: row.isChecked,
      ),
    );
  }

  // Dodaj obsługę zmiany wartości kg/reps
  void _onKgChanged(ExerciseRow row, String value) {
    setState(() {
      row.colKg = int.tryParse(value) ?? row.colKg;
    });
    ref.read(workoutPlanStateProvider.notifier).updateRow(
      widget.plan.id,
      ExerciseRowState(
        colStep: row.colStep,
        colKg: row.colKg,
        colRep: row.colRep,
        isChecked: row.isChecked,
      ),
    );
  }

  void _onRepChanged(ExerciseRow row, String value) {
    setState(() {
      row.colRep = int.tryParse(value) ?? row.colRep;
    });
    ref.read(workoutPlanStateProvider.notifier).updateRow(
      widget.plan.id,
      ExerciseRowState(
        colStep: row.colStep,
        colKg: row.colKg,
        colRep: row.colRep,
        isChecked: row.isChecked,
      ),
    );
  }

  void _endWorkout(BuildContext context) {
    // TODO: implementacja zakończenia treningu
  }

  @override
  Widget build(BuildContext context) {
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

    Widget cellText(BuildContext context, String text, String subject, {bool bold = false, required ExerciseRow row}) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: subject == "step"
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
                    _onKgChanged(row, value);
                  } else if (subject == "reps") {
                    _onRepChanged(row, value);
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
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        widget.plan.exercise_table,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          _endWorkout(context);
                        },
                        child: Text(
                          "End Workout",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      children: groupedData.entries.map((entry) {
                        final exerciseName = entry.key;
                        final exerciseRows = entry.value;
                        final firstRow = exerciseRows.first;

                        final matchingExercise = widget.exercises.firstWhere(
                          (ex) =>
                              int.tryParse(ex.id) ==
                              int.tryParse(firstRow.exercise_number),
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
                                              color: Theme.of(
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
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.check,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                    for (int i = 0;
                                        i < exerciseRows.length;
                                        i++)
                                      ...exerciseRows[i].data.asMap().entries.map(
                                        (entry) {
                                          final row = entry.value;
                                          final rowId = entry.key + 1;
                                          return TableRow(
                                            decoration: BoxDecoration(
                                              color: row.rowColor,
                                            ),
                                            children: [
                                              cellText(context, "$rowId","step", row: row),
                                              cellText(context, "${row.colKg}","weight", row: row),
                                              cellText(context, "${row.colRep}","reps", row: row),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: IconButton(
                                                  onPressed: () =>
                                                      _toogleRowChecked(row),
                                                  icon: Icon(
                                                    row.isChecked
                                                        ? Icons.check_box
                                                        : Icons
                                                            .check_box_outline_blank,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // ...możesz dodać inne przyciski, np. zakończ trening...
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
