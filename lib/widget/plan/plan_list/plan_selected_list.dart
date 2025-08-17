import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/CurrentWorkout.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/provider/ExercisePlanNotifier.dart';
import 'package:work_plan_front/provider/current_workout_plan_provider.dart';
import 'package:work_plan_front/provider/wordoutTimeNotifer.dart';
import 'package:work_plan_front/screens/exercise_info.dart';
import 'package:work_plan_front/provider/workout_plan_state_provider.dart';
import 'package:work_plan_front/screens/exercises.dart';
import 'package:work_plan_front/screens/save_workout/save_workout.dart';
import 'package:work_plan_front/utils/workout_utils.dart';
import 'helpers/plan_helpers.dart';
import 'helpers/exercise_calculator.dart';
import 'components/plan_stats.dart';
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
  ConsumerState<ConsumerStatefulWidget> createState() => _PlanSelectedListState();
}

class _PlanSelectedListState extends ConsumerState<PlanSelectedList> 
    with PlanHelpers, ExerciseCalculations {
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController? _scrollController;
  Timer? _timer;

  late ExerciseTable _originalPlan;
  late List<Exercise> _originalExercises;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _originalPlan = _deepCopyPlan(widget.plan);
    _originalExercises = List<Exercise>.from(widget.exercises);
    _initializePlanData();
  }

  void _initializePlanData() {
    final planId = widget.plan.id;
    final savedRows = ref.read(workoutPlanStateProvider).getRows(planId);
    
    if (savedRows.isNotEmpty) {
      _applyUserProgress(savedRows);
    }
  }
   ExerciseTable _deepCopyPlan(ExerciseTable plan) {
    final copiedRows = plan.rows.map((rowData) {
      final copiedData = rowData.data.map((row) => ExerciseRow(
        colStep: row.colStep,
        colKg: row.colKg,
        colRep: row.colRep,
        isChecked: false, // ✅ RESETUJ STATUS
        isFailure: false, // ✅ RESETUJ STATUS
        rowColor: Colors.transparent,
      )).toList();
      
      return ExerciseRowsData(
        exercise_number: rowData.exercise_number,
        exercise_name: rowData.exercise_name,
        data: copiedData,
        notes: rowData.notes,
      );
    }).toList();
    
    return ExerciseTable(
      id: plan.id,
      exercise_table: plan.exercise_table,
      rows: copiedRows,
    );
  }

  void _applyUserProgress(List<ExerciseRowState> savedRows) {
    for (final rowData in widget.plan.rows) {
      for (final row in rowData.data) {
        final match = savedRows.firstWhere(
          (e) => e.colStep == row.colStep && e.exerciseNumber == rowData.exercise_number,
          orElse: () => ExerciseRowState(
            colStep: row.colStep,
            colKg: row.colKg,
            colRep: row.colRep,
            isChecked: row.isChecked,
            isFailure: row.isFailure,
            exerciseNumber: rowData.exercise_number,
          ),
        );
        
        row.colKg = match.colKg;
        row.colRep = match.colRep;
        row.isChecked = match.isChecked;
        row.isFailure = match.isFailure;
        row.rowColor = row.isChecked ? Colors.green : Colors.transparent;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController?.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  // ✅ EXERCISE INTERACTIONS
  void _openInfoExercise(Exercise exercise) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => ExerciseInfoScreen(exercise: exercise),
    );
  }

  // ✅ ROW INTERACTIONS
  void _onToggleRowChecked(ExerciseRow row, String exerciseNumber) {
    setState(() {
      row.isChecked = !row.isChecked;
      row.rowColor = row.isChecked 
          ? const Color.fromARGB(255, 103, 189, 106) 
          : Colors.transparent;
    });
    _updateRowInProvider(row, exerciseNumber);
    _updateCurrentWorkoutPlan();
  }

  void _onToggleRowFailure(ExerciseRow row, String exerciseNumber) {
    if (!row.isChecked) return;
    
    setState(() {
      row.isFailure = !row.isFailure;
      row.rowColor = row.isFailure 
          ? const Color.fromARGB(255, 12, 107, 15)
          : const Color.fromARGB(255, 103, 189, 106);
    });
    _updateRowInProvider(row, exerciseNumber);
  }

  void _onKgChanged(ExerciseRow row, String value, String exerciseNumber) {
    setState(() {
      row.colKg = int.tryParse(value) ?? row.colKg;
    });
    _updateRowInProvider(row, exerciseNumber);
  }

  void _onRepChanged(ExerciseRow row, String value, String exerciseNumber) {
    setState(() {
      row.colRep = int.tryParse(value) ?? row.colRep;
    });
    _updateRowInProvider(row, exerciseNumber);
  }

  void _updateRowInProvider(ExerciseRow row, String exerciseNumber) {
    ref.read(workoutPlanStateProvider.notifier).updateRow(
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

  void _updateCurrentWorkoutPlan() {
    final newRows = widget.plan.rows.map((rowData) => 
      rowData.copyWithData(
        rowData.data.map((row) => ExerciseRow(
          colStep: row.colStep,
          colKg: row.colKg,
          colRep: row.colRep,
          isChecked: row.isChecked,
          isFailure: row.isFailure,
          rowColor: row.rowColor,
        )).toList(),
      )
    ).toList();

    final newPlan = widget.plan.copyWithRows(newRows);
    ref.read(currentWorkoutPlanProvider.notifier).state = Currentworkout(
      plan: newPlan,
      exercises: widget.exercises,
    );
  }

  // ✅ PLAN MANAGEMENT
  void _saveAllRowsToProvider() {
    final planId = widget.plan.id;
    final rowStates = <ExerciseRowState>[];
    
    for (final rowData in widget.plan.rows) {
      for (final row in rowData.data) {
        rowStates.add(ExerciseRowState(
          colStep: row.colStep,
          colKg: row.colKg,
          colRep: row.colRep,
          isChecked: row.isChecked,
          isFailure: row.isFailure,
          exerciseNumber: rowData.exercise_number,
        ));
      }
    }
    
    ref.read(workoutPlanStateProvider.notifier).setPlanRows(planId, rowStates);
  }

  void _savePlan() {
    final timerController = ref.read(workoutProvider.notifier);
    final startHour = timerController.startHour ?? 0;
    final startMinute = timerController.startMinute ?? 0;

    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => SaveWorkout(
        allTime: timerController.currentTime,
        allReps: calculateTotalReps(widget.plan),
        allWeight: calculateTotalVolume(widget.plan),
        startHour: startHour,
        startMinute: startMinute,
        planName: widget.plan.exercise_table,
        onEndWorkout: () => _endWorkout(context),
      ),
    ));
  }

  void _endWorkout(BuildContext context) {
    // ✅ PRZYWRÓĆ ORYGINALNY PLAN
    _restoreOriginalPlan();
    
    final currentWorkout = ref.read(currentWorkoutPlanProvider);
    if (currentWorkout?.plan != null) {
      ref.read(exercisePlanProvider.notifier).resetPlanById(currentWorkout!.plan!.id);
      resetPlanRows(currentWorkout.plan!);
    }
    
    endWorkoutGlobal(context: context, ref: ref);
    Navigator.of(context).pop();
  }
   void _deleteExerciseFromPlan(String exerciseNumber){
    setState(() {
      widget.plan.rows.removeWhere((rowData) =>
       rowData.exercise_number == exerciseNumber);

         print("🗑️ Usunięto ćwiczenie o numerze: $exerciseNumber z planu");
    });
    _updateCurrentWorkoutPlan();

     _removeExerciseFromWorkoutState(exerciseNumber);

      if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Exercise removed from current workout"),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  };
  }
  void _removeExerciseFromWorkoutState(String exerciseNumber){
    final planId = widget.plan.id;
    final currentRows = ref.read(workoutPlanStateProvider).getRows(planId);

    final filteredRows = currentRows.where((row)=>
    row.exerciseNumber != exerciseNumber).toList();

    ref.read(workoutPlanStateProvider.notifier).setPlanRows(planId, filteredRows);
  }

  void _restoreOriginalPlan() {
    try {
      // ✅ PRZYWRÓĆ ORYGINALNY STAN PLANU W PROVIDERZE
      final planIndex = ref.read(exercisePlanProvider).indexWhere(
        (plan) => plan.id == widget.plan.id
      );
      
      if (planIndex != -1) {
        // ✅ ZASTĄP BIEŻĄCY PLAN ORYGINALNYM
        final currentPlans = List<ExerciseTable>.from(ref.read(exercisePlanProvider));
        currentPlans[planIndex] = _originalPlan;
        
        // ✅ ZAKTUALIZUJ PROVIDER
        ref.read(exercisePlanProvider.notifier).state = currentPlans;
        
        print("✅ Przywrócono oryginalny plan: ${_originalPlan.exercise_table}");
        print("✅ Oryginalny plan ma ${_originalPlan.rows.length} ćwiczeń");
        print("✅ Tymczasowy plan miał ${widget.plan.rows.length} ćwiczeń");
      }
      
      // ✅ WYCZYŚĆ WORKOUT STATE
      ref.read(workoutPlanStateProvider.notifier).clearPlan(widget.plan.id);
      
    } catch (e) {
      print("❌ Błąd przywracania oryginalnego planu: $e");
    }
  }

  // ✅ TIME FORMATTING
  String getTime(BuildContext context) {
    final timerController = ref.watch(workoutProvider.notifier);
    final time = timerController.currentTime;
    final duration = Duration(seconds: time);

    return formatDuration(duration);
  }

  Future<void> _addExerciseToPlan(Exercise exercise) async {
  setState(() {
    // ✅ UTWÓRZ NOWY WIERSZ ĆWICZENIA Z DOMYŚLNYMI SERIAMI
    final newExerciseRow = ExerciseRowsData(
      exercise_number: exercise.exerciseId.isNotEmpty ? exercise.exerciseId : exercise.id,
      exercise_name: exercise.name,
      data: [
        // ✅ DODAJ 3 DOMYŚLNE SERIE
        ExerciseRow(
          colStep: 1,
          colKg: 0,
          colRep: 0,
          isChecked: false,
          isFailure: false,
          rowColor: Colors.transparent,
        ),
      ],
      notes: "",
    );
    
    // ✅ DODAJ DO PLANU
    widget.plan.rows.add(newExerciseRow);
    
    // ✅ DODAJ ĆWICZENIE DO LISTY ĆWICZEŃ (jeśli nie istnieje)
    final exerciseExists = widget.exercises.any((ex) => 
        ex.exerciseId == exercise.exerciseId || ex.id == exercise.id);
    
    if (!exerciseExists) {
      widget.exercises.add(exercise);
    }
  });
  
  // ✅ ZAKTUALIZUJ CURRENT WORKOUT PLAN
  _updateCurrentWorkoutPlan();

  
  print("✅ Dodano ćwiczenie: ${exercise.name} do planu");
}

  @override
  Widget build(BuildContext context) {
    final groupedData = ExerciseTableHelpers.groupExercisesByName(
      widget.plan,
      widget.exercises,
    );

    final totalSteps = ExerciseTableHelpers.calculateTotalSteps(widget.plan);
    final currentStep = ExerciseTableHelpers.calculateCurrentStep(widget.plan);

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
                    // ✅ APP BAR
                    PlanSelectedAppBar(
                      onBack: () {
                        _saveAllRowsToProvider();
                        Navigator.pop(context);
                      },
                      planName: widget.plan.exercise_table,
                      getTime: getTime,
                      getCurrentStep: () => currentStep,
                      onSavePlan: _savePlan,
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // ✅ PROGRESS BAR
                    _buildProgressBar(totalSteps, currentStep),
                    
                    const SizedBox(height: 16),
                    
                    // ✅ STATS
                    //PlanStats(plan: widget.plan, isCompact: true),
                    
                    const SizedBox(height: 16),
                    
                    // ✅ EXERCISE CARDS
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
            
            // ✅ DRAWER BUTTON
            _buildDrawerButton(),
          ],
        ),
      ),
    );
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
  return groupedData.entries.map((entry) {
    final exerciseName = entry.key;
    final exerciseRows = entry.value;
    final firstRow = exerciseRows.first;

    final matchingExercise = widget.exercises.firstWhere(
      (ex) => int.tryParse(ex.id) == int.tryParse(firstRow.exercise_number),
      orElse: () => Exercise(
        exerciseId: '',
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
      ),
      onNotesChanged: (value) {
         setState(() {
           // ✅ UTWÓRZ NOWY OBIEKT ZAMIAST UŻYWAĆ copyWith
    final updatedRow = ExerciseRowsData(
      exercise_name: exerciseName,
      exercise_number: firstRow.exercise_number,
      data: firstRow.data,
      notes: value, // ✅ TYLKO NOTES SIĘ ZMIENIA
    );
    
    final index = groupedData[exerciseName]!.indexOf(firstRow);
    if (index != -1) {
      groupedData[exerciseName]![index] = updatedRow;
    }
  });
      },
      onTap: () => _openInfoExercise(matchingExercise), 
      deleteExerciseCard: () =>  _deleteExerciseFromPlan(firstRow.exercise_number),
      // ✅ DODANE
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

            if(newExercise != null) {
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
}


