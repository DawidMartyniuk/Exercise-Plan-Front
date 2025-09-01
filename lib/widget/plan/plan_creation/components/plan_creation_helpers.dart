import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/utils/toast_untils.dart';

class PlanCreationHelpers {
  /// Pokazuje dialog potwierdzenia wyjścia bez zapisania
  static Future<bool> showUnsavedChangesDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          "Niezapisane zmiany",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          "Czy na pewno chcesz wyjść? Wszystkie wprowadzone zmiany zostaną utracone.",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              "Anuluj",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              "Wyjdź bez zapisywania",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Pokazuje dialog potwierdzenia usunięcia ćwiczenia
  static Future<bool> showRemoveExerciseDialog(BuildContext context, Exercise exercise) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          "Usuń ćwiczenie",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          "Czy na pewno chcesz usunąć ćwiczenie \"${exercise.name}\" z planu? Wszystkie wprowadzone dane zostaną utracone.",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              "Anuluj",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              "Usuń",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Sprawdza czy można dodać ćwiczenie (czy nie jest już dodane)
  static bool canAddExercise(List<Exercise> selectedExercises, Exercise exercise) {
    return !selectedExercises.any((selected) => selected.id == exercise.id);
  }

  /// Pokazuje toast o próbie dodania duplikatu ćwiczenia
  static void showDuplicateExerciseToast(BuildContext context, Exercise exercise) {
    ToastUtils.showWarningToast(
      context: context,
      title: "Ćwiczenie już dodane",
      message: "\"${exercise.name}\" jest już w planie treningowym.",
    );
  }

  /// Generuje domyślne sety dla nowego ćwiczenia
  static List<Map<String, String>> generateDefaultSets({int count = 1}) {
    return List.generate(count, (index) => {
      "colStep": "${index + 1}",
     "colRepMin": "0", // ✅ ZMIENIONE z colRep
      "colRepMax": "0", // ✅ DODAJ TO
    });
  }

  /// Formatuje czas szacowanego treningu
  static String formatEstimatedDuration(int minutes) {
    if (minutes < 60) {
      return "${minutes}min";
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return "${hours}h";
      } else {
        return "${hours}h ${remainingMinutes}min";
      }
    }
  }

  /// Sprawdza czy plan jest gotowy do zapisania i pokazuje odpowiednie komunikaty
  static bool validateAndShowErrors(BuildContext context, {
    required String planTitle,
    required List<Exercise> exercises,
    required Map<String, List<Map<String, String>>> tableData,
  }) {
    if (planTitle.trim().isEmpty) {
      ToastUtils.showValidationError(
        context,
        customMessage: "Wprowadź nazwę planu treningowego",
      );
      return false;
    }

    if (exercises.isEmpty) {
      ToastUtils.showValidationError(
        context,
        customMessage: "Dodaj przynajmniej jedno ćwiczenie do planu",
      );
      return false;
    }

    // Sprawdź czy każde ćwiczenie ma przynajmniej jeden poprawny set
    for (final exercise in exercises) {
      final exerciseData = tableData[exercise.id] ?? [];
      if (exerciseData.isEmpty) {
        ToastUtils.showValidationError(
          context,
          customMessage: "Ćwiczenie \"${exercise.name}\" nie ma żadnych setów",
        );
        return false;
      }

      final hasValidSet = exerciseData.any((row) {
        final kg = double.tryParse(row["colKg"] ?? "0") ?? 0;
        final repsMin = int.tryParse(row["colRepMin"] ?? "0") ?? 0;
        final repsMax = int.tryParse(row["colRepMax"] ?? "0") ?? 0;
        return kg > 0 && repsMin > 0 && repsMax > 0;
      });

      if (!hasValidSet) {
        ToastUtils.showValidationError(
          context,
          customMessage: "Ćwiczenie \"${exercise.name}\" musi mieć przynajmniej jeden set z wagą i powtórzeniami",
        );
        return false;
      }
    }

    return true;
  }

  /// Pokazuje podsumowanie przed zapisaniem planu
  static Future<bool> showSavePlanSummary(BuildContext context, {
    required String planTitle,
    required List<Exercise> exercises,
    required Map<String, List<Map<String, String>>> tableData,
  }) async {
    final totalSets = tableData.values
        .expand((rows) => rows)
        .where((row) {
          final kg = double.tryParse(row["colKg"] ?? "0") ?? 0;
          final reps = int.tryParse(row["colRep"] ?? "0") ?? 0;
          return kg > 0 && reps > 0;
        })
        .length;

    final totalReps = tableData.values
        .expand((rows) => rows)
        .map((row) => int.tryParse(row["colRep"] ?? "0") ?? 0)
        .fold(0, (sum, reps) => sum + reps);

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          "Podsumowanie planu",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nazwa: $planTitle",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Ćwiczenia: ${exercises.length}",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            Text(
              "Łączna liczba setów: $totalSets",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            Text(
              "Łączna liczba powtórzeń: $totalReps",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            Text(
              "Czy chcesz zapisać ten plan?",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              "Anuluj",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              "Zapisz plan",
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    ) ?? false;
  }
}