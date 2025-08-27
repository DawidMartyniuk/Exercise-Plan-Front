import 'package:work_plan_front/model/exercise_plan.dart';

class PlanValidation {
  // ✅ WALIDACJA PLANU
  static ValidationResult validatePlan(ExerciseTable plan) {
    final errors = <String>[];
    final warnings = <String>[];

    // Sprawdź czy plan ma nazwę
    if (plan.exercise_table.isEmpty) {
      errors.add("Plan name is required");
    }

    // Sprawdź czy plan ma ćwiczenia
    if (plan.rows.isEmpty) {
      errors.add("Plan must have at least one exercise");
    }

    // Sprawdź każde ćwiczenie
    for (int i = 0; i < plan.rows.length; i++) {
      final exercise = plan.rows[i];
      final exerciseErrors = validateExercise(exercise, i + 1);
      errors.addAll(exerciseErrors.errors);
      warnings.addAll(exerciseErrors.warnings);
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // ✅ WALIDACJA ĆWICZENIA
  static ValidationResult validateExercise(ExerciseRowsData exercise, int exerciseNumber) {
    final errors = <String>[];
    final warnings = <String>[];

    // Sprawdź czy ćwiczenie ma serie
    if (exercise.data.isEmpty) {
      errors.add("Exercise $exerciseNumber must have at least one set");
    }

    // Sprawdź każdą serię
    for (int i = 0; i < exercise.data.length; i++) {
      final set = exercise.data[i];
      final setErrors = validateSet(set, exerciseNumber, i + 1);
      errors.addAll(setErrors.errors);
      warnings.addAll(setErrors.warnings);
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // ✅ WALIDACJA SERII
  static ValidationResult validateSet(ExerciseRow set, int exerciseNumber, int setNumber) {
    final errors = <String>[];
    final warnings = <String>[];

    // Sprawdź wagę
    if (set.colKg < 0) {
      errors.add("Exercise $exerciseNumber, Set $setNumber: Weight cannot be negative");
    }
    if (set.colKg == 0) {
      warnings.add("Exercise $exerciseNumber, Set $setNumber: Weight is 0");
    }

    // Sprawdź powtórzenia
    if (set.colRepMin <= 0) {
      errors.add("Exercise $exerciseNumber, Set $setNumber: Reps must be greater than 0");
    }

    // Sprawdź czy seria jest sensowna
    if (set.colRepMax > 100) {
      warnings.add("Exercise $exerciseNumber, Set $setNumber: Very high rep count (${set.colRepMax})");
    }

    if (set.colKg > 600) {
      warnings.add("Exercise $exerciseNumber, Set $setNumber: Very high weight (${set.colKg}kg)");
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // ✅ WALIDACJA INPUTÓW
  static String? validateWeightInput(String input) {
    if (input.isEmpty) return "Weight is required";
    
    final weight = double.tryParse(input);
    if (weight == null) return "Invalid weight format";
    if (weight < 0) return "Weight cannot be negative";
    if (weight > 1000) return "Weight seems too high";
    
    return null;
  }

  static String? validateRepsInput(String input) {
    if (input.isEmpty) return "Reps is required";
    
    final reps = int.tryParse(input);
    if (reps == null) return "Invalid reps format";
    if (reps <= 0) return "Reps must be greater than 0";
    if (reps > 200) return "Reps seems too high";
    
    return null;
  }

  // ✅ SPRAWDZENIE CZY WORKOUT MOŻE BYĆ ZAKOŃCZONY
  static bool canCompleteWorkout(ExerciseTable plan) {
    // Sprawdź czy przynajmniej jedna seria została wykonana
    return plan.rows.any((exercise) => 
        exercise.data.any((set) => set.isChecked));
  }

  // ✅ SPRAWDZENIE CZY PLAN JEST PUSTY
  static bool isPlanEmpty(ExerciseTable plan) {
    return plan.rows.isEmpty || 
           plan.rows.every((exercise) => exercise.data.isEmpty);
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
}