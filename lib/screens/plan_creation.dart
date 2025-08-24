import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/provider/ExercisePlanNotifier.dart';
import 'package:work_plan_front/screens/exercises.dart';
import 'package:work_plan_front/screens/tabs.dart';
import 'package:work_plan_front/widget/plan/plan_creation/selected_exercise_list.dart';
import 'package:work_plan_front/widget/plan/plan_creation/widgets/plan_title_field.dart';
import 'package:work_plan_front/widget/plan/plan_creation/widgets/exercise_selection_button.dart';
import 'package:work_plan_front/widget/plan/plan_creation/helpers/data_formatter.dart';
import 'package:work_plan_front/widget/plan/plan_creation/components/plan_creation_validation.dart';
import 'package:work_plan_front/utils/toast_untils.dart';

class PlanCreation extends ConsumerStatefulWidget {
  const PlanCreation({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _StatePlanCreation();
  }
}

class _StatePlanCreation extends ConsumerState<PlanCreation> {
  List<Exercise> selectedExercise = [];
  Map<String, List<Map<String, String>>> Function()? _getTableData;
  String exerciseTableTitle = "";
  
  // ✅ DODAJ GLOBALKEY
  final GlobalKey<SelectedExerciseListState> _selectedExerciseListKey = 
      GlobalKey<SelectedExerciseListState>();

  bool get _isPlanReadToSave {
    return PlanCreationValidation.validatePlanData(
      exerciseTableTitle,
      selectedExercise,
    );
  }

  /// Zapisuje dane planu treningowego
  void _savePlanData() async {
    print("💾 Starting plan save process...");

    if (!_isPlanReadToSave) {
      ToastUtils.showValidationError(context,
          customMessage: "Wypełnij tytuł planu i dodaj przynajmniej jedno ćwiczenie");
      return;
    }

    if (_getTableData == null) {
      ToastUtils.showErrorToast(context: context, message: "Brak danych tabeli");
      return;
    }

    try {
      // ✅ POBIERZ I POKAŻ SUROWE DANE
      final tableData = _getTableData!();
      
      print("🔍 Raw table data:");
      tableData.forEach((exerciseId, rows) {
        print("  - Exercise $exerciseId:");
        for (int i = 0; i < rows.length; i++) {
          print("    - Set ${i + 1}: ${rows[i]}");
        }
      });

      // ✅ UTWÓRZ MAPĘ NAZW ĆWICZEŃ
      final exerciseNames = <String, String>{};
      for (final exercise in selectedExercise) {
        exerciseNames[exercise.id] = exercise.name;
      }
      print("🔍 Exercise names: $exerciseNames");

      // ✅ FORMATUJ Z NAZWAMI ĆWICZEŃ
      final payload = DataFormatter.formatPlanDataWithNames(
        tableData: tableData,
        planTitle: exerciseTableTitle,
        exerciseNames: exerciseNames,
      );

      print("📤 Final payload to send:");
      print("  - Structure: ${payload.keys.toList()}");
      print("  - Full payload: $payload");

      // Zapisywanie planu
      final exercisePlanNotifier = ref.read(exercisePlanProvider.notifier);
      await exercisePlanNotifier.initializeExercisePlan(payload);

      final statusCode = await exercisePlanNotifier.saveExercisePlan(
          onlyThis: exercisePlanNotifier.state.last);

      if (statusCode == 200 || statusCode == 201) {
        await _handleSaveSuccess();
      } else {
        _handleSaveError("Status: $statusCode");
      }
    } catch (e) {
      _handleSaveError(e.toString());
    }
  }

  /// Obsługuje pomyślne zapisanie planu
  Future<void> _handleSaveSuccess() async {
    ToastUtils.showSaveSuccess(context, itemName: "Plan treningowy");
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
    ToastUtils.showErrorToast(
      context: context,
      message: "Nie udało się zapisać planu. Spróbuj ponownie.",
    );
    print("Błąd zapisywania planu: $error");
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
      builder: (context) => AlertDialog(
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
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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

  /// Dodaje nowe ćwiczenie do planu
  Future<void> _addExerciseToPlan() async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (ctx) => ExercisesScreen(
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
          // ✅ LISTA ĆWICZEŃ - DODAJ WSZYSTKIE
          int addedCount = 0;
          for (final exercise in result) {
            if (!selectedExercise.any((existing) => existing.id == exercise.id)) {
              selectedExercise.add(exercise);
              addedCount++;
            }
          }
          print('Dodano $addedCount nowych ćwiczeń do planu (z ${result.length} otrzymanych)');
        } else if (result is Exercise) {
          // ✅ POJEDYNCZE ĆWICZENIE - DODAJ JEDNO
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

  /// ✅ NOWA METODA - OBSŁUGA ZMIANY KOLEJNOŚCI ĆWICZEŃ
  void _onExercisesReordered(List<Exercise> reorderedExercises) {
    setState(() {
      selectedExercise = reorderedExercises;
    });
    print("🔄 Zmieniono kolejność ćwiczeń: ${reorderedExercises.map((e) => e.name).join(', ')}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBackPress,
        ),
        title: const Text("Plan Creation"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: _isPlanReadToSave ? _savePlanData : null,
              child: Text(
                "Save",
                style: TextStyle(
                  color: _isPlanReadToSave
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pole tytułu planu
            PlanTitleField(
              initialValue: exerciseTableTitle,
              onChanged: (value) => setState(() => exerciseTableTitle = value),
            ),

            const SizedBox(height: 20),

            // ✅ DODAJ INSTRUKCJĘ O PRZECIĄGANIU (opcjonalnie)
            if (selectedExercise.length > 1) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.drag_handle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Przeciągnij ćwiczenia aby zmienić ich kolejność w planie",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Lista wybranych ćwiczeń lub komunikat o braku ćwiczeń
            Expanded(
              child: selectedExercise.isEmpty
                  ? _buildEmptyState()
                  : SelectedExerciseList(
                      key: _selectedExerciseListKey, // ✅ DODAJ KEY
                      onGetTableData: (getterFunction) {
                        _getTableData = getterFunction; // ✅ ZAPISZ FUNKCJĘ BEZPOŚREDNIO
                      },
                      exercises: selectedExercise,
                      onDelete: _removeExerciseFromPlan,
                      onExercisesReordered: _onExercisesReordered,
                    ),
            ),

            // Przycisk dodawania ćwiczeń
            ExerciseSelectionButton(
              onPressed: _addExerciseToPlan,
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
        ],
      ),
    );
  }
}