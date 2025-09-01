import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/CurrentWorkout.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/model/reps_type.dart';
import 'package:work_plan_front/provider/ExercisePlanNotifier.dart';
import 'package:work_plan_front/provider/current_workout_plan_provider.dart';
import 'package:work_plan_front/provider/repsTypeProvider.dart';
import 'package:work_plan_front/provider/wordoutTimeNotifer.dart';
import 'package:work_plan_front/screens/exercise_info.dart';
import 'package:work_plan_front/provider/workout_plan_state_provider.dart';
import 'package:work_plan_front/screens/exercises.dart';
import 'package:work_plan_front/screens/save_workout/save_workout.dart';
import 'helpers/plan_helpers.dart';
import 'helpers/exercise_calculator.dart';
import 'components/exercise_table_helpers.dart';
import 'plan_selected/plan_selected_card.dart';
import 'plan_selected/plan_selected_appBar.dart';
import 'plan_selected/plan_selected_details.dart';

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
  ConsumerState<PlanSelectedList> createState() => _PlanSelectedListState();
}

class _PlanSelectedListState extends ConsumerState<PlanSelectedList> 
    with PlanHelpers, ExerciseCalculations {
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  ScrollController? _scrollController;
  Timer? _timer;

  late ExerciseTable _originalPlan; // ✅ ORYGINAŁ - nigdy nie modyfikowany
  late ExerciseTable _workingPlan;  // ✅ KOPIA ROBOCZA - na tej pracujemy
  bool _isWorkoutActive = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // ✅ ZACHOWAJ ORYGINAŁ
    _originalPlan = _createDeepCopyOfPlan(widget.plan);
    
    // ✅ STWÓRZ KOPIĘ ROBOCZĄ
    _workingPlan = _createDeepCopyOfPlan(widget.plan);
    
    _isWorkoutActive = false;
    _initializePlanData();
  }

  ExerciseTable _createDeepCopyOfPlan(ExerciseTable plan) {
    return ExerciseTable(
      id: plan.id,
      exercise_table: plan.exercise_table,
      rows: plan.rows.map((row) => ExerciseRowsData(
        exercise_number: row.exercise_number,
        exercise_name: row.exercise_name,
        notes: row.notes,
        rep_type: row.rep_type,
        data: row.data.map((exerciseRow) => ExerciseRow(
          colStep: exerciseRow.colStep,
          colKg: exerciseRow.colKg,
          colRepMin: exerciseRow.colRepMin,
          colRepMax: exerciseRow.colRepMax,
          isChecked: exerciseRow.isChecked,
          isFailure: exerciseRow.isFailure,
          rowColor: exerciseRow.rowColor,
          isUserModified: false,
        )).toList(),
      )).toList(),
    );
  }
void _initializePlanData() {
  final planId = _workingPlan.id;
  final savedRows = ref.read(workoutPlanStateProvider).getRows(planId);
  
  print("🔍 _initializePlanData: planId=$planId, savedRows.length=${savedRows.length}");
  
  // ✅ OPÓŹNIJ MODYFIKACJĘ PROVIDERA
  Future(() {
    // ✅ USTAW POPRAWNY REPS TYPE PO ZBUDOWANIU WIDGETU
    for (final rowData in _workingPlan.rows) {
      // ✅ SPRAWDŹ CZY TO ZAKRES I USTAW ODPOWIEDNI TYP
      final hasRange = rowData.data.any((row) => 
        row.colRepMin > 0 && row.colRepMax > 0 && row.colRepMin != row.colRepMax
      );
      
      if (hasRange) {
        // ✅ USTAW RANGE TYPE W PROVIDERZE (OPÓŹNIONE)
        ref.read(exerciseRepsTypeProvider(rowData.exercise_number).notifier).state = RepsType.range;
        print("✅ Ustawiono RepsType.range dla ${rowData.exercise_number}");
      } else {
        ref.read(exerciseRepsTypeProvider(rowData.exercise_number).notifier).state = RepsType.single;
        print("✅ Ustawiono RepsType.single dla ${rowData.exercise_number}");
      }
      
      print("🔍 Exercise ${rowData.exercise_number}: ${rowData.data.first.colRepMin}-${rowData.data.first.colRepMax}");
    }
  });
  
  if (savedRows.isNotEmpty) {
    _applyUserProgress(savedRows);
  } else {
    print("⚠️ Brak zapisanego progresu - dane pozostają bez zmian");
  }
}
String _getOriginalRange(String exerciseNumber, int colStep) {
  final originalRow = _getOriginalRowData(exerciseNumber, colStep);
  if (originalRow != null && originalRow.colRepMin != originalRow.colRepMax) {
    return "${originalRow.colRepMin} - ${originalRow.colRepMax}";
  }
  return "0";
}
  // ✅ DODAJ TĘ METODĘ DO KLASY _PlanSelectedListState
// Map<String, Map<String, int>> _getOriginalRanges() {
//   final originalRanges = <String, Map<String, int>>{};
  
//   // ✅ UŻYJ ORYGINALNEGO PLANU (NIE KOPII ROBOCZEJ)
//   for (final rowData in _originalPlan.rows) {
//     for (final row in rowData.data) {
//       final key = "${rowData.exercise_number}_${row.colStep}";
//       originalRanges[key] = {
//         'min': row.colRepMin,
//         'max': row.colRepMax,
//       };
//     }
//   }
  
//   print("🔍 Oryginalne zakresy:");
//   originalRanges.forEach((key, range) {
//     print("  - $key: ${range['min']} - ${range['max']}");
//   });
  
//   return originalRanges;
// }
ExerciseRow? _getOriginalRowData(String exerciseNumber, int colStep) {
  // ✅ ZNAJDŹ ORYGINALNĄ WARTOŚĆ Z _originalPlan
  for (final rowData in _originalPlan.rows) {
    if (rowData.exercise_number == exerciseNumber) {
      for (final row in rowData.data) {
        if (row.colStep == colStep) {
          return row; // ✅ ZWRÓĆ ORYGINALNY WIERSZ
        }
      }
    }
  }
  return null;
}
void _applyUserProgress(List<ExerciseRowState> savedRows) {
  print("🔍 _applyUserProgress: savedRows.length = ${savedRows.length}");
  
  for (final rowData in _workingPlan.rows) {
    print("🔍 Processing exercise: ${rowData.exercise_name} (${rowData.exercise_number})");
    
    for (final row in rowData.data) {
      print("🔍 Looking for step ${row.colStep}, exercise ${rowData.exercise_number}");
      print("🔍 Original row: colRepMin=${row.colRepMin}, colRepMax=${row.colRepMax}");
      
      final match = savedRows.firstWhereOrNull(
        (e) => e.colStep == row.colStep && e.exerciseNumber == rowData.exercise_number,
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
      
      print("🔍 Final row: colRepMin=${row.colRepMin}, colRepMax=${row.colRepMax}");
      row.rowColor = row.isChecked ? Colors.green : Colors.transparent;
    }
  }
}


  // ✅ METODA USUWANIA - TYLKO Z KOPII ROBOCZEJ
  void _deleteExerciseFromPlan(String exerciseNumber) {
    setState(() {
      // ✅ USUŃ Z KOPII ROBOCZEJ, NIE Z ORYGINAŁU
      _workingPlan.rows.removeWhere((rowData) => 
          rowData.exercise_number == exerciseNumber);
    });
    _updateCurrentWorkoutPlan();
    _removeExerciseFromWorkoutState(exerciseNumber);
  }

  // ✅ AKTUALIZUJ WORKOUT PLAN - UŻYJ KOPII ROBOCZEJ
  void _updateCurrentWorkoutPlan() {
    final newRows = _workingPlan.rows.map((rowData) => 
      rowData.copyWithData(
        rowData.data.map((row) => ExerciseRow(
          colStep: row.colStep,
          colKg: row.colKg,
          colRepMin: row.colRepMin,
          colRepMax: row.colRepMax,
          isChecked: row.isChecked,
          isFailure: row.isFailure,
          rowColor: row.rowColor,
        )).toList(),
      )
    ).toList();

    final newPlan = _workingPlan.copyWithRows(newRows);
    ref.read(currentWorkoutPlanProvider.notifier).state = Currentworkout(
      plan: newPlan,
      exercises: widget.exercises,
    );
  }

  // ✅ ZAPISZ DANE Z KOPII ROBOCZEJ
  void _saveAllRowsToProvider() {
    final planId = _workingPlan.id;
    final rowStates = <ExerciseRowState>[];
    
    for (final rowData in _workingPlan.rows) {
      for (final row in rowData.data) {
        rowStates.add(ExerciseRowState(
          colStep: row.colStep,
          colKg: row.colKg,
          colRepMin: row.colRepMin,
          colRepMax: row.colRepMax,
          isChecked: row.isChecked,
          isFailure: row.isFailure,
          exerciseNumber: rowData.exercise_number,
        ));
      }
    }
    
    ref.read(workoutPlanStateProvider.notifier).setPlanRows(planId, rowStates);
  }

  // ✅ ROW INTERACTIONS - PRACUJ NA KOPII ROBOCZEJ
void _onToggleRowChecked(ExerciseRow row, String exerciseNumber) {
  print("🔍 PRZED TOGGLE: isChecked=${row.isChecked}, colRepMin=${row.colRepMin}, colRepMax=${row.colRepMax}");
  
  setState(() {
    row.isChecked = !row.isChecked;
    row.rowColor = row.isChecked 
        ? const Color.fromARGB(255, 103, 189, 106) 
        : Colors.transparent;
    
    final repsType = ref.read(exerciseRepsTypeProvider(exerciseNumber));
    print("🔍 repsType: $repsType");
    
    if (repsType == RepsType.range) {
      if (row.isChecked) {
        // ✅ ZAZNACZENIE
        final originalRow = _getOriginalRowData(exerciseNumber, row.colStep);
        if (originalRow != null) {
          print("🔍 ZAZNACZENIE: Oryginalny zakres ${originalRow.colRepMin}-${originalRow.colRepMax}");
          final middleValue = ((originalRow.colRepMin + originalRow.colRepMax) ~/ 2).round();
          row.colRepMin = middleValue;
          row.isUserModified = true;
          print("🔍 ZAZNACZENIE: Ustawiono środkową wartość: $middleValue");
        }
      } else {
        // ✅ ODZNACZENIE - PRZYWRÓĆ ORYGINALNĄ
        final originalRow = _getOriginalRowData(exerciseNumber, row.colStep);
        if (originalRow != null) {
          row.colRepMin = originalRow.colRepMin;
          row.isUserModified = false;
          print("🔍 ODZNACZENIE: Przywrócono oryginalną wartość: ${originalRow.colRepMin}");
        }
      }
    }
  });
  
  print("🔍 PO TOGGLE: isChecked=${row.isChecked}, colRepMin=${row.colRepMin}, colRepMax=${row.colRepMax}");
  _updateRowInProvider(row, exerciseNumber);
  _updateCurrentWorkoutPlan();
}

  void _onKgChanged(ExerciseRow row, String value, String exerciseNumber) {
    setState(() {
      row.colKg = int.tryParse(value) ?? row.colKg;
    });
    _updateRowInProvider(row, exerciseNumber);
  }

  void _onToggleRowFailure(ExerciseRow row, String exerciseNumber) {
    setState(() {
      row.isFailure = !row.isFailure;
    });
    _updateRowInProvider(row, exerciseNumber);
  }

void _onRepChanged(ExerciseRow row, String value, String exerciseNumber) {
  setState(() {
    final repsType = ref.read(exerciseRepsTypeProvider(exerciseNumber));
    
    if (value.isEmpty) {
      // ✅ PUSTE POLE - UŻYTKOWNIK USUNĄŁ WARTOŚĆ
      row.isUserModified = false; // ✅ OZNACZ ŻE BRAK ZMIAN UŻYTKOWNIKA
      
      // ✅ PRZYWRÓĆ ORYGINALNĄ WARTOŚĆ DOLNEJ GRANICY
      final originalRow = _getOriginalRowData(exerciseNumber, row.colStep);
      if (originalRow != null) {
        row.colRepMin = originalRow.colRepMin; // ✅ PRZYWRÓĆ ORYGINALNĄ
        if (repsType == RepsType.single) {
          row.colRepMax = originalRow.colRepMax;
        }
      }
    } else {
      // ✅ WPROWADZONA LICZBA - OZNACZ MODYFIKACJĘ
      row.isUserModified = true; // ✅ UŻYTKOWNIK WPROWADZIŁ ZMIANY
      final newValue = int.tryParse(value) ?? 0;
      row.colRepMin = newValue;
      
      if (repsType == RepsType.single) {
        row.colRepMax = newValue;
      }
      // ✅ DLA RANGE - colRepMax POZOSTAJE BEZ ZMIAN
    }
  });
  _updateRowInProvider(row, exerciseNumber);
}

  void _updateRowInProvider(ExerciseRow row, String exerciseNumber) {
    ref.read(workoutPlanStateProvider.notifier).updateRow(
      _workingPlan.id, // ✅ UŻYJ ID KOPII ROBOCZEJ
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

  // ✅ DODAWANIE ĆWICZENIA - DO KOPII ROBOCZEJ
  Future<void> _addExerciseToPlan(Exercise exercise) async {
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
      _workingPlan.rows.add(newRow); // ✅ DODAJ DO KOPII ROBOCZEJ
    });
    
    _updateCurrentWorkoutPlan();
  }

  // ✅ KOŃCZENIE TRENINGU - PRZYWRÓĆ ORYGINAŁ
  void _endWorkout(BuildContext context) {
    // ✅ ZNAJDŹ I ZASTĄP PLAN W PROVIDERZE ORYGINALNYM
    final planIndex = ref.read(exercisePlanProvider).indexWhere(
      (plan) => plan.id == widget.plan.id
    );
    
    if (planIndex != -1) {
      final currentPlans = List<ExerciseTable>.from(ref.read(exercisePlanProvider));
      currentPlans[planIndex] = _createDeepCopyOfPlan(_originalPlan); // ✅ PRZYWRÓĆ ORYGINAŁ
      ref.read(exercisePlanProvider.notifier).state = currentPlans;
    }
    
    _isWorkoutActive = false;
    Navigator.of(context).pop();
  }

  void _removeExerciseFromWorkoutState(String exerciseNumber) {
    ref.read(workoutPlanStateProvider.notifier).removeExercise(_workingPlan.id, exerciseNumber);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ UŻYJ KOPII ROBOCZEJ W BUILD
    final groupedData = ExerciseTableHelpers.groupExercisesByName(
      _workingPlan, // ✅ KOPIA ROBOCZA
      widget.exercises,
    );

    final totalSteps = ExerciseTableHelpers.calculateTotalSteps(_workingPlan);
    final currentStep = ExerciseTableHelpers.calculateCurrentStep(_workingPlan);

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
                child: Column(
                  children: [
                    // ✅ APP BAR - UŻYJ KOPII ROBOCZEJ
                    PlanSelectedAppBar(
                      onBack: () {
                        _saveAllRowsToProvider();
                        Navigator.pop(context);
                      },
                      planName: _workingPlan.exercise_table, // ✅ KOPIA ROBOCZA
                      getTime: (ctx) {
                        final workoutState = ref.watch(workoutProvider.notifier);
                        return workoutState.currentTime.toString();
                      },
                      getCurrentStep: () => currentStep,
                      onSavePlan: _savePlan,
                    ),
                    
                    const SizedBox(height: 10),
                    _buildProgressBar(totalSteps, currentStep),
                    const SizedBox(height: 16),
                    
                    // ✅ EXERCISE CARDS - UŻYJ KOPII ROBOCZEJ
                    Expanded(
                      child: ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        children: [
                          ..._buildExerciseCards(groupedData),
                          const SizedBox(height: 24),
                          _buildActionButtons(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildDrawerButton(),
          ],
        ),
      ),
    );
  }

  void _savePlan() {
    final timerController = ref.read(workoutProvider.notifier);
    final startHour = timerController.startHour ?? 0;
    final startMinute = timerController.startMinute ?? 0;

    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => SaveWorkout(
        allTime: timerController.currentTime,
        allReps: calculateTotalReps(_workingPlan), // ✅ KOPIA ROBOCZA
        allWeight: calculateTotalVolume(_workingPlan), // ✅ KOPIA ROBOCZA
        startHour: startHour,
        startMinute: startMinute,
        planName: _workingPlan.exercise_table, // ✅ KOPIA ROBOCZA
        onEndWorkout: () => _endWorkout(context),
      ),
    ));
  }

  Widget _buildProgressBar(int totalSteps, int currentStep) {
    return LinearProgressIndicator(
      minHeight: 8,
      value: totalSteps > 0 ? currentStep / totalSteps : 0,
      backgroundColor: Colors.red,
      valueColor: AlwaysStoppedAnimation<Color>(
        Theme.of(context).colorScheme.primary.withOpacity(0.2),
      ),
    );
  }

  List<Widget> _buildExerciseCards(Map<String, List<ExerciseRowsData>> groupedData) {
 // final originalRanges = _getOriginalRanges(); 
    return groupedData.entries.map((entry) {
      final exerciseName = entry.key;
      final exerciseRows = entry.value;
      final firstRow = exerciseRows.first;

      final matchingExercise = widget.exercises.firstWhere(
        (ex) => ex.id == firstRow.exercise_number, // ✅ POPRAWIONA LOGIKA
        orElse: () => Exercise(
          exerciseId: firstRow.exercise_number,
          name: exerciseName,
          bodyParts: [],
          equipments: [],
          gifUrl: '',
          targetMuscles: [],
          secondaryMuscles: [],
          instructions: [], 
          //id: '',
        ),
      );

      return PlanSelectedCard(
        exerciseId: firstRow.exercise_number,
        exerciseName: exerciseName,
        headerCellTextStep: ExerciseTableHelpers.buildHeaderCell(context, "Step"),
        headerCellTextKg: ExerciseTableHelpers.buildHeaderCell(context, "Weight"),
        headerCellTextReps: ExerciseTableHelpers.buildHeaderCell(context, "Reps"),
        notes: firstRow.notes,
    exerciseRows: ExerciseTableHelpers.buildExerciseTableRows(
            exerciseRows,
            context,
            onKgChanged: (row, value, exerciseNumber) => _onKgChanged(row, value, exerciseNumber),
            onRepChanged: (row, value, exerciseNumber) => _onRepChanged(row, value, exerciseNumber),
            onToggleChecked: (row, exerciseNumber) => _onToggleRowChecked(row, exerciseNumber),
            onToggleFailure: (row, exerciseNumber) => _onToggleRowFailure(row, exerciseNumber),
            ref: ref, // ✅ DODAJ REF
           getOriginalRange: _getOriginalRange, // ✅ PRZEKAŻ ORYGINALNE ZAKRESY
          ),
        onNotesChanged: (value) {
          setState(() {
            final updatedRow = ExerciseRowsData(
              rep_type:  RepsType.single, // Placeholder, adjust as needed
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
        deleteExerciseCard: () => _deleteExerciseFromPlan(firstRow.exercise_number),
      );
    }).toList();
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // ✅ ADD EXERCISE BUTTON
        ElevatedButton.icon(
          onPressed: () async {
            final newExercise = await Navigator.of(context).push<Exercise>(
              MaterialPageRoute(
                builder: (ctx) => ExercisesScreen(
                  isSelectionMode: true,
                  title: 'Select Exercise for Plan',
                ),
              ),
            );

            if (newExercise != null) {
              await _addExerciseToPlan(newExercise);
            }
          },
          icon: const Icon(Icons.add),
          label: const Text("Add Exercise"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // ✅ END WORKOUT BUTTON
        ElevatedButton(
          onPressed: () => _endWorkout(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          child: const Text("End Workout"),
        ),
      ],
    );
  }

  Widget _buildDrawerButton() {
    return Positioned(
      left: 0,
      top: MediaQuery.of(context).size.height / 2 - 24,
      child: GestureDetector(
        onTap: () => _scaffoldKey.currentState?.openDrawer(),
        child: Container(
          width: 32,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(24),
            ),
          ),
          child: const Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }

  void _openInfoExercise(Exercise exercise) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ExerciseInfoScreen(exercise: exercise),
      ),
    );
  }
}


