import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/current_workout.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/model/reps_type.dart';
import 'package:work_plan_front/provider/exercise_plan_notifier.dart';
import 'package:work_plan_front/provider/current_workout_plan_provider.dart';
import 'package:work_plan_front/provider/reps_type_provider.dart';
import 'package:work_plan_front/provider/wordout_time_notifer.dart';
import 'package:work_plan_front/screens/exercise_info/exercise_info.dart';
import 'package:work_plan_front/provider/workout_plan_state_provider.dart';
import 'package:work_plan_front/screens/exercises.dart';
import 'package:work_plan_front/screens/plan_creation.dart';
import 'package:work_plan_front/screens/save_workout/save_workout.dart';
import 'package:work_plan_front/widget/plan/plan_works/helpers/worokout_exercise_replacement_menager.dart';
import 'package:work_plan_front/widget/plan/plan_works/plan_selected/components/plan_stats_bar.dart';
import 'package:work_plan_front/widget/plan/plan_works/plan_selected/widget/action_button.dart';
import 'package:work_plan_front/widget/plan/plan_works/plan_selected/widget/progress_bar.dart';
import '../helpers/plan_helpers.dart';
import '../helpers/exercise_calculator.dart';
import '../helpers/exercise_table_helpers.dart';
import 'plan_selected_card.dart';
import 'components/plan_selected_appBar.dart';
import 'plan_selected_details.dart';
// TODO: Powrucić do konceptu początkowego czyli wartoiści na początku są w hint potem po zaznaczeniu stają się widoczne
// i zawsze możan je usuwac do " "  i zmineiac

//TODO  ODSTĘP MIĘDZY PRZYciskami , kolor tekstu na opise ma być bardziej widoczny,
class PlanSelectedList extends ConsumerStatefulWidget {
  final ExerciseTable plan;
  final List<Exercise> exercises;
  final VoidCallback? onStartWorkout;
  final bool isReadOnly;
  final bool isWorkoutMode;

  const PlanSelectedList({
    super.key,
    required this.plan,
    required this.exercises,
    required this.isReadOnly,
    required this.isWorkoutMode,
    this.onStartWorkout,
  });

  @override
  ConsumerState<PlanSelectedList> createState() => _PlanSelectedListState();
}

class _PlanSelectedListState extends ConsumerState<PlanSelectedList>
    with PlanHelpers, ExerciseCalculations {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final WorkoutExerciseReplacementManager _replacementManager =
      WorkoutExerciseReplacementManager();

  ScrollController? _scrollController;
  Timer? _timer;

  late ExerciseTable _originalPlan;
  late ExerciseTable _workingPlan;
  bool _isWorkoutActive = false;
  WorkoutTimeNotifier _workoutTimeNotifier = WorkoutTimeNotifier();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _originalPlan = _createDeepCopyOfPlan(widget.plan);

    _workingPlan = _createDeepCopyOfPlan(widget.plan);
    startTimer();

    _initializePlanData();
  }

  void startTimer() {
    if (widget.isWorkoutMode) {
      print("🕐 Uruchamianie timera treningu...");
      _isWorkoutActive = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(workoutProvider.notifier).startTimer();
      });
    } else {
      _isWorkoutActive = false;
    }
  }

  @override
  void dispose() {
    print("🗑️ Disposing PlanSelectedList");

    _replacementManager.clearAllPendingData();

    _timer?.cancel();
    _scrollController?.dispose();
    super.dispose();
  }

  ExerciseTable _createDeepCopyOfPlan(ExerciseTable plan) {
    return ExerciseTable(
      id: plan.id,
      exercise_table: plan.exercise_table,
      rows:
          plan.rows
              .map(
                (row) => ExerciseRowsData(
                  exercise_number: row.exercise_number,
                  exercise_name: row.exercise_name,
                  notes: row.notes,
                  rep_type: row.rep_type,
                  data:
                      row.data
                          .map(
                            (exerciseRow) => ExerciseRow(
                              colStep: exerciseRow.colStep,
                              colKg: exerciseRow.colKg,
                              colRepMin: exerciseRow.colRepMin,
                              colRepMax: exerciseRow.colRepMax,
                              isChecked: exerciseRow.isChecked,
                              isFailure: exerciseRow.isFailure,
                              rowColor: exerciseRow.rowColor,
                              isUserModified: false,
                            ),
                          )
                          .toList(),
                ),
              )
              .toList(),
    );
  }

  void _initializePlanData() {
    final planId = _workingPlan.id;
    final savedRows = ref.read(workoutPlanStateProvider).getRows(planId);

    for (final exerciseData in _workingPlan.rows) {
      print("🔍 Ćwiczenie: ${exerciseData.exercise_name}");

      for (final row in exerciseData.data) {
        print(
          "🔍 Seria ${row.colStep}: colKg=${row.colKg}, colRepMin=${row.colRepMin}",
        );

        if (row.colKg == 0) {
          row.colKg = 20;
          print("🔍 Ustawiono domyślną wagę: ${row.colKg}");
        }
      }
    }

    print(
      "🔍 _initializePlanData: planId=$planId, savedRows.length=${savedRows.length}",
    );

    Future(() {
      for (final rowData in _workingPlan.rows) {
        final hasRange = rowData.data.any(
          (row) =>
              row.colRepMin > 0 &&
              row.colRepMax > 0 &&
              row.colRepMin != row.colRepMax,
        );

        if (hasRange) {
          ref
              .read(exerciseRepsTypeProvider(rowData.exercise_number).notifier)
              .state = RepsType.range;
          print("✅ Ustawiono RepsType.range dla ${rowData.exercise_number}");
        } else {
          ref
              .read(exerciseRepsTypeProvider(rowData.exercise_number).notifier)
              .state = RepsType.single;
          print(" Ustawiono RepsType.single dla ${rowData.exercise_number}");
        }

        print(
          "🔍 Exercise ${rowData.exercise_number}: ${rowData.data.first.colRepMin}-${rowData.data.first.colRepMax}",
        );
      }
    });

    if (savedRows.isNotEmpty) {
      _applyUserProgress(savedRows);
    } else {
      print("⚠️ Brak zapisanego progresu - dane pozostają bez zmian");
    }
  }

  Future<void> _replaceExercise(String exerciseNumber) async {
    print("🔄 Starting exercise replacement for: $exerciseNumber");
    if (!_replacementManager.canReplaceExercise(
      exerciseNumber: exerciseNumber,
      workingPlan: _workingPlan,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot replace this exercise - no data found'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final savedData = _replacementManager.saveExerciseDataFromPlan(
        exerciseNumber: exerciseNumber,
        workingPlan: _workingPlan,
      );

      _replacementManager.logExerciseReplacementInfo(
        exerciseNumber: exerciseNumber,
        workingPlan: _workingPlan,
      );

      _replacementManager.storePendingData(exerciseNumber, savedData);

      final result = await Navigator.of(context).push<Exercise>(
        MaterialPageRoute(
          builder:
              (ctx) => ExercisesScreen(
                isSelectionMode: true,
                title: 'Replace Exercise',

                onSingleExerciseSelected: (exercise) {
                  print(
                    '🔄 Exercise selected for replacement: ${exercise.name}',
                  );
                  Navigator.of(context).pop(exercise);
                },
              ),
        ),
      );

      if (result != null) {
        final oldExercise = widget.exercises.firstWhere(
          (ex) => ex.id == exerciseNumber,
          orElse:
              () => Exercise(
                exerciseId: exerciseNumber,
                name: "Unknown Exercise",
                bodyParts: [],
                equipments: [],
                gifUrl: '',
                targetMuscles: [],
                secondaryMuscles: [],
                instructions: [],
              ),
        );

        setState(() {
          _replacementManager.replaceExerciseInPlan(
            oldExerciseNumber: exerciseNumber,
            newExercise: result,
            workingPlan: _workingPlan,
            savedData: savedData,
            onStateChanged: () {
              _updateCurrentWorkoutPlan();
              _saveAllRowsToProvider();
            },
          );
        });

        _replacementManager.clearPendingData(exerciseNumber);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exercise replaced successfully! )'),

            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        print("✅ Exercise replacement completed successfully");
      } else {
        _replacementManager.clearPendingData(exerciseNumber);
        print("❌ Exercise replacement cancelled by user");
      }
    } catch (e) {
      print("❌ Error during exercise replacement: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error replacing exercise: $e'),
          backgroundColor: Colors.red,
        ),
      );

      _replacementManager.clearPendingData(exerciseNumber);
    }
  }

  String _getOriginalRange(String exerciseNumber, int colStep) {
    final originalRow = _getOriginalRowData(exerciseNumber, colStep);
    if (originalRow != null && originalRow.colRepMin != originalRow.colRepMax) {
      return "${originalRow.colRepMin} - ${originalRow.colRepMax}";
    }
    return "0";
  }

  Future<void> _addMultipleExercisesToPlan() async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder:
            (ctx) => ExercisesScreen(
              isSelectionMode: true,
              title: 'Select Exercises for Plan',
              onMultipleExercisesSelected: (exercises) {
                print('🔧 Callback wywołany z ${exercises.length} ćwiczeniami');
              },
            ),
      ),
    );

    print('🔧 Navigator.pop zwrócił: $result (typ: ${result.runtimeType})');

    if (result != null) {
      if (result is List<Exercise>) {
        int addedCount = 0;

        setState(() {
          for (final exercise in result) {
            final exerciseExists = _workingPlan.rows.any(
              (rowData) => rowData.exercise_number == exercise.id,
            );

            if (!exerciseExists) {
              final newRow = ExerciseRowsData(
                exercise_number: exercise.id,
                exercise_name: exercise.name,
                notes: '',
                rep_type: RepsType.single,
                data: [
                  ExerciseRow(
                    colStep: 1,
                    colKg: 0,
                    colRepMin: 0,
                    colRepMax: 0,
                    isChecked: false,
                    isFailure: false,
                    rowColor: Colors.transparent,
                    isUserModified: false,
                  ),
                ],
              );
              _workingPlan.rows.add(newRow);
              addedCount++;
            }
          }
        });

        print('✅ Dodano $addedCount nowych ćwiczeń do planu');

        _updateCurrentWorkoutPlan();

        //  POKAŻ TOAST
        if (addedCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Added $addedCount exercise${addedCount > 1 ? 's' : ''} to plan',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('All selected exercises already exist in plan'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else if (result is Exercise) {
        final exerciseExists = _workingPlan.rows.any(
          (rowData) => rowData.exercise_number == result.id,
        );

        if (!exerciseExists) {
          setState(() {
            final newRow = ExerciseRowsData(
              exercise_number: result.id,
              exercise_name: result.name,
              notes: '',
              rep_type: RepsType.single,
              data: [
                ExerciseRow(
                  colStep: 1,
                  colKg: 0,
                  colRepMin: 0,
                  colRepMax: 0,
                  isChecked: false,
                  isFailure: false,
                  rowColor: Colors.transparent,
                  isUserModified: false,
                ),
              ],
            );
            _workingPlan.rows.add(newRow);
          });

          _updateCurrentWorkoutPlan();

          print('✅ Dodano ćwiczenie: ${result.name}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${result.name} to plan'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.name} already exists in plan'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } else {
      print('⚠️ Użytkownik anulował wybór ćwiczeń');
    }
  }

  ExerciseRow? _getOriginalRowData(String exerciseNumber, int colStep) {
    for (final rowData in _originalPlan.rows) {
      if (rowData.exercise_number == exerciseNumber) {
        for (final row in rowData.data) {
          if (row.colStep == colStep) {
            return row;
          }
        }
      }
    }
    return null;
  }

  void _applyUserProgress(List<ExerciseRowState> savedRows) {
    print("🔍 _applyUserProgress: savedRows.length = ${savedRows.length}");

    for (final rowData in _workingPlan.rows) {
      print(
        "🔍 Processing exercise: ${rowData.exercise_name} (${rowData.exercise_number})",
      );

      for (final row in rowData.data) {
        print(
          "🔍 Looking for step ${row.colStep}, exercise ${rowData.exercise_number}",
        );
        print(
          "🔍 Original row: colRepMin=${row.colRepMin}, colRepMax=${row.colRepMax}",
        );

        final match = savedRows.firstWhereOrNull(
          (e) =>
              e.colStep == row.colStep &&
              e.exerciseNumber == rowData.exercise_number,
        );

        if (match != null) {
          print("✅ Found saved progress for step ${row.colStep}");
          row.colKg = match.colKg;
          row.colRepMin = match.colRepMin;
          row.colRepMax = match.colRepMax;
          row.isChecked = match.isChecked;
          row.isFailure = match.isFailure;
        } else {
          print("⚠️ No saved progress - keeping original values");
        }

        print(
          "🔍 Final row: colRepMin=${row.colRepMin}, colRepMax=${row.colRepMax}",
        );
        row.rowColor = row.isChecked ? Colors.green : Colors.transparent;
      }
    }
  }

  void _deleteExerciseFromPlan(String exerciseNumber) {
    setState(() {
      _workingPlan.rows.removeWhere(
        (rowData) => rowData.exercise_number == exerciseNumber,
      );
    });
    _updateCurrentWorkoutPlan();
    _removeExerciseFromWorkoutState(exerciseNumber);
  }

  void _updateCurrentWorkoutPlan() {
    final newRows =
        _workingPlan.rows
            .map(
              (rowData) => rowData.copyWithData(
                rowData.data
                    .map(
                      (row) => ExerciseRow(
                        colStep: row.colStep,
                        colKg: row.colKg,
                        colRepMin: row.colRepMin,
                        colRepMax: row.colRepMax,
                        isChecked: row.isChecked,
                        isFailure: row.isFailure,
                        rowColor: row.rowColor,
                      ),
                    )
                    .toList(),
              ),
            )
            .toList();

    final newPlan = _workingPlan.copyWithRows(newRows);
    ref.read(currentWorkoutPlanProvider.notifier).state = Currentworkout(
      plan: newPlan,
      exercises: widget.exercises,
    );
  }

  void _saveAllRowsToProvider() {
    final planId = _workingPlan.id;
    final rowStates = <ExerciseRowState>[];

    for (final rowData in _workingPlan.rows) {
      for (final row in rowData.data) {
        rowStates.add(
          ExerciseRowState(
            colStep: row.colStep,
            colKg: row.colKg,
            colRepMin: row.colRepMin,
            colRepMax: row.colRepMax,
            isChecked: row.isChecked,
            isFailure: row.isFailure,
            exerciseNumber: rowData.exercise_number,
          ),
        );
      }
    }

    ref.read(workoutPlanStateProvider.notifier).setPlanRows(planId, rowStates);
  }

  void _onToggleRowChecked(ExerciseRow row, String exerciseNumber) {
    print(
      "🔍 PRZED TOGGLE: isChecked=${row.isChecked}, colRepMin=${row.colRepMin}, isUserModified=${row.isUserModified}",
    );

    setState(() {
      row.isChecked = !row.isChecked;
      row.rowColor =
          row.isChecked
              ? const Color.fromARGB(255, 103, 189, 106)
              : Colors.transparent;

      final repsType = ref.read(exerciseRepsTypeProvider(exerciseNumber));
      print("🔍 repsType: $repsType");

      if (repsType == RepsType.range && !row.isUserModified) {
        if (row.isChecked) {
          final originalRow = _getOriginalRowData(exerciseNumber, row.colStep);
          if (originalRow != null) {
            print(
              "🔍 ZAZNACZENIE: Oryginalny zakres ${originalRow.colRepMin}-${originalRow.colRepMax}",
            );
            final middleValue =
                ((originalRow.colRepMin + originalRow.colRepMax) ~/ 2).round();
            row.colRepMin = middleValue;
            row.isUserModified = true;
            print("🔍 ZAZNACZENIE: Ustawiono środkową wartość: $middleValue");
          }
        }
      }

      if (row.isUserModified) {
        print("🔍 TOGGLE: Zachowuję wartość użytkownika: ${row.colRepMin}");
      }
    });

    print(
      "🔍 PO TOGGLE: isChecked=${row.isChecked}, colRepMin=${row.colRepMin}, isUserModified=${row.isUserModified}",
    );
    _updateRowInProvider(row, exerciseNumber);
    _updateCurrentWorkoutPlan();
  }

  void _onKgChanged(ExerciseRow row, String value, String exerciseNumber) {
    print("🏋️ _onKgChanged: value='$value', exerciseNumber=$exerciseNumber");
    print("🏋️ PRZED: colKg=${row.colKg}");

    setState(() {
      if (value.isEmpty) {
        row.colKg = 0;
        print("🏋️ PUSTE POLE: Ustawiono 0");
      } else {
        final newValue = double.tryParse(value) ?? 0;
        if (newValue >= 0) {
          row.colKg = newValue as int;
          print("🏋️ NOWA WARTOŚĆ: Ustawiono ${newValue}");
        } else {
          print("⚠️ NIEPRAWIDŁOWA WARTOŚĆ WAGI: '$value' - ignorowanie");
          return;
        }
      }
    });

    print("🏋️ PO: colKg=${row.colKg}");
    _updateRowInProvider(row, exerciseNumber);
  }

  void _addNewSet(String exerciseNumber) {
    print("➕ Dodawanie nowej serii dla ćwiczenia: $exerciseNumber");

    setState(() {
      final exerciseIndex = _workingPlan.rows.indexWhere(
        (rowData) => rowData.exercise_number == exerciseNumber,
      );

      if (exerciseIndex != -1) {
        final exerciseData = _workingPlan.rows[exerciseIndex];
        final newStepNumber = exerciseData.data.length + 1;

        final lastSet =
            exerciseData.data.isNotEmpty ? exerciseData.data.last : null;

        final newSet = ExerciseRow(
          colStep: newStepNumber,
          colKg: lastSet?.colKg ?? 0,
          colRepMin: lastSet?.colRepMin ?? 0,
          colRepMax: lastSet?.colRepMax ?? 0,
          isChecked: false,
          isFailure: false,
          rowColor: Colors.transparent,
          isUserModified: false,
        );

        _workingPlan.rows[exerciseIndex].data.add(newSet);

        print("✅ Dodano serię ${newStepNumber} do ćwiczenia $exerciseNumber");
        print("   - Waga: ${newSet.colKg}");
        print("   - Powtórzenia: ${newSet.colRepMin}-${newSet.colRepMax}");
      }
    });

    _updateCurrentWorkoutPlan();
  }

  void _removeLastSet(String exerciseNumber) {
    print("➖ Usuwanie ostatniej serii z ćwiczenia: $exerciseNumber");

    setState(() {
      // Znajdź ćwiczenie
      final exerciseIndex = _workingPlan.rows.indexWhere(
        (rowData) => rowData.exercise_number == exerciseNumber,
      );

      if (exerciseIndex != -1) {
        final exerciseData = _workingPlan.rows[exerciseIndex];

        if (exerciseData.data.length > 1) {
          final removedSet = exerciseData.data.removeLast();
          print(
            "✅ Usunięto serię ${removedSet.colStep} z ćwiczenia $exerciseNumber",
          );

          for (int i = 0; i < exerciseData.data.length; i++) {
            exerciseData.data[i].colStep = i + 1;
          }

          print(
            "✅ Przenumerowano serie: ${exerciseData.data.map((s) => s.colStep).join(', ')}",
          );
        } else {
          print("⚠️ Nie można usunąć - musi pozostać przynajmniej 1 seria");
          return;
        }
      }
    });

    _updateCurrentWorkoutPlan();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed last set'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onToggleRowFailure(ExerciseRow row, String exerciseNumber) {
    setState(() {
      row.isFailure = !row.isFailure;
    });
    _updateRowInProvider(row, exerciseNumber);
  }

  void _onRepChanged(ExerciseRow row, String value, String exerciseNumber) {
    print("🔍 _onRepChanged: value='$value', exerciseNumber=$exerciseNumber");
    print(
      "🔍 _onRepChanged PRZED: colRepMin=${row.colRepMin}, isUserModified=${row.isUserModified}",
    );

    setState(() {
      final repsType = ref.read(exerciseRepsTypeProvider(exerciseNumber));

      if (value.isEmpty) {
        row.isUserModified = false;

        final originalRow = _getOriginalRowData(exerciseNumber, row.colStep);
        if (originalRow != null) {
          row.colRepMin = originalRow.colRepMin;
          if (repsType == RepsType.single) {
            row.colRepMax = originalRow.colRepMax;
          }
          print(
            "🔍 PUSTE POLE: Przywrócono oryginalną wartość: ${originalRow.colRepMin}",
          );
        } else {
          print("🔍 PUSTE POLE: Brak oryginalnych danych - pozostawiam obecną");
        }
      } else {
        final newValue = int.tryParse(value) ?? 0;
        if (newValue >= 0) {
          row.isUserModified = true;
          row.colRepMin = newValue;

          if (repsType == RepsType.single) {
            row.colRepMax = newValue;
          }

          print("🔍 NOWA WARTOŚĆ: Ustawiono ${newValue}, isUserModified=true");
        } else {
          print("⚠️ NIEPRAWIDŁOWA WARTOŚĆ: '$value' - ignorowanie");
          return;
        }
      }
    });

    print(
      "🔍 _onRepChanged PO: colRepMin=${row.colRepMin}, isUserModified=${row.isUserModified}",
    );
    _updateRowInProvider(row, exerciseNumber);
  }

  void _updateRowInProvider(ExerciseRow row, String exerciseNumber) {
    ref
        .read(workoutPlanStateProvider.notifier)
        .updateRow(
          _workingPlan.id,
          ExerciseRowState(
            colStep: row.colStep,
            colKg: row.colKg,
            colRepMin: row.colRepMin,
            colRepMax: row.colRepMax,
            isChecked: row.isChecked,
            isFailure: row.isFailure,
            exerciseNumber: exerciseNumber,
          ),
        );
  }

  void _goEditPlan() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => PlanCreation(planToEdit: _workingPlan),
      ),
    );
  }

  void _addSingleExerciseToPlan(Exercise exercise) {
    final exerciseExists = _workingPlan.rows.any(
      (rowData) => rowData.exercise_number == exercise.id,
    );

    if (!exerciseExists) {
      setState(() {
        final newRow = ExerciseRowsData(
          exercise_number: exercise.id,
          exercise_name: exercise.name,
          notes: '',
          rep_type: RepsType.single,
          data: [
            ExerciseRow(
              colStep: 1,
              colKg: 0,
              colRepMin: 0,
              colRepMax: 0,
              isChecked: false,
              isFailure: false,
              rowColor: Colors.transparent,
              isUserModified: false,
            ),
          ],
        );
        _workingPlan.rows.add(newRow);
      });

      _updateCurrentWorkoutPlan();

      print('✅ Dodano ćwiczenie: ${exercise.name}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${exercise.name} to plan'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${exercise.name} already exists in plan'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _endWorkout(BuildContext context) {
    final planIndex = ref
        .read(exercisePlanProvider)
        .indexWhere((plan) => plan.id == widget.plan.id);

    if (planIndex != -1) {
      final currentPlans = List<ExerciseTable>.from(
        ref.read(exercisePlanProvider),
      );
      currentPlans[planIndex] = _createDeepCopyOfPlan(_originalPlan);
      ref.read(exercisePlanProvider.notifier).state = currentPlans;
    }

    _isWorkoutActive = false;
    Navigator.of(context).pop();
  }

  void _removeExerciseFromWorkoutState(String exerciseNumber) {
    ref
        .read(workoutPlanStateProvider.notifier)
        .removeExercise(_workingPlan.id, exerciseNumber);
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = ExerciseTableHelpers.groupExercisesByName(
      _workingPlan,
      widget.exercises,
    );

    int totalSteps = 0;
    int currentStep = 0;

    for (final rowData in _workingPlan.rows) {
      for (final row in rowData.data) {
        totalSteps++;
        if (row.isChecked) {
          currentStep++;
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const Drawer(child: PlanSelectedDetails()),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: PlanSelectedAppBar(
                        onBack: () {
                          print("🔙 PlanSelectedAppBar onBack wywołany");

                          if (widget.isWorkoutMode && _isWorkoutActive) {
                            _saveAllRowsToProvider();

                            ref
                                .read(currentWorkoutPlanProvider.notifier)
                                .state = Currentworkout(
                              plan: _workingPlan,
                              exercises: widget.exercises,
                            );
                          } else if (widget.isReadOnly) {
                          } else {
                            print("💾 Tryb edycji - zapisuję zmiany");
                            _saveAllRowsToProvider();
                          }
                        },
                        planName: _workingPlan.exercise_table,
                        onSavePlan: _savePlan,
                        isReadOnly: widget.isReadOnly,
                        isWorkoutMode: widget.isWorkoutMode,
                        onEditPlan: _goEditPlan,
                      ),
                    ),
                    if (widget.isWorkoutMode) ...[
                      SliverToBoxAdapter(
                        child: Consumer(
                          builder:
                              (context, ref, _) => PlanStatsBar(
                                isWorkoutMode: widget.isWorkoutMode,
                                isWorkoutActive: _isWorkoutActive,
                                sets: currentStep,
                              ),
                        ),
                      ),
                    ],

                    SliverToBoxAdapter(
                      child: ProgressBar(
                        totalSteps: totalSteps,
                        currentStep: currentStep,
                        isReadOnly: widget.isReadOnly,
                      ),
                    ),

                    SliverList(
                      delegate: SliverChildListDelegate([
                        ..._buildExerciseCards(groupedData),
                        const SizedBox(height: 24),
                        ActionButton(
                          isReadOnly: widget.isReadOnly,
                          isWorkoutMode: widget.isWorkoutMode,
                          addMultipleExercisesToPlan:
                              _addMultipleExercisesToPlan,
                          onEndWorkout: () => _endWorkout(context),
                          plan: _workingPlan,
                          exercises:
                              widget.exercises.isNotEmpty
                                  ? widget.exercises.first
                                  : Exercise(
                                    exerciseId: '',
                                    name: '',
                                    bodyParts: [],
                                    equipments: [],
                                    gifUrl: '',
                                    targetMuscles: [],
                                    secondaryMuscles: [],
                                    instructions: [],
                                  ),
                        ),
                        const SizedBox(height: 24),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _savePlan() {
    final timerController = ref.read(workoutProvider.notifier);
    final startHour = timerController.startHour ?? 0;
    final startMinute = timerController.startMinute ?? 0;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (ctx) => SaveWorkout(
              allTime: timerController.currentTime,
              allReps: calculateTotalReps(_workingPlan),
              allWeight: calculateTotalVolume(_workingPlan),
              startHour: startHour,
              startMinute: startMinute,
              planName: _workingPlan.exercise_table,
              onEndWorkout: () => _endWorkout(context),
            ),
      ),
    );
  }

  List<Widget> _buildExerciseCards(
    Map<String, List<ExerciseRowsData>> groupedData,
  ) {
    return groupedData.entries.map((entry) {
      final exerciseName = entry.key;
      final exerciseRows = entry.value;
      final firstRow = exerciseRows.first;

      final matchingExercise = widget.exercises.firstWhere(
        (ex) => ex.id == firstRow.exercise_number,
        orElse:
            () => Exercise(
              exerciseId: firstRow.exercise_number,
              name: exerciseName,
              bodyParts: [],
              equipments: [],
              gifUrl: '',
              targetMuscles: [],
              secondaryMuscles: [],
              instructions: [],
            ),
      );

      return PlanSelectedCard(
        exerciseId: firstRow.exercise_number,
        exerciseName: exerciseName,
        headerCellTextStep: ExerciseTableHelpers.buildHeaderCell(
          context,
          "Step",
        ),
        headerCellTextKg: ExerciseTableHelpers.buildHeaderCell(
          context,
          "Weight",
        ),
        headerCellTextReps: ExerciseTableHelpers.buildHeaderCell(
          context,
          "Reps",
        ),
        notes: firstRow.notes,
        isReadOnly: widget.isReadOnly,
        onAddSet:
            widget.isReadOnly
                ? null
                : (exerciseNumber) => _addNewSet(exerciseNumber),
        onRemoveSet: widget.isReadOnly ? null : _removeLastSet,
        setsCount: firstRow.data.length,
        onReplaceExercise:
            widget.isReadOnly
                ? null
                : () => _replaceExercise(firstRow.exercise_number),
        exerciseRows: ExerciseTableHelpers.buildExerciseTableRows(
          exerciseRows,
          context,
          onKgChanged:
              (row, value, exerciseNumber) =>
                  _onKgChanged(row, value, exerciseNumber),
          onRepChanged:
              (row, value, exerciseNumber) =>
                  _onRepChanged(row, value, exerciseNumber),
          onToggleChecked:
              (row, exerciseNumber) => _onToggleRowChecked(row, exerciseNumber),
          onToggleFailure:
              (row, exerciseNumber) => _onToggleRowFailure(row, exerciseNumber),
          ref: ref, //  DODAJ REF
          getOriginalRange: _getOriginalRange,
          isReadOnly: widget.isReadOnly,
        ),
        onNotesChanged: (value) {
          setState(() {
            final updatedRow = ExerciseRowsData(
              rep_type: RepsType.single,
              exercise_name: exerciseName,
              exercise_number: firstRow.exercise_number,
              data: firstRow.data,
              notes: value,
            );

            final index = groupedData[exerciseName]!.indexOf(firstRow);
            if (index != -1) {
              groupedData[exerciseName]![index] = updatedRow;
            }
          });
        },
        onTap: () => _openInfoExercise(matchingExercise),
        deleteExerciseCard:
            () => _deleteExerciseFromPlan(firstRow.exercise_number),
      );
    }).toList();
  }

  void _openInfoExercise(Exercise exercise) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseInfoScreen(exercise: exercise),
      ),
    );
  }
}
