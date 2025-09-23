import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/weight_type.dart';
import 'package:work_plan_front/provider/exercise_plan_notifier.dart';
import 'package:work_plan_front/provider/exercise_provider.dart';
import 'package:work_plan_front/provider/reps_type_provider.dart';
import 'package:work_plan_front/provider/weight_type_provider.dart';
import 'package:work_plan_front/screens/exercises.dart';
import 'package:work_plan_front/screens/tabs.dart';
import 'package:work_plan_front/widget/plan/plan_creation/selected_exercise_list.dart';
import 'package:work_plan_front/widget/plan/plan_creation/widgets/plan_title_field.dart';
import 'package:work_plan_front/widget/plan/plan_creation/widgets/exercise_selection_button.dart';
import 'package:work_plan_front/widget/plan/plan_creation/helpers/data_formatter.dart';
import 'package:work_plan_front/utils/toast_untils.dart';

class PlanCreation extends ConsumerStatefulWidget {
  final ExerciseTable? planToEdit;
  const PlanCreation({
    super.key,
    this.planToEdit
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _StatePlanCreation();
  }
}

class _StatePlanCreation extends ConsumerState<PlanCreation> {
  List<Exercise> selectedExercise = [];
  Map<String, List<Map<String, String>>> Function()? _getTableData;
  String exerciseTableTitle = ""; 
  final ScrollController _mainScrollController = ScrollController();

  bool get _isEditMode => widget.planToEdit != null;

  // ✅ DODAJ KLUCZ DLA PlanTitleField
  final GlobalKey<PlanTitleFieldState> _planTitleFieldKey = GlobalKey<PlanTitleFieldState>();
  final GlobalKey<SelectedExerciseListState> _selectedExerciseListKey = GlobalKey<SelectedExerciseListState>();
  final String _widgetKey = DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic>? _pendingReplacementData;
  String? _oldExerciseIdForReplacement;

  bool get _isPlanReadToSave {
    final hasTitle = exerciseTableTitle.trim().isNotEmpty;
    final hasExercises = selectedExercise.isNotEmpty;
    return hasTitle && hasExercises;
  }

  @override
  void initState() {
    super.initState();
    
    print("🔧 PlanCreation initialized in ${_isEditMode ? 'EDIT' : 'CREATE'} mode");
    
    if (_isEditMode && widget.planToEdit != null) {
      print("✏️ Loading plan for editing: ${widget.planToEdit!.exercise_table}");
      _loadPlanForEditing(widget.planToEdit!);
    } else {
      print("🆕 Creating new plan");
    }
  }
  @override
  void dispose() {
  _mainScrollController.dispose();
  super.dispose();
}

  void _loadPlanForEditing(ExerciseTable plan) {
    print("\n🔄 Loading plan for editing: ${plan.exercise_table} (ID: ${plan.id})");
    
    // POBIERZ NAJNOWSZE DANE Z PROVIDERA
    final currentPlans = ref.read(exercisePlanProvider);
    final currentPlan = currentPlans.firstWhere(
      (p) => p.id == plan.id,
      orElse: () => plan, // fallback do przekazanego planu
    );
    
    print("📊 Using plan data: ${currentPlan.rows.length} exercise groups from provider");
    for (final row in currentPlan.rows) {
      print("  📋 ${row.exercise_name}: ${row.data.length} sets");
    }
    setState(() {
      exerciseTableTitle = currentPlan.exercise_table;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _planTitleFieldKey.currentState?.setValue(currentPlan.exercise_table);
      }
    });
    _loadExercisesFromPlan(currentPlan); // używaj currentPlan zamiast plan
  }

  //  POPRAWIONY CALLBACK DLA ZMIANY NAZWY PLANU - UŻYJ PostFrameCallback
  void _onPlanTitleChanged(String newTitle) {
    //  SPRAWDŹ CZY WIDGET JEST PODCZAS BUDOWANIA
    if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      //  JEŚLI TAK - UŻYJ PostFrameCallback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            exerciseTableTitle = newTitle;
          });
         // print("📝 Plan title changed to: '$newTitle' (via PostFrameCallback)");
        }
      });
    } else {
      
      setState(() {
        exerciseTableTitle = newTitle;
      });
  
    }
  }
  


  void _loadExercisesFromPlan(ExerciseTable plan) async {
  print("\n🔄 Loading exercises from plan...");
  
  final allExercises = ref.read(exerciseProvider);
  allExercises.when(
    data: (exercisesList) {
      print("📊 Available exercises in provider: ${exercisesList.length}");
      return null;
    },
    loading: () {
      print("📊 Available exercises in provider: loading...");
      return null;
    },
    error: (error, stack) {
      print("📊 Available exercises in provider: error: $error");
      return null;
    },
  );

  final selectedExercisesList = <Exercise>[];
  final exerciseData = <String, List<Map<String, String>>>{};

  print("\n📋 Processing plan rows:");
  for (int groupIndex = 0; groupIndex < plan.rows.length; groupIndex++) {
    final rowData = plan.rows[groupIndex];
    final exerciseId = rowData.exercise_number;
    print("\n🏋️ Group $groupIndex: Exercise ID '$exerciseId' (${rowData.exercise_name})");
    print("  📊 This group has ${rowData.data.length} sets");

    //  ZNAJDŹ ĆWICZENIE BEZPOŚREDNIO (BEZ WHEN)
    final exercise = allExercises.when(
      data: (exercisesList) {
        return exercisesList.firstWhere(
          (ex) => ex.exerciseId == exerciseId,
          orElse: () {
            print("  ⚠️ Exercise with exerciseId '$exerciseId' not found! Creating fallback");
            return Exercise(
              exerciseId: exerciseId,
              name: rowData.exercise_name ?? "Unknown Exercise",
              bodyParts: [],
              equipments: [],
              gifUrl: "",
              targetMuscles: [],
              secondaryMuscles: [],
              instructions: [],
            );
          },
        );
      },
      loading: () => Exercise(
        exerciseId: exerciseId, 
        name: rowData.exercise_name ?? "Loading Exercise",
        bodyParts: [],
        equipments: [],
        gifUrl: "",
        targetMuscles: [],
        secondaryMuscles: [],
        instructions: [],
      ),
      error: (error, stack) => Exercise(
        exerciseId: exerciseId,
        name: rowData.exercise_name ?? "Error Exercise", 
        bodyParts: [],
        equipments: [],
        gifUrl: "",
        targetMuscles: [],
        secondaryMuscles: [],
        instructions: [],
      ),
    );

    print("  ✅ Exercise resolved: ${exercise.name} (ID: ${exercise.id})");

    //  DODAJ ĆWICZENIE DO LISTY
    if (!selectedExercisesList.any((ex) => ex.id == exercise.id)) {
      selectedExercisesList.add(exercise);
      print("  ➕ Added exercise to selected list: ${exercise.name}");
    }

    //  PRZYGOTUJ DANE SETÓW
    if (!exerciseData.containsKey(exercise.id)) {
      exerciseData[exercise.id] = [];
      print("  📊 Initialized exercise data for ${exercise.id}");
    }

    //  DODAJ DANE SETÓW Z PLANU - UŻYWAJ colRepMin
    for (int setIndex = 0; setIndex < rowData.data.length; setIndex++) {
      final row = rowData.data[setIndex];
      
      final isRange = row.colRepMin != row.colRepMax;
      final repsType = isRange ? 'range' : 'single';
      
      final setData = {
        "colStep": row.colStep.toString(),
        "colKg": row.colKg.toString(),
        "colRepMin": row.colRepMin.toString(), // POPRAWIONE z colRep
        "colRepMax": row.colRepMax.toString(),
        "repsType": repsType,
      };
      exerciseData[exercise.id]!.add(setData);
      
      print("    📋 Set ${setIndex + 1}: step=${row.colStep}, kg=${row.colKg}, repMin=${row.colRepMin}, repMax=${row.colRepMax}, type=$repsType");
    }
    
    print("  ✅ Loaded ${rowData.data.length} sets for exercise ${exercise.name}");
  }

  print("\n📊 Final loading summary:");
  print("  🏋️ Selected exercises: ${selectedExercisesList.length}");
  print("  📋 Exercise data keys: ${exerciseData.keys.toList()}");
  
  for (final entry in exerciseData.entries) {
    print("    ${entry.key}: ${entry.value.length} sets");
    for (int i = 0; i < entry.value.length; i++) {
      final setData = entry.value[i];
      print("      Set ${i + 1}: repMin=${setData['colRepMin']}, repMax=${setData['colRepMax']}, repsType=${setData['repsType']}");
    }
  }

  //  ZAKTUALIZUJ STAN
  setState(() {
    selectedExercise = selectedExercisesList;
   // exerciseTableTitle = plan.exercise_table; //  DODAJ TO!
    print("✅ State updated with ${selectedExercisesList.length} exercises");
  });

  //  ZAŁADUJ DANE DO UI
  WidgetsBinding.instance.addPostFrameCallback((_) {
    print("\n📤 PostFrameCallback: Loading data to SelectedExerciseList...");
    _selectedExerciseListKey.currentState?.loadInitialData(
      exerciseData,
      _extractInitialNotes(),
    );
    print("✅ Data loading initiated");
  });
}

  Map<String, String> _extractInitialNotes() {
    if (widget.planToEdit == null) return {};

    final Map<String, String> notes = {};

    for (final rowData in widget.planToEdit!.rows) {
      notes[rowData.exercise_number] = rowData.notes ?? "";
    }

    return notes;
  }

  Map<String, List<Map<String, String>>> _extractInitialData() {
    if (widget.planToEdit == null) return {};

    final Map<String, List<Map<String, String>>> data = {};

    for (final rowData in widget.planToEdit!.rows) {
      final exerciseId = rowData.exercise_number;
      data[exerciseId] =
          rowData.data
              .map(
                (row) => {
                  "colStep": row.colStep.toString(),
                  "colKg": row.colKg.toString(),
                  "colRepMin": row.colRepMin.toString(),
                  "colRepMax": row.colRepMax.toString(),
                },
              )
              .toList();
    }

    return data;
  }

  /// Zapisuje dane planu treningowego
  void _savePlanData(WidgetRef ref) async {
    print("💾 Starting plan save process...");

      final currentTitleFromField = _planTitleFieldKey.currentState?.currentValue?.trim() ?? exerciseTableTitle.trim();
      final finalTitle = currentTitleFromField.isNotEmpty ? currentTitleFromField : exerciseTableTitle.trim();

    if (!_isPlanReadToSave) {
      ToastUtils.showValidationError(
        context,
        customMessage:
            "Wypełnij tytuł planu i dodaj przynajmniej jedno ćwiczenie",
      );
      return;
    }

    if (_getTableData == null) {
      ToastUtils.showErrorToast(
        context: context,
        message: "Brak danych tabeli",
      );
      return;
    }
    // final finalTitle = currentTitleFromField.isNotEmpty ? currentTitleFromField : exerciseTableTitle.trim();


    try {
      final tableData = _getTableData!();
      final currentExerciseOrder = _selectedExerciseListKey.currentState?.getCurrentExerciseOrder() ?? [];

      // UTWÓRZ MAPĘ NAZWA ĆWICZEŃ
      final exerciseNames = <String, String>{};
      final exerciseRepTypes = <String, String>{};

      for (final exercise in currentExerciseOrder) {
        exerciseNames[exercise.id] = exercise.name;
        final repType = ref.read(exerciseRepsTypeProvider(exercise.id));
        exerciseRepTypes[exercise.id] = repType.toDbString();
      }
       if (currentExerciseOrder.isEmpty) {
      ToastUtils.showValidationError(
        context,
        customMessage: "Brak ćwiczeń w planie",
      );
      return;
    }
      
      //  POPRAW POBIERANIE weight_type
      final rawWeightType = ref.read(weightTypeForExerciseProvider(selectedExercise.first.id));
      
      //  KONWERTUJ WeightType enum na string
      String cleanWeightType;
      if (rawWeightType == WeightType.kg) {
        cleanWeightType = "kg";
      } else if (rawWeightType == WeightType.lbs) {
        cleanWeightType = "lbs";
      } else {
        cleanWeightType = "kg"; // domyślnie
      }
      
      print("🔍 Weight type conversion: $rawWeightType -> $cleanWeightType");

      if (_isEditMode && widget.planToEdit != null) {
        // ✅ AKTUALIZACJA
        try {
          final statusCode = await ref.read(exercisePlanProvider.notifier).updateExercisePlan(
            
            exerciseId: widget.planToEdit!.id, 
            exerciseTableTitle: finalTitle,
            tableData: tableData,
            exerciseNames: exerciseNames,
            exerciseRepTypes: exerciseRepTypes,

            exerciseNotes: _selectedExerciseListKey.currentState?.getExerciseNotes() ?? {},
            weightType: cleanWeightType, //  UŻYJ OCZYSZCZONEJ WARTOŚCI
            exerciseOrder: currentExerciseOrder, //   AKTUALNA KOLEJNOŚĆ
          );

          if (statusCode == 200 || statusCode == 201) {
            setState(() {
            exerciseTableTitle = finalTitle;
            selectedExercise = currentExerciseOrder;
          });
            await _handleSaveSuccess();
          } else {
            _handleSaveError("Status: $statusCode");
          }
        } catch (e) {
          _handleSaveError(e.toString());
        }
      } else {
        // ✅ NOWY PLAN
        try {
          final payload = DataFormatter.formatPlanDataWithNames(
            weightType: cleanWeightType,
            tableData: tableData,
            planTitle: finalTitle,
            exerciseNames: exerciseNames,
            exerciseRepTypes: exerciseRepTypes,
            exerciseNotes: _selectedExerciseListKey.currentState?.getExerciseNotes() ?? {},
            exerciseOrder: currentExerciseOrder,
          );

          final exercisePlanNotifier = ref.read(exercisePlanProvider.notifier);
          await exercisePlanNotifier.initializeExercisePlan(payload);

          final statusCode = await exercisePlanNotifier.saveExercisePlan(
            onlyThis: exercisePlanNotifier.state.last,
          );

          if (statusCode == 200 || statusCode == 201) {
            await _handleSaveSuccess();
          } else {
            _handleSaveError("Status: $statusCode");
          }
        } catch (e) {
          _handleSaveError(e.toString());
        }
      }
    } catch (e) {
      _handleSaveError(e.toString());
    }
  }

  /// Obsługuje pomyślne zapisanie planu
  Future<void> _handleSaveSuccess() async {
     final actionName = _isEditMode ? "zaktualizowany" : "zapisany";
    ToastUtils.showSaveSuccess(context, itemName: "Plan treningowy $actionName");
    await ref.read(exercisePlanProvider.notifier).fetchExercisePlans();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TabsScreen(selectedPageIndex: 2),
        ),
      );
    }
  }

  /// Obsługuje błąd podczas zapisywania
 void _handleSaveError(String error) {
    final actionName = _isEditMode ? "zaktualizować" : "zapisać";
    ToastUtils.showErrorToast(
      context: context,
      message: "Nie udało się $actionName planu. Spróbuj ponownie.",
    );
    print("Błąd ${_isEditMode ? 'aktualizacji' : 'zapisywania'} planu: $error");
  }
  

  /// Obsługuje powrót z ekranu z walidacją zmian
  void _handleBackPress() {
    if (selectedExercise.isNotEmpty || exerciseTableTitle.isNotEmpty) {
      _showUnsavedChangesDialog();
    } else {
      Navigator.of(context).pop();
    }
  }

  /// Pokazuje dialog o niezapisanych zmianach
  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              "Czy na pewno chcesz wrócić?",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Text(
              "Wprowadzone zmiany nie zostały zapisane.",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Anuluj",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Zamknij dialog
                  Navigator.of(context).pop(); // Wróć do poprzedniego ekranu
                },
                child: Text(
                  "Wróć bez zapisywania",
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
    );
  }

  ///  NOWA METODA - OBSŁUGA ZMIANY ĆWICZENIA
  Future<void> _handleExerciseReplacement(
    Exercise oldExercise,
    Map<String, dynamic> savedData,
  ) async {
    print("🔄 Starting exercise replacement process for: ${oldExercise.name}");
    print("🔄 Old exercise ID: ${oldExercise.id}");
    print("🔄 Saved data: $savedData");

    //  ZAPISZ DANE DO PRZYWRÓCENIA PÓŹNIEJ
    _pendingReplacementData = savedData;
    _oldExerciseIdForReplacement = oldExercise.id;

    //  USUŃ STARE ĆWICZENIE Z LISTY
    setState(() {
      selectedExercise.removeWhere((exercise) => exercise.id == oldExercise.id);
    });

    //  PRZEJDŹ DO EKRANU WYBORU ĆWICZENIA
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder:
            (ctx) => ExercisesScreen(
              isSelectionMode: true,
              title: 'Zamień ćwiczenie: ${oldExercise.name}',
              onMultipleExercisesSelected: (exercises) {
                print('Otrzymano ${exercises.length} ćwiczeń do zamiany');
              },
            ),
      ),
    );

    if (result != null && _pendingReplacementData != null) {
      if (result is Exercise) {
        print("🔄 Selected new exercise: ${result.name} (ID: ${result.id})");

        //  DODAJ NOWE ĆWICZENIE
        setState(() {
          selectedExercise.add(result);
        });

        //  PRZYWRÓĆ ZAPISANE DANE PO ZBUDOWANIU WIDGETU
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print("🔄 Attempting to restore data:");
          print("  - New exercise ID: ${result.id}");
          print("  - Old exercise ID: $_oldExerciseIdForReplacement");
          print("  - Saved data: $_pendingReplacementData");

          // UŻYJ POPRAWNEJ METODY restoreExerciseDataWithTransfer
          _selectedExerciseListKey.currentState
              ?.restoreExerciseDataWithTransfer(
                newExerciseId: result.id,
                oldExerciseId: _oldExerciseIdForReplacement!,
                savedData: _pendingReplacementData!,
              );

          //  WYCZYŚĆ TYMCZASOWE DANE
          _pendingReplacementData = null;
          _oldExerciseIdForReplacement = null;

          print(
            "✅ Exercise replacement completed: ${oldExercise.name} → ${result.name}",
          );

          // POKAŻ TOAST O POWODZENIU
          ToastUtils.showSuccessToast(
            context: context,
            message: "Zamieniono ${oldExercise.name} na ${result.name}",
          );
        });
      } else if (result is List<Exercise> && result.isNotEmpty) {
        //  JEŚLI WYBRANO LISTĘ - WEŹ PIERWSZE ĆWICZENIE
        final newExercise = result.first;
        print(
          "🔄 Selected first exercise from list: ${newExercise.name} (ID: ${newExercise.id})",
        );

        setState(() {
          selectedExercise.add(newExercise);
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          print("🔄 Attempting to restore data for list selection:");
          print("  - New exercise ID: ${newExercise.id}");
          print("  - Old exercise ID: $_oldExerciseIdForReplacement");

          //  UŻYJ POPRAWNEJ METODY restoreExerciseDataWithTransfer
          _selectedExerciseListKey.currentState
              ?.restoreExerciseDataWithTransfer(
                newExerciseId: newExercise.id,
                oldExerciseId: _oldExerciseIdForReplacement!,
                savedData: _pendingReplacementData!,
              );

          _pendingReplacementData = null;
          _oldExerciseIdForReplacement = null;

          print(
            "✅ Exercise replacement completed: ${oldExercise.name} → ${newExercise.name}",
          );

          ToastUtils.showSuccessToast(
            context: context,
            message: "Zamieniono ${oldExercise.name} na ${newExercise.name}",
          );
        });
      }
    } else {
      //  UŻYTKOWNIK ANULOWAŁ - PRZYWRÓĆ STARE ĆWICZENIE
      print("❌ Exercise replacement cancelled - restoring old exercise");
      setState(() {
        selectedExercise.add(oldExercise);
      });
      //  PRZYWRÓĆ DANE STAREGO ĆWICZENIA
      if (_pendingReplacementData != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          //  UŻYJ POPRAWNEJ METODY restoreExerciseDataWithTransfer
          _selectedExerciseListKey.currentState
              ?.restoreExerciseDataWithTransfer(
                newExerciseId: oldExercise.id,
                oldExerciseId: _oldExerciseIdForReplacement!,
                savedData: _pendingReplacementData!,
              );

          _pendingReplacementData = null;
          _oldExerciseIdForReplacement = null;
        });
      }

      ToastUtils.showInfoToast(
        context: context,
        message: "Anulowano zamianę ćwiczenia",
      );
    }
  }

  /// Dodaje nowe ćwiczenie do planu
  Future<void> _addExerciseToPlan() async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder:
            (ctx) => ExercisesScreen(
              isSelectionMode: true,
              title: 'Wybierz ćwiczenie do planu',
              onMultipleExercisesSelected: (exercises) {
                print('Otrzymano ${exercises.length} ćwiczeń');
              },
            ),
      ),
    );

    if (result != null) {
      setState(() {
        if (result is List<Exercise>) {
          //  LISTA ĆWICZEŃ - DODAJ WSZYSTKIE
          int addedCount = 0;
          for (final exercise in result) {
            if (!selectedExercise.any(
              (existing) => existing.id == exercise.id,
            )) {
              selectedExercise.add(exercise);
              addedCount++;
            }
          }
          print(
            'Dodano $addedCount nowych ćwiczeń do planu (z ${result.length} otrzymanych)',
          );
        } else if (result is Exercise) {
          //  POJEDYNCZE ĆWICZENIE - DODAJ JEDNO
          if (!selectedExercise.any((existing) => existing.id == result.id)) {
            selectedExercise.add(result);
            print('Dodano ćwiczenie: ${result.name}');
          } else {
            print('Ćwiczenie ${result.name} już istnieje w planie');
          }
        }
      });
    }
  }

  /// Usuwa ćwiczenie z planu
  void _removeExerciseFromPlan(Exercise exercise) {
    setState(() {
      selectedExercise.remove(exercise);
    });
    print("🗑️ Usunięto ćwiczenie z planu: ${exercise.name}");
  }

  /// ✅ OBSŁUGA ZMIANY KOLEJNOŚCI ĆWICZEŃ
  void _onExercisesReordered(List<Exercise> reorderedExercises) {
    setState(() {
      selectedExercise = reorderedExercises;
    });
    print(
      "🔄 Zmieniono kolejność ćwiczeń: ${reorderedExercises.map((e) => e.name).join(', ')}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey("plan_creation_$_widgetKey"),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBackPress,
        ),
        title: Text(_isEditMode ? "Edytuj Plan" : "Stwórz Plan"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: _isPlanReadToSave ? () => _savePlanData(ref) : null,
              child: Text(
                _isEditMode ? "Aktualizuj" : "Zapisz",
                style: TextStyle(
                  color: _isPlanReadToSave
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Listener(
                onPointerMove: (event) {
          SelectedExerciseListState.globalPointerDy = event.position.dy;
          SelectedExerciseListState.globalAutoScrollCallback?.call();
          
        },
        onPointerUp: (_) {
          SelectedExerciseListState.globalPointerDy = null;
          SelectedExerciseListState.globalStopAutoScrollCallback?.call();
           _selectedExerciseListKey.currentState?.resetDragging();
        },
        child: CustomScrollView(
          key: ValueKey("plan_creation_$_widgetKey"),
          slivers: [
            if(selectedExercise.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                child: PlanTitleField(
                  key: _planTitleFieldKey,
                  initialValue: exerciseTableTitle, 
                  onChanged: _onPlanTitleChanged,
                  isEditMode: _isEditMode,
                  
                  // editPlanName: widget.planToEdit?.exercise_table,
                ),
              ),
            ),
        
            //  RESZTA WIDOKU POZOSTAJE BEZ ZMIAN
            selectedExercise.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState())
                : SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Listener(
                        onPointerMove: (event) {
                          SelectedExerciseListState.globalPointerDy = event.position.dy;
                          SelectedExerciseListState.globalAutoScrollCallback?.call();
                        },
                        onPointerUp: (_) {
                          SelectedExerciseListState.globalPointerDy = null;
                          SelectedExerciseListState.globalStopAutoScrollCallback?.call();
                        },
                        child: SelectedExerciseList(
                          key: _selectedExerciseListKey,
                          onGetTableData: (getterFunction) {
                            _getTableData = getterFunction;
                          },
                          exercises: selectedExercise,
                          onDelete: _removeExerciseFromPlan,
                          initialData: widget.planToEdit != null ? _extractInitialData() : null,
                          initialNotes: widget.planToEdit != null ? _extractInitialNotes() : null,
                          onExercisesReordered: _onExercisesReordered,
                          onReplaceExercise: _handleExerciseReplacement,
                          mainScrollController: _mainScrollController,
                        ),
                      ),
                    ),
                  ),
        
          if (selectedExercise.isNotEmpty)
  SliverToBoxAdapter(
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      child: ExerciseSelectionButton(onPressed: _addExerciseToPlan),
    ),
  ),
             
          ],
        ),
      ),
    );
  }

  /// Buduje stan pusty gdy brak ćwiczeń
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "Brak dodanych ćwiczeń",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Użyj przycisku poniżej, aby dodać pierwsze ćwiczenie",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),

          ExerciseSelectionButton(onPressed: _addExerciseToPlan),
        ],
      ),
    );
  }
}
