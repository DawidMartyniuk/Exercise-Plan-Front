import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/screens/exercise_info.dart';
import 'package:work_plan_front/widget/plan/plan_creation/widgets/build_sets_table.dart';
import 'package:work_plan_front/widget/plan/plan_works/plan_selected/components/exercise_image.dart';
import 'package:work_plan_front/widget/plan/plan_creation/helpers/selected_exercise_data_manager.dart';
import 'package:work_plan_front/widget/plan/plan_creation/helpers/exercise_replacement_manager.dart';

class SelectedExerciseList extends StatefulWidget {
  final List<Exercise> exercises;
  final void Function(Exercise exercise) onDelete;
  final void Function(Map<String, List<Map<String, String>>> Function()) onGetTableData;
  final void Function(List<Exercise>)? onExercisesReordered;
  final void Function(Exercise oldExercise, Map<String, dynamic> savedData)? onReplaceExercise;

  // OPCJONALNE DANE POCZĄTKOWE DLA EDYCJI
  final Map<String, List<Map<String, String>>>? initialData; 
  final Map<String, String>? initialNotes; 

  const SelectedExerciseList({
    Key? key,
    required this.exercises,
    required this.onDelete,
    required this.onGetTableData,
    this.onExercisesReordered,
    this.onReplaceExercise,
    this.initialData,
    this.initialNotes,
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

    //  INICJALIZUJ MANAGERY
    _dataManager = SelectedExerciseDataManager();
    _replacementManager = ExerciseReplacementManager();
    _reorderedExercises = List.from(widget.exercises);

    //  ZAŁADUJ DANE POCZĄTKOWE JEŚLI ISTNIEJĄ (EDYCJA)
    if (widget.initialData != null && widget.initialData!.isNotEmpty) {
      _loadInitialDataForEdit();
    } else {
      // ✅ INICJALIZUJ NORMALNE DANE DLA NOWEGO PLANU
      _initializeNewPlanData();
    }

    // ✅ USTAW CALLBACK DLA POBRANIA DANYCH
    widget.onGetTableData(() => _dataManager.getTableData(widget.exercises));
  }

  // ✅ ŁADOWANIE DANYCH DO EDYCJI
  void _loadInitialDataForEdit() {
  //print("🔄 Loading initial data for plan editing...");
  print("📊 Total exercises to load: ${widget.exercises.length}");
  print("📊 Initial data keys: ${widget.initialData?.keys.toList()}");
  print("📊 Initial notes keys: ${widget.initialNotes?.keys.toList()}");
  
  for (final exercise in widget.exercises) {
    final exerciseId = exercise.id;
    print("\n🏋️ Processing exercise: ${exercise.name} (ID: $exerciseId)");
    
    // Sprawdź czy mamy dane dla tego ćwiczenia
    if (widget.initialData!.containsKey(exerciseId)) {
      final rows = widget.initialData![exerciseId]!;
      final notes = widget.initialNotes?[exerciseId] ?? "";
      
      print("✅ Found data for exercise $exerciseId:");
      print("  📝 Notes: '$notes'");
      print("  📊 Sets count: ${rows.length}");
      
        for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      print("  📋 Set ${i + 1}: colKg=${row['colKg']}, colRepMin=${row['colRepMin']}, colRepMax=${row['colRepMax']}, colStep=${row['colStep']}, repsType=${row['repsType']}");
    }
      
      // Załaduj dane do managera
      _dataManager.exerciseRows[exerciseId] = {
        "exerciseName": exercise.name,
        "notes": notes,
        "rows": List<Map<String, String>>.from(rows),
      };
      
      print("  ✅ Data loaded to manager for $exerciseId");
      
      // Stwórz kontrolery dla istniejących setów
      _createControllersForExistingData(exerciseId, rows, notes);
      
      print("  ✅ Controllers created for $exerciseId");
    } else {
      print("⚠️ No data found for exercise $exerciseId - initializing standard data");
      // Jeśli nie ma danych - inicjalizuj standardowo
      _dataManager.initializeExerciseData(exercise, _updateRowValue);
    }
  }
  
  print("\n✅ Initial data loaded for ${widget.initialData!.length} exercises");
  print("🔍 Final data manager state:");
  for (final entry in _dataManager.exerciseRows.entries) {
    final exerciseId = entry.key;
    final data = entry.value;
    final rows = data["rows"] as List<Map<String, String>>;
    print("  🏋️ $exerciseId: ${rows.length} sets, notes: '${data["notes"]}'");
  }
}

  // ✅INICJALIZACJA NOWEGO PLANU
  void _initializeNewPlanData() {
    for (final exercise in widget.exercises) {
      _dataManager.initializeExerciseData(exercise, _updateRowValue);
    }
  }
   Map<String, String> getExerciseNotes() {
    final notes = <String, String>{};
    
    for (final entry in _dataManager.exerciseRows.entries) {
      final exerciseId = entry.key;
      final exerciseData = entry.value;
      notes[exerciseId] = exerciseData["notes"]?.toString() ?? "";
    }
    
    print("📝 Retrieved exercise notes: $notes");
    return notes;
  }
   Map<String, Map<String, dynamic>> getAllExerciseData() {
    return Map.from(_dataManager.exerciseRows);
  }

  //  PUBLICZNA METODA DO ŁADOWANIA DANYCH Z ZEWNĄTRZ
  void loadInitialData(
    Map<String, List<Map<String, String>>> exerciseData,
    Map<String, String> exerciseNotes,
  ) {
    print("🔄 Loading initial data externally...");
    
    for (final entry in exerciseData.entries) {
      final exerciseId = entry.key;
      final rows = entry.value;
      
      // Załaduj dane setów
      _dataManager.exerciseRows[exerciseId] = {
        "exerciseName": widget.exercises.firstWhere(
          (ex) => ex.id == exerciseId,
          orElse: () => widget.exercises.first,
        ).name,
        "notes": exerciseNotes[exerciseId] ?? "",
        "rows": List<Map<String, String>>.from(rows),
      };
      
      // Stwórz kontrolery dla istniejących setów
      _createControllersForExistingData(exerciseId, rows, exerciseNotes[exerciseId] ?? "");
    }
    
    setState(() {
      // Trigger rebuild
    });
    
    // Wywołaj callback z załadowanymi danymi
    widget.onGetTableData?.call(() => _dataManager.exerciseRows.map(
      (key, value) => MapEntry(key, value["rows"] as List<Map<String, String>>),
    ));
    
    print("✅ External initial data loaded for ${exerciseData.length} exercises");
  }
  List<Exercise> getCurrentExerciseOrder() {
  print("📋 Getting current exercise order: ${_reorderedExercises.map((e) => e.name).join(', ')}");
  return List.from(_reorderedExercises);
}

  //  TWORZENIE KONTROLERÓW DLA ISTNIEJĄCYCH DANYCH
  void _createControllersForExistingData(String exerciseId, List<Map<String, String>> rows, String notes) {
    //  DISPOSE POPRZEDNICH KONTROLERÓW
    _dataManager.kgControllers[exerciseId]?.forEach((c) => c.dispose());
    _dataManager.repMinControllers[exerciseId]?.forEach((c) => c.dispose()); //  ZMIENIONE
    _dataManager.repMaxControllers[exerciseId]?.forEach((c) => c.dispose());

    _dataManager.kgControllers[exerciseId] = [];
    _dataManager.repMinControllers[exerciseId] = []; // ZMIENIONE
    _dataManager.repMaxControllers[exerciseId] = [];
    
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      
      final kgValue = row["colKg"] ?? "0";
      final repMinValue = row["colRepMin"] ?? "0"; // ZMIENIONE z colRep
      final repMaxValue = row["colRepMax"] ?? row["colRepMin"] ?? "0";
      final repsType = row["repsType"] ?? "single";
      
      print("  🎛️ Set ${i + 1} controllers: kg='$kgValue', repMin='$repMinValue', repMax='$repMaxValue', type='$repsType'");
      
      final kgController = TextEditingController(text: kgValue);
      kgController.addListener(() {
        print("  📝 KG changed for $exerciseId set ${i + 1}: ${kgController.text}");
        _updateRowValue(exerciseId, i, "colKg", kgController.text);
      });
      _dataManager.kgControllers[exerciseId]!.add(kgController);
      
      //  KONTROLER REP MIN (poprzednio rep)
      final repMinController = TextEditingController(text: repMinValue);
      repMinController.addListener(() {
        print("  📝 REP MIN changed for $exerciseId set ${i + 1}: ${repMinController.text}");
        _updateRowValue(exerciseId, i, "colRepMin", repMinController.text); //  ZMIENIONE
      });
      _dataManager.repMinControllers[exerciseId]!.add(repMinController); //  ZMIENIONE
    
      final repMaxController = TextEditingController(text: repMaxValue);
      repMaxController.addListener(() {
        print("  📝 REP MAX changed for $exerciseId set ${i + 1}: ${repMaxController.text}");
        _updateRowValue(exerciseId, i, "colRepMax", repMaxController.text);
      });
      _dataManager.repMaxControllers[exerciseId]!.add(repMaxController);
      
      final currentRows = _dataManager.exerciseRows[exerciseId]!["rows"] as List<Map<String, String>>;
      if (i < currentRows.length) {
        currentRows[i]["repsType"] = repsType;
      }
    }
    
    _dataManager.notesControllers[exerciseId]?.dispose();
    _dataManager.notesControllers[exerciseId] = TextEditingController(text: notes);
    _dataManager.notesControllers[exerciseId]!.addListener(() {
      _updateNotes(exerciseId, _dataManager.notesControllers[exerciseId]!.text);
    });
  }

  @override
  void didUpdateWidget(SelectedExerciseList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Aktualizuj listę ćwiczeń jeśli się zmieniła
   if (widget.exercises.length != _reorderedExercises.length ||
      !widget.exercises.every((e) => _reorderedExercises.any((r) => r.id == e.id))) {
    
    // ✅ UŻYJ PostFrameCallback ZAMIAST setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _reorderedExercises = List.from(widget.exercises);
        });
        
        // Inicjalizuj dane dla nowych ćwiczeń
        for (final exercise in widget.exercises) {
          if (!_dataManager.hasExerciseData(exercise.id)) {
            print("🆕 Initializing new exercise: ${exercise.name}");
            _dataManager.initializeExerciseData(exercise, _updateRowValue);
          }
        }
        
        widget.onGetTableData(() => _dataManager.getTableData(widget.exercises));
      }
    });
  }
  }

  // ✅ METODY AKCJI
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
      _dataManager.repMinControllers,
      _dataManager.notesControllers,
    );
    
    // Zapisz dane
    final savedData = _replacementManager.saveExerciseData(
      exerciseId,
      _dataManager.kgControllers,
      _dataManager.repMinControllers,
      _dataManager.notesControllers,
    );

    if (widget.onReplaceExercise != null) {
      widget.onReplaceExercise!(exercise, savedData);
    } else {
      widget.onDelete(exercise);
      _replacementManager.storePendingData(exerciseId, savedData);
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

  // ✅ PUBLICZNE METODY DLA DOSTĘPU Z ZEWNĄTRZ
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
      repControllers: _dataManager.repMinControllers,
      updateRowCallback: _updateRowValue,
      onStateChanged: () => setState(() {}),
    );
  }

  Map<String, dynamic> saveExerciseDataById(String exerciseId) {
    return _replacementManager.saveExerciseData(
      exerciseId,
      _dataManager.kgControllers,
      _dataManager.repMinControllers,
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
                      child: Icon(
                        Icons.drag_handle,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
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
                  repMinControllers: _dataManager.repMinControllers, // ✅ ZMIENIONE z repControllers
                  repMaxControllers: _dataManager.repMaxControllers,
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