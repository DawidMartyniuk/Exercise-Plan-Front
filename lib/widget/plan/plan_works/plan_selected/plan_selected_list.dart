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
import 'package:work_plan_front/widget/plan/plan_works/plan_selected/widget/progress_bar.dart';
import '../helpers/plan_helpers.dart';
import '../helpers/exercise_calculator.dart';
import '../helpers/exercise_table_helpers.dart';
import 'plan_selected_card.dart';
import 'plan_selected_appBar.dart';
import 'plan_selected_details.dart';
 // TODO: Powrucić do konceptu początkowego czyli wartoiści na początku są w hint potem po zaznaczeniu stają się widoczne 
 // i zawsze możan je usuwac do " "  i zmineiac
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
  
  ScrollController? _scrollController;
  Timer? _timer;

  late ExerciseTable _originalPlan; // 
  late ExerciseTable _workingPlan;  //  KOPIA ROBOCZA - na tej pracujemy
  bool _isWorkoutActive = false;
  WorkoutTimeNotifier _workoutTimeNotifier = WorkoutTimeNotifier();


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    //  ZACHOWAJ ORYGINAŁ
    _originalPlan = _createDeepCopyOfPlan(widget.plan);
    
    //  STWÓRZ KOPIĘ ROBOCZĄ
    _workingPlan = _createDeepCopyOfPlan(widget.plan);
    startTimer();
    
    _initializePlanData();
  }

  void startTimer(){
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

  // void startWorkout(){
  //   if(_isWorkoutActive){
  //     _workoutTimeNotifier.startTimer();
  //     _isWorkoutActive = true;
  //   }
  // }
  @override
void dispose() {
  print("🗑️ Disposing PlanSelectedList");
  

  // if (widget.isWorkoutMode && _isWorkoutActive) {
  //   ref.read(workoutProvider.notifier).stopTimer();
  // }
  
  _timer?.cancel();
  _scrollController?.dispose();
  super.dispose();
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

  for (final exerciseData in _workingPlan.rows) {
    print("🔍 Ćwiczenie: ${exerciseData.exercise_name}");
    
    for (final row in exerciseData.data) {
      print("🔍 Seria ${row.colStep}: colKg=${row.colKg}, colRepMin=${row.colRepMin}");
      
      // ✅ JEŚLI WAGA JEST 0 - USTAW WARTOŚĆ DOMYŚLNĄ
      if (row.colKg == 0) {
        row.colKg = 20; // PRZYKŁADOWA WARTOŚĆ
        print("🔍 Ustawiono domyślną wagę: ${row.colKg}");
      }
    }
  }
  
  print("🔍 _initializePlanData: planId=$planId, savedRows.length=${savedRows.length}");
  
  //  OPÓŹNIJ MODYFIKACJĘ PROVIDERA
  Future(() {
    //  USTAW POPRAWNY REPS TYPE PO ZBUDOWANIU WIDGETU
    for (final rowData in _workingPlan.rows) {
      //  SPRAWDŹ CZY TO ZAKRES I USTAW ODPOWIEDNI TYP
      final hasRange = rowData.data.any((row) => 
        row.colRepMin > 0 && row.colRepMax > 0 && row.colRepMin != row.colRepMax
      );
      
      if (hasRange) {
        //  USTAW RANGE TYPE W PROVIDERZE (OPÓŹNIONE)
        ref.read(exerciseRepsTypeProvider(rowData.exercise_number).notifier).state = RepsType.range;
        print("✅ Ustawiono RepsType.range dla ${rowData.exercise_number}");
      } else {
        ref.read(exerciseRepsTypeProvider(rowData.exercise_number).notifier).state = RepsType.single;
        print(" Ustawiono RepsType.single dla ${rowData.exercise_number}");
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
Future<void> _addMultipleExercisesToPlan() async {
  final result = await Navigator.of(context).push<dynamic>(
    MaterialPageRoute(
      builder: (ctx) => ExercisesScreen(
        isSelectionMode: true,
        title: 'Select Exercises for Plan',
        onMultipleExercisesSelected: (exercises) {
          print('🔧 Callback wywołany z ${exercises.length} ćwiczeniami');
        },
      ),
    ),
  );

  print('🔧 Navigator.pop zwrócił: $result (typ: ${result.runtimeType})');

  //  OBSŁUGA REZULTATU BEZ ASYNC W setState
  if (result != null) {
    if (result is List<Exercise>) {
      //  LISTA ĆWICZEŃ - DODAJ WSZYSTKIE SYNCHRONICZNIE
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
      
      //  AKTUALIZUJ PROVIDER PO setState
      _updateCurrentWorkoutPlan();
      
      //  POKAŻ TOAST
      if (addedCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $addedCount exercise${addedCount > 1 ? 's' : ''} to plan'),
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
      // POJEDYNCZE ĆWICZENIE - DODAJ SYNCHRONICZNIE
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
        
        // AKTUALIZUJ PROVIDER PO setState
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
  //  ZNAJDŹ ORYGINALNĄ WARTOŚĆ Z _originalPlan
  for (final rowData in _originalPlan.rows) {
    if (rowData.exercise_number == exerciseNumber) {
      for (final row in rowData.data) {
        if (row.colStep == colStep) {
          return row; // ZWRÓĆ ORYGINALNY WIERSZ
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


  //  METODA USUWANIA - TYLKO Z KOPII ROBOCZEJ
  void _deleteExerciseFromPlan(String exerciseNumber) {
    setState(() {
      //  USUŃ Z KOPII ROBOCZEJ, NIE Z ORYGINAŁU
      _workingPlan.rows.removeWhere((rowData) => 
          rowData.exercise_number == exerciseNumber);
    });
    _updateCurrentWorkoutPlan();
    _removeExerciseFromWorkoutState(exerciseNumber);
  }

  //  AKTUALIZUJ WORKOUT PLAN - UŻYJ KOPII ROBOCZEJ
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

  //  ZAPISZ DANE Z KOPII ROBOCZEJ
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


  //  ROW INTERACTIONS - PRACUJ NA KOPII ROBOCZEJ
void _onToggleRowChecked(ExerciseRow row, String exerciseNumber) {
  print("🔍 PRZED TOGGLE: isChecked=${row.isChecked}, colRepMin=${row.colRepMin}, isUserModified=${row.isUserModified}");
  
  setState(() {
    row.isChecked = !row.isChecked;
    row.rowColor = row.isChecked 
        ? const Color.fromARGB(255, 103, 189, 106) 
        : Colors.transparent;
    
    final repsType = ref.read(exerciseRepsTypeProvider(exerciseNumber));
    print("🔍 repsType: $repsType");
    
    // ✅ TYLKO DLA RANGE I TYLKO JEŚLI UŻYTKOWNIK NIE WPROWADZIŁ WŁASNEJ WARTOŚCI
    if (repsType == RepsType.range && !row.isUserModified) {
      if (row.isChecked) {
        // ✅ ZAZNACZENIE - USTAW ŚREDNIĄ TYLKO JEŚLI BRAK MODYFIKACJI
        final originalRow = _getOriginalRowData(exerciseNumber, row.colStep);
        if (originalRow != null) {
          print("🔍 ZAZNACZENIE: Oryginalny zakres ${originalRow.colRepMin}-${originalRow.colRepMax}");
          final middleValue = ((originalRow.colRepMin + originalRow.colRepMax) ~/ 2).round();
          row.colRepMin = middleValue;
          row.isUserModified = true; // ✅ OZNACZ ŻE TERAZ MA WARTOŚĆ
          print("🔍 ZAZNACZENIE: Ustawiono środkową wartość: $middleValue");
        }
      }
      // ✅ ODZNACZENIE - NIE RÓB NIC, ZOSTAW WARTOŚĆ UŻYTKOWNIKA
    }
    
    // ✅ JEŚLI UŻYTKOWNIK WPROWADZIŁ WŁASNĄ WARTOŚĆ - NIE ZMIENIAJ JEJ
    if (row.isUserModified) {
      print("🔍 TOGGLE: Zachowuję wartość użytkownika: ${row.colRepMin}");
    }
  });
  
  print("🔍 PO TOGGLE: isChecked=${row.isChecked}, colRepMin=${row.colRepMin}, isUserModified=${row.isUserModified}");
  _updateRowInProvider(row, exerciseNumber);
  _updateCurrentWorkoutPlan();
}

void _onKgChanged(ExerciseRow row, String value, String exerciseNumber) {
  print("🏋️ _onKgChanged: value='$value', exerciseNumber=$exerciseNumber");
  print("🏋️ PRZED: colKg=${row.colKg}");
  
  setState(() {
    if (value.isEmpty) {
      // ✅ PUSTE POLE - USTAW 0
      row.colKg = 0;
      print("🏋️ PUSTE POLE: Ustawiono 0");
    } else {
      // ✅ WPROWADZONA WARTOŚĆ
      final newValue = double.tryParse(value) ?? 0;
      if (newValue >= 0) { // ✅ POZWÓL NA 0
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

  void _onToggleRowFailure(ExerciseRow row, String exerciseNumber) {
    setState(() {
      row.isFailure = !row.isFailure;
    });
    _updateRowInProvider(row, exerciseNumber);
  }

void _onRepChanged(ExerciseRow row, String value, String exerciseNumber) {
  print("🔍 _onRepChanged: value='$value', exerciseNumber=$exerciseNumber");
  print("🔍 _onRepChanged PRZED: colRepMin=${row.colRepMin}, isUserModified=${row.isUserModified}");
  
  setState(() {
    final repsType = ref.read(exerciseRepsTypeProvider(exerciseNumber));
    
    if (value.isEmpty) {
      // ✅ PUSTE POLE - OZNACZ ŻE UŻYTKOWNIK USUNĄŁ WARTOŚĆ
      row.isUserModified = false;
      
      // ✅ PRZYWRÓĆ ORYGINALNĄ TYLKO JEŚLI JEST DOSTĘPNA
      final originalRow = _getOriginalRowData(exerciseNumber, row.colStep);
      if (originalRow != null) {
        row.colRepMin = originalRow.colRepMin;
        if (repsType == RepsType.single) {
          row.colRepMax = originalRow.colRepMax;
        }
        print("🔍 PUSTE POLE: Przywrócono oryginalną wartość: ${originalRow.colRepMin}");
      } else {
        // ✅ BRAK ORYGINALNYCH DANYCH - ZOSTAW OBECNĄ WARTOŚĆ
        print("🔍 PUSTE POLE: Brak oryginalnych danych - pozostawiam obecną");
      }
    } else {
      // ✅ WPROWADZONA WARTOŚĆ - ZAWSZE USTAW I OZNACZ JAKO MODYFIKACJĘ
      final newValue = int.tryParse(value) ?? 0;
      if (newValue >= 0) { // ✅ POZWÓL NA 0
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
  
  print("🔍 _onRepChanged PO: colRepMin=${row.colRepMin}, isUserModified=${row.isUserModified}");
  _updateRowInProvider(row, exerciseNumber);
}
  void _updateRowInProvider(ExerciseRow row, String exerciseNumber) {
    ref.read(workoutPlanStateProvider.notifier).updateRow(
      _workingPlan.id, //  UŻYJ ID KOPII ROBOCZEJ
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
  // Future<void> _addExerciseToPlan(Exercise exercise) async {
  //   setState(() {
  //     final newRow = ExerciseRowsData(
  //       exercise_number: exercise.id,
  //       exercise_name: exercise.name,
  //       notes: '',
  //       rep_type: RepsType.single,
  //       data: [
  //         ExerciseRow(
  //           colStep: 1,
  //           colKg: 0,
  //           colRepMin: 0,
  //           colRepMax: 0,
  //           isChecked: false,
  //           isFailure: false,
  //           rowColor: Colors.transparent,
  //           isUserModified: false,
  //         ),
  //       ],
  //     );
  //     _workingPlan.rows.add(newRow); // ✅ DODAJ DO KOPII ROBOCZEJ
  //   });
    
  //   _updateCurrentWorkoutPlan();
  // }
  void _goEditPlan(){
    print('Edytuj plan');
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

  //  KOŃCZENIE TRENINGU - PRZYWRÓĆ ORYGINAŁ
  void _endWorkout(BuildContext context) {
    //  ZNAJDŹ I ZASTĄP PLAN W PROVIDERZE ORYGINALNYM
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
    //  UŻYJ KOPII ROBOCZEJ W BUILD
    final groupedData = ExerciseTableHelpers.groupExercisesByName(
      _workingPlan, // ✅ KOPIA ROBOCZA
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
        
       // bottomNavigationBar: widget.isWorkoutMode 
          // ? BottomButtonAppBar(
          //     onBack: () {
          //       print("🔄 Bottom bar - powrót z treningu");
          //       if (!widget.isReadOnly) {
          //         _saveAllRowsToProvider();
          //       }
          //       // ✅ ZATRZYMAJ TIMER PRZED WYJŚCIEM
          //       if (_isWorkoutActive) {
          //         ref.read(workoutProvider.notifier).stopTimer();
          //       }
          //       Navigator.pop(context);
          //     },
          //     onEnd: () {
          //       print("🛑 Bottom bar - koniec treningu");
          //       _endWorkout(context);
          //     },
          //   )
          // : null, // 
        body: Stack(
          children: [
            SafeArea(
              
              
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    //  APP BAR - UŻYJ KOPII ROBOCZEJ
                    PlanSelectedAppBar(
                      onBack: () {
                      // ✅ ZAWSZE ZAPISZ DANE
                      _saveAllRowsToProvider();
                      
                      if (widget.isWorkoutMode && _isWorkoutActive) {
                        // ✅ W TRYBIE TRENINGU - USTAW GLOBALNY STAN, NIE ZATRZYMUJ TIMER
                        print("🔽 Minimalizowanie treningu - timer pozostaje aktywny globalnie");
                        
                        // ✅ USTAW GLOBALNY STAN TRENINGU
                        ref.read(currentWorkoutPlanProvider.notifier).state = Currentworkout(
                          plan: _workingPlan,
                          exercises: widget.exercises,
                        );
                        
                        // ✅ NIE ZATRZYMUJ TIMERA - ZOSTAW GO AKTYWNEGO
                        // ❌ USUŃ TO: ref.read(workoutProvider.notifier).stopTimer();
                      }
                      
                      // ✅ NAVIGATOR.POP ZOSTANIE WYWOŁANE W hidingScreen
                    },
                      planName: _workingPlan.exercise_table, // ✅ KOPIA ROBOCZA
                      getTime: (ctx) {
                        if (widget.isWorkoutMode && _isWorkoutActive) {
                          
                          final currentTime = ref.watch(workoutProvider);
                          final minutes = currentTime ~/ 60;
                          final seconds = currentTime % 60;
                          return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
                        }
                        return "00:00";
                      },
                      getCurrentStep: () => currentStep,
                      onSavePlan: _savePlan,
                      isReadOnly: widget.isReadOnly,
                      isWorkoutMode: widget.isWorkoutMode,
                      onEditPlan: _goEditPlan,
                    ),
                    
                    const SizedBox(height: 10),
                   // _buildProgressBar(totalSteps, currentStep),
                   ProgressBar(
                     totalSteps: totalSteps,
                     currentStep: currentStep,
                     isReadOnly: widget.isReadOnly,
                   ),

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
           // _buildDrawerButton(),
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
        allReps: calculateTotalReps(_workingPlan), //  KOPIA ROBOCZA
        allWeight: calculateTotalVolume(_workingPlan), //  KOPIA ROBOCZA
        startHour: startHour,
        startMinute: startMinute,
        planName: _workingPlan.exercise_table, //  KOPIA ROBOCZA
        onEndWorkout: () => _endWorkout(context),
      ),
    ));
  }

  // Widget _buildProgressBar(int totalSteps, int currentStep) {
  //   return widget.isReadOnly ? Container() : LinearProgressIndicator(
  //     minHeight: 8,
  //     value: totalSteps > 0 ? currentStep / totalSteps : 0,
  //     backgroundColor: Colors.red,
  //     valueColor: AlwaysStoppedAnimation<Color>(
  //       Theme.of(context).colorScheme.primary.withOpacity(0.2),
  //     ),
  //   );
  // }

  List<Widget> _buildExerciseCards(Map<String, List<ExerciseRowsData>> groupedData) {
 // final originalRanges = _getOriginalRanges(); 
    return groupedData.entries.map((entry) {
      final exerciseName = entry.key;
      final exerciseRows = entry.value;
      final firstRow = exerciseRows.first;

      final matchingExercise = widget.exercises.firstWhere(
        (ex) => ex.id == firstRow.exercise_number, // POPRAWIONA LOGIKA
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
        isReadOnly: widget.isReadOnly,
    exerciseRows: ExerciseTableHelpers.buildExerciseTableRows(
            exerciseRows,
            context,
            onKgChanged: (row, value, exerciseNumber) => _onKgChanged(row, value, exerciseNumber),
            onRepChanged: (row, value, exerciseNumber) => _onRepChanged(row, value, exerciseNumber),
            onToggleChecked: (row, exerciseNumber) => _onToggleRowChecked(row, exerciseNumber),
            onToggleFailure: (row, exerciseNumber) => _onToggleRowFailure(row, exerciseNumber),
            ref: ref, //  DODAJ REF
           getOriginalRange: _getOriginalRange, // PRZEKAŻ ORYGINALNE ZAKRESY
          isReadOnly: widget.isReadOnly,
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

  void _openInfoExercise(Exercise exercise) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseInfoScreen(exercise: exercise),
      ),
    );
  }

  Widget _buildActionButtons() {
  if (widget.isReadOnly && !widget.isWorkoutMode) {
    // TRYB PODGLĄDU - TYLKO PRZYCISK STARTU TRENINGU
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => PlanSelectedList(
                    plan: widget.plan,
                    exercises: widget.exercises,
                    isReadOnly: false,
                    isWorkoutMode: true,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.fitness_center),
            label: const Text("Start Workout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  } else if (widget.isWorkoutMode) {
    //  TRYB TRENINGU - WSZYSTKIE PRZYCISKI TRENINGOWE
    return Column(
      children: [
        //  POJEDYNCZY PRZYCISK DODAWANIA ĆWICZEŃ
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _addMultipleExercisesToPlan, //  UŻYJ METODY MULTI-SELECT
            icon: const Icon(Icons.add),
            label: const Text("Add Exercises"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
         
        //  PRZYCISK ZAKOŃCZ TRENING
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _endWorkout(context),
            icon: const Icon(Icons.stop),
            label: const Text("End Workout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  } else {
    //  TRYB EDYCJI PLANU - PRZYCISKI EDYCYJNE
    return Column(
      children: [
        //  POJEDYNCZY PRZYCISK DODAWANIA ĆWICZEŃ
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _addMultipleExercisesToPlan, //  UŻYJ METODY MULTI-SELECT
            icon: const Icon(Icons.add),
            label: const Text("Add Exercises"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        //  START WORKOUT
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => PlanSelectedList(
                    plan: widget.plan,
                    exercises: widget.exercises,
                    isReadOnly: false,
                    isWorkoutMode: true,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.fitness_center),
            label: const Text("Start Workout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
    }



