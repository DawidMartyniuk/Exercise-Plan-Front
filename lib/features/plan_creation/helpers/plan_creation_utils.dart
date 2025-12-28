import 'package:work_plan_front/model/exercise.dart';

class PlanCreationUtils {
  /// Sprawdza czy ćwiczenie już istnieje w planie
  static bool isExerciseAlreadyAdded(List<Exercise> selectedExercises, Exercise exercise) {
    return selectedExercises.any((selected) => selected.id == exercise.id);
  }

  /// Generuje unikalny identyfikator dla nowego setu
  static String generateSetId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Formatuje nazwę planu usuwając zbędne spacje
  static String formatPlanTitle(String title) {
    return title.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Sprawdza czy plan ma wystarczające dane do zapisania
  static bool isPlanReadyToSave({
    required String planTitle,
    required List<Exercise> exercises,
    required Map<String, List<Map<String, String>>> tableData,
  }) {
    if (planTitle.trim().isEmpty) return false;
    if (exercises.isEmpty) return false;
    
    // Sprawdź czy każde ćwiczenie ma przynajmniej jeden set
    for (final exercise in exercises) {
      final exerciseData = tableData[exercise.id] ?? [];
      if (exerciseData.isEmpty) return false;
      
      // Sprawdź czy przynajmniej jeden set ma dane
          final hasValidSet = exerciseData.any((row) {
        final kg = int.tryParse(row["colKg"] ?? "0") ?? 0;
        final reps = int.tryParse(row["colRepMin"] ?? "0") ?? 0; // ✅ ZMIENIONE z colRep
        return kg > 0 || reps > 0;
      });
      
      if (!hasValidSet) return false;
    }
    
    return true;
  }

  /// Liczy całkowitą liczbę setów w planie
  static int getTotalSets(Map<String, List<Map<String, String>>> tableData) {
    return tableData.values
        .expand((rows) => rows)
        .where((row) {
          final kg = int.tryParse(row["colKg"] ?? "0") ?? 0;
          final reps = int.tryParse(row["colRep"] ?? "0") ?? 0;
          return kg > 0 || reps > 0;
        })
        .length;
  }

  /// Liczy całkowitą liczbę powtórzeń w planie
  static int getTotalReps(Map<String, List<Map<String, String>>> tableData) {
    return tableData.values
        .expand((rows) => rows)
        .map((row) => int.tryParse(row["colRep"] ?? "0") ?? 0)
        .fold(0, (sum, reps) => sum + reps);
  }

  /// Liczy całkowity ciężar w planie
  static double getTotalWeight(Map<String, List<Map<String, String>>> tableData) {
    return tableData.values
        .expand((rows) => rows)
        .map((row) {
          final kg = double.tryParse(row["colKg"] ?? "0") ?? 0;
          final repsMin = int.tryParse(row["colRepMin"] ?? "0") ?? 0;
          final repsMax = int.tryParse(row["colRepMax"] ?? "0") ?? 0;
          return kg * (repsMin + repsMax) / 2;
        })
        .fold(0.0, (sum, weight) => sum + weight);
  }

  /// Generuje podsumowanie planu
  static Map<String, dynamic> getPlanSummary({
    required String planTitle,
    required List<Exercise> exercises,
    required Map<String, List<Map<String, String>>> tableData,
  }) {
    return {
      'title': planTitle,
      'exerciseCount': exercises.length,
      'totalSets': getTotalSets(tableData),
      'totalReps': getTotalReps(tableData),
      'totalWeight': getTotalWeight(tableData),
      'estimatedDuration': _estimateDuration(exercises.length, getTotalSets(tableData)),
    };
  }

  /// Szacuje czas trwania treningu (w minutach)
  static int _estimateDuration(int exerciseCount, int totalSets) {
    // Przybliżenie: 2-3 minuty na set + czas na przygotowanie ćwiczeń
    const int minutesPerSet = 3;
    const int setupTimePerExercise = 2;
    
    return (totalSets * minutesPerSet) + (exerciseCount * setupTimePerExercise);
  }

  /// Sprawdza czy tytuł planu jest unikalny (można rozszerzyć o sprawdzanie w bazie)
  static bool isPlanTitleUnique(String title, List<String> existingTitles) {
    final formattedTitle = formatPlanTitle(title).toLowerCase();
    return !existingTitles
        .map((t) => t.toLowerCase())
        .contains(formattedTitle);
  }
}