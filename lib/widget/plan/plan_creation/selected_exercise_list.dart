import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/screens/exercise_info.dart';
import 'package:work_plan_front/widget/plan/plan_creation/widgets/build_sets_table.dart';
import 'package:work_plan_front/widget/plan/plan_list/plan_selected/components/exercise_image.dart';
import 'package:work_plan_front/widget/plan/plan_creation/helpers/selected_exercise_data_manager.dart';
import 'package:work_plan_front/widget/plan/plan_creation/helpers/exercise_replacement_manager.dart';

class SelectedExerciseList extends StatefulWidget {
  final List<Exercise> exercises;
  final void Function(Exercise exercise) onDelete;
  final void Function(Map<String, List<Map<String, String>>> Function()) onGetTableData;
  final void Function(List<Exercise>)? onExercisesReordered;
  final void Function(Exercise oldExercise, Map<String, dynamic> savedData)? onReplaceExercise;

  const SelectedExerciseList({
    Key? key,
    required this.exercises,
    required this.onDelete,
    required this.onGetTableData,
    this.onExercisesReordered,
    this.onReplaceExercise,
  }) : super(key: key);

  @override
  State<SelectedExerciseList> createState() => SelectedExerciseListState();
}

class SelectedExerciseListState extends State<SelectedExerciseList> {
  late SelectedExerciseDataManager _dataManager;
  late ExerciseReplacementManager _replacementManager;
  List<Exercise> _reorderedExercises = [];

  @override
  void initState() {
    super.initState();
    _dataManager = SelectedExerciseDataManager();
    _replacementManager = ExerciseReplacementManager();
    _reorderedExercises = List.from(widget.exercises);
 
    // Inicjalizuj dane dla wszystkich ćwiczeń
    for (final exercise in widget.exercises) {
      _dataManager.initializeExerciseData(exercise, _updateRowValue);
    }
   
    widget.onGetTableData(() => _dataManager.getTableData(widget.exercises));
  }

  @override
  void didUpdateWidget(SelectedExerciseList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.exercises.length != _reorderedExercises.length ||
        !widget.exercises.every((e) => _reorderedExercises.any((r) => r.id == e.id))) {
      _reorderedExercises = List.from(widget.exercises);
    }
    
    // Inicjalizuj dane dla nowych ćwiczeń
    for (final exercise in widget.exercises) {
      if (!_dataManager.hasExerciseData(exercise.id)) {
        print("🆕 Initializing new exercise: ${exercise.name}");
        _dataManager.initializeExerciseData(exercise, _updateRowValue);
      }
    }
    
    widget.onGetTableData(() => _dataManager.getTableData(widget.exercises));
  }

  void _reorderExercises(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final exercise = _reorderedExercises.removeAt(oldIndex);
      _reorderedExercises.insert(newIndex, exercise);
    });
    widget.onExercisesReordered?.call(_reorderedExercises);
  }

  void _addRow(String exerciseId, String exerciseName) {
    setState(() {
      _dataManager.addRow(exerciseId, exerciseName, widget.exercises, _updateRowValue);
    });
  }

  void _removeRow(String exerciseId, int index) {
    setState(() {
      _dataManager.removeRow(exerciseId, index);
    });
  }

  void _openInfoExercise(Exercise exercise) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => ExerciseInfoScreen(exercise: exercise),
    );
  }

  void _deleteExerciseForPlan(String exerciseId) {
    final exerciseForDelete = widget.exercises.firstWhere((exercise) => exercise.id == exerciseId);
    setState(() {
      _dataManager.deleteExerciseData(exerciseId);
    });  
    widget.onDelete(exerciseForDelete);
  }

  void _replaceExerciseForPlan(Exercise exercise) {
    final exerciseId = exercise.id;
    
    // Loguj aktualne dane
    _replacementManager.logReplacementData(
      exercise,
      _dataManager.kgControllers,
      _dataManager.repControllers,
      _dataManager.notesControllers,
    );
    
    // Zapisz dane
    final savedData = _replacementManager.saveExerciseData(
      exerciseId,
      _dataManager.kgControllers,
      _dataManager.repControllers,
      _dataManager.notesControllers,
    );
    
    print("💾 Saved data: $savedData");

    if (widget.onReplaceExercise != null) {
      print("🔄 Calling onReplaceExercise callback with saved data");
      widget.onReplaceExercise!(exercise, savedData);
    } else {
      print("❌ onReplaceExercise callback is null - using fallback");
      widget.onDelete(exercise);
      _replacementManager.storePendingData(exerciseId, savedData);
      print("🔄 Exercise replacement initiated. Data saved for restoration.");
    }
  }

  void _updateRowValue(String exerciseId, int rowIndex, String field, String value) {
    setState(() {
      _dataManager.updateRowValue(exerciseId, rowIndex, field, value);
    });
  }

  void _updateNotes(String exerciseId, String notes) {
    setState(() {
      _dataManager.updateNotes(exerciseId, notes);
    });
  }

  /// Publiczne metody dla dostępu z zewnątrz

  void restoreExerciseDataWithTransfer({
    required String newExerciseId,
    required String oldExerciseId,
    required Map<String, dynamic> savedData,
  }) {
    _replacementManager.restoreExerciseDataWithTransfer(
      newExerciseId: newExerciseId,
      oldExerciseId: oldExerciseId,
      savedData: savedData,
      exercises: widget.exercises,
      exerciseRows: _dataManager.exerciseRows,
      notesControllers: _dataManager.notesControllers,
      kgControllers: _dataManager.kgControllers,
      repControllers: _dataManager.repControllers,
      updateRowCallback: _updateRowValue,
      onStateChanged: () => setState(() {}),
    );
  }

  void restoreExerciseData(String newExerciseId, String oldExerciseId) {
    print("🔄 Legacy restore method called - this should NOT be used anymore!");
    print("❌ Use restoreExerciseDataWithTransfer instead");
    
    final exercise = widget.exercises.firstWhere((e) => e.id == newExerciseId);
    _dataManager.initializeExerciseData(exercise, _updateRowValue);
  }

  Map<String, dynamic> saveExerciseDataById(String exerciseId) {
    return _replacementManager.saveExerciseData(
      exerciseId,
      _dataManager.kgControllers,
      _dataManager.repControllers,
      _dataManager.notesControllers,
    );
  }

  @override
  void dispose() {
    _dataManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      onReorder: _reorderExercises,
      itemCount: widget.exercises.length,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).colorScheme.primary.withAlpha(25),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ), 
                ),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      
      itemBuilder: (context, index) {
        final exercise = widget.exercises[index];
        final exerciseId = exercise.id;

        // Upewnij się, że dane są zainicjalizowane
        if (!_dataManager.hasExerciseData(exerciseId)) {
          _dataManager.initializeExerciseData(exercise, _updateRowValue);
        }

        return Card(
          key: ValueKey(exerciseId),
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header z nazwą ćwiczenia i akcjami
                Row(
                  children: [
                    ReorderableDragStartListener(
                      index: index,
                      child: Container(
                        child: Icon(
                          Icons.drag_handle,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: ExerciseImage(
                        exerciseId: exerciseId,
                        size: 48,
                        showBorder: false,
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Nazwa ćwiczenia
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (exercise.bodyPart.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              exercise.bodyPart,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Przyciski akcji
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _replaceExerciseForPlan(exercise),
                          color: Theme.of(context).colorScheme.primary,
                          icon: const Icon(Icons.refresh),
                          tooltip: "Zamień ćwiczenie",
                        ),
                     
                        IconButton(
                          onPressed: () => _openInfoExercise(exercise),
                          icon: const Icon(Icons.info_outline),
                          color: Theme.of(context).colorScheme.primary,
                          tooltip: "Informacje o ćwiczeniu",
                        ),
                        IconButton(
                          onPressed: () => _deleteExerciseForPlan(exerciseId),
                          icon: const Icon(Icons.remove_circle_outline),
                          color: Theme.of(context).colorScheme.error,
                          tooltip: "Usuń ćwiczenie",
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Pole notatek
                TextField(
                  controller: _dataManager.notesControllers[exerciseId],
                  onChanged: (value) => _updateNotes(exerciseId, value),
                  decoration: InputDecoration(
                    labelText: "Notatki do ćwiczenia",
                    hintText: "Dodaj uwagi lub instrukcje...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  maxLines: 1,
                ),
                
                const SizedBox(height: 16),
                
                // Tabela setów
                BuildSetsTable(
                  exerciseId: exerciseId,
                  exerciseName: exercise.name,
                  rows: _dataManager.getExerciseTableData(exerciseId),
                  kgControllers: _dataManager.kgControllers,
                  repControllers: _dataManager.repControllers,
                ),
                
                const SizedBox(height: 12),
                
                // Przyciski akcji dla setów
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _addRow(exerciseId, exercise.name),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Dodaj set"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _dataManager.getExerciseTableData(exerciseId).length > 1
                          ? () => _removeRow(exerciseId, _dataManager.getExerciseTableData(exerciseId).length - 1)
                          : null,
                      icon: const Icon(Icons.remove, size: 18),
                      label: const Text("Usuń set"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}