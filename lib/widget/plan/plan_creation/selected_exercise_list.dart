import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/screens/exercise_info.dart';
import 'package:work_plan_front/widget/plan/plan_creation/widgets/build_sets_table.dart';
import 'package:work_plan_front/widget/plan/plan_list/plan_selected/components/exercise_image.dart';

class SelectedExerciseList extends StatefulWidget {
  final List<Exercise> exercises;
  final void Function(Exercise exercise) onDelete;
  final void Function(Map<String, List<Map<String, String>>> Function()) onGetTableData;
  final void Function(List<Exercise>)? onExercisesReordered;

  const SelectedExerciseList({
    Key? key,
    required this.exercises,
    required this.onDelete,
    required this.onGetTableData,
    this.onExercisesReordered,
  }) : super(key: key);

  @override
  State<SelectedExerciseList> createState() => SelectedExerciseListState();
}

class SelectedExerciseListState extends State<SelectedExerciseList> {
  Map<String, Map<String, dynamic>> exerciseRows = {};
  final Map<String, TextEditingController> _notesControllers = {};
  final Map<String, List<TextEditingController>> _kgControllers = {};
  final Map<String, List<TextEditingController>> _repControllers = {};

  List<Exercise> _reorderedExercises = [];
  int? _draggedIndex;

  @override
  void initState() {
    super.initState();
    _reorderedExercises = List.from(widget.exercises.toList());
 
    for (final exercise in widget.exercises) {
      _initializeExerciseData(exercise);
    }
   
    widget.onGetTableData(getTableData);
  }

  @override
  void didUpdateWidget(SelectedExerciseList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.exercises.length != _reorderedExercises.length ||
        !widget.exercises.every((e) => _reorderedExercises.any((r) => r.id == e.id))) {
      _reorderedExercises = List.from(widget.exercises);
    }
    
    // Jeśli lista ćwiczeń się zmieniła, zaktualizuj dane
    for (final exercise in widget.exercises) {
      if (!exerciseRows.containsKey(exercise.id)) {
        print("🆕 Initializing new exercise: ${exercise.name}");
        _initializeExerciseData(exercise);
      }
    }
    _reorderedExercises = List.from(widget.exercises);
    
    // Przekaż zaktualizowaną funkcję pobierania danych
    widget.onGetTableData(getTableData);
  }

  void _reorderExercises(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final exercise = _reorderedExercises.removeAt(oldIndex);
      _reorderedExercises.insert(newIndex, exercise);
    });
    if (widget.onExercisesReordered != null) {
      widget.onExercisesReordered!(_reorderedExercises);
    }
  }

  void _initializeExerciseData(Exercise exercise) {
    print("🆕 Initializing exercise data for: ${exercise.name} (ID: ${exercise.id})");
  
    // Sprawdź czy już nie istnieje
    if (exerciseRows.containsKey(exercise.id)) {
      print("⚠️ Exercise data already exists for: ${exercise.name}");
      return;
    }
  
    exerciseRows[exercise.id] = {
      "exerciseName": exercise.name,
      "notes": "",
      "rows": [
        {"colStep": "1", "colKg": "0", "colRep": "0"}
      ]
    };
  
    // Inicjalizuj kontrolery
    if (!_notesControllers.containsKey(exercise.id)) {
      _notesControllers[exercise.id] = TextEditingController();
    }
  
    if (!_kgControllers.containsKey(exercise.id)) {
      _kgControllers[exercise.id] = [TextEditingController(text: "0")];
    }
  
    if (!_repControllers.containsKey(exercise.id)) {
      _repControllers[exercise.id] = [TextEditingController(text: "0")];
    }

    // Dodaj listenery
    _kgControllers[exercise.id]![0].addListener(() {
      _updateRowValue(exercise.id, 0, "colKg", _kgControllers[exercise.id]![0].text);
    });

    _repControllers[exercise.id]![0].addListener(() {
      _updateRowValue(exercise.id, 0, "colRep", _repControllers[exercise.id]![0].text);
    });
  
    print("✅ Initialized exercise data for: ${exercise.name}");
  }

  void _addRow(String exerciseId, String exerciseName) {
    setState(() {
      if (!exerciseRows.containsKey(exerciseId)) {
        _initializeExerciseData(widget.exercises.firstWhere((e) => e.id == exerciseId));
      }
      
      final rows = exerciseRows[exerciseId]!["rows"] as List<Map<String, String>>;
      final currentRowCount = rows.length;
      
      // ✅ POPRAWKA - KOPIUJ WARTOŚCI Z OSTATNIEGO SETU
      final lastKg = rows.isNotEmpty ? rows[currentRowCount - 1]["colKg"] ?? "0" : "0";
      final lastReps = rows.isNotEmpty ? rows[currentRowCount - 1]["colRep"] ?? "0" : "0";
      
      rows.add({
        "colStep": "${currentRowCount + 1}",
        "colKg": lastKg, // ✅ KOPIUJ OSTATNIĄ WAGĘ
        "colRep": lastReps, // ✅ KOPIUJ OSTATNIE POWTÓRZENIA
      });

      // ✅ NOWE KONTROLERY Z SKOPIOWANYMI WARTOŚCIAMI
      final kgController = TextEditingController(text: lastKg);
      final repController = TextEditingController(text: lastReps);

      kgController.addListener(() => 
        _updateRowValue(exerciseId, currentRowCount, "colKg", kgController.text));
      repController.addListener(() => 
        _updateRowValue(exerciseId, currentRowCount, "colRep", repController.text));

      _kgControllers[exerciseId]!.add(kgController);
      _repControllers[exerciseId]!.add(repController);
    });
  }

  void _removeRow(String exerciseId, int index) {
    setState(() {
      if (exerciseRows.containsKey(exerciseId)) {
        final rows = exerciseRows[exerciseId]!["rows"] as List<Map<String, String>>;
        if (rows.length > 1 && index < rows.length) {

          if (_kgControllers[exerciseId] != null && _kgControllers[exerciseId]!.length > index) {
            _kgControllers[exerciseId]![index].dispose();
            _kgControllers[exerciseId]!.removeAt(index);
          }

          if (_repControllers[exerciseId] != null && _repControllers[exerciseId]!.length > index) {
            _repControllers[exerciseId]![index].dispose();
            _repControllers[exerciseId]!.removeAt(index);
          }

          rows.removeAt(index);
          // Aktualizuj numery kroków
          for (int i = 0; i < rows.length; i++) {
            rows[i]["colStep"] = "${i + 1}";
          }
        }
      }
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

  List<Map<String, String>> _getTableData(String exerciseId) {
    return (exerciseRows[exerciseId]?["rows"] as List<Map<String, String>>?) ?? [];
  }

  // ✅ POWRÓT DO PROSTEJ WERSJI getTableData
  Map<String, List<Map<String, String>>> getTableData() {
    print("🔍 Getting table data for ${widget.exercises.length} exercises");
    
    final Map<String, List<Map<String, String>>> result = {};
    
    for (final exercise in widget.exercises) {
      final exerciseId = exercise.id;
      if (exerciseRows.containsKey(exerciseId)) {
        final rows = (exerciseRows[exerciseId]?["rows"] as List<Map<String, String>>?) ?? [];
        result[exerciseId] = rows;
        print("  - ${exercise.name}: ${rows.length} sets");
      } else {
        print("  - ${exercise.name}: NO DATA");
      }
    }
    
    print("🔍 Returning data for ${result.length} exercises");
    return result;
  }

  void _deleteExerciseForPlan(String exerciseId) {
    final exerciseForDelete = widget.exercises.firstWhere((exercise) => exercise.id == exerciseId);
    setState(() {
      exerciseRows.remove(exerciseId);
      _notesControllers.remove(exerciseId)?.dispose();

      if (_kgControllers[exerciseId] != null) {
        for (var controller in _kgControllers[exerciseId]!) {
          controller.dispose();
        }
        _kgControllers.remove(exerciseId);
      }
      if (_repControllers[exerciseId] != null) {
        for (var controller in _repControllers[exerciseId]!) {
          controller.dispose();
        }
        _repControllers.remove(exerciseId);
      }
    });  
    widget.onDelete(exerciseForDelete);
  }

  void _updateRowValue(String exerciseId, int rowIndex, String field, String value) {
    setState(() {
      if (exerciseRows.containsKey(exerciseId)) {
        final rows = exerciseRows[exerciseId]!["rows"] as List<Map<String, String>>;
        if (rowIndex < rows.length) {
          rows[rowIndex][field] = value;
        }
      }
    });
  }

  void _updateNotes(String exerciseId, String notes) {
    setState(() {
      if (exerciseRows.containsKey(exerciseId)) {
        exerciseRows[exerciseId]!["notes"] = notes;
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _notesControllers.values) {
      controller.dispose();
    }

    for (var controllers in _kgControllers.values) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }

    for (var controllers in _repControllers.values) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }

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
        if (!exerciseRows.containsKey(exerciseId)) {
          _initializeExerciseData(exercise);
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
                  controller: _notesControllers[exerciseId],
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
                  rows: _getTableData(exerciseId),
                  kgControllers: _kgControllers,
                  repControllers: _repControllers,
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
                      onPressed: _getTableData(exerciseId).length > 1
                          ? () => _removeRow(exerciseId, _getTableData(exerciseId).length - 1)
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