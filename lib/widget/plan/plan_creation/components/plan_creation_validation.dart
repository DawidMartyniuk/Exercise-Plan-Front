import 'package:work_plan_front/model/exercise.dart';

class PlanCreationValidation {
  /// Waliduje podstawowe dane planu
  static bool validatePlanData(String planTitle, List<Exercise> exercises) {
    return planTitle.trim().isNotEmpty && exercises.isNotEmpty;
  }

  /// Waliduje tytuł planu
  static ValidationResult validatePlanTitle(String title) {
    final errors = <String>[];
    
    if (title.trim().isEmpty) {
      errors.add("Nazwa planu jest wymagana");
    }
    
    if (title.length > 100) {
      errors.add("Nazwa planu nie może być dłuższa niż 100 znaków");
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Waliduje listę ćwiczeń
  static ValidationResult validateExercises(List<Exercise> exercises) {
    final errors = <String>[];
    
    if (exercises.isEmpty) {
      errors.add("Plan musi zawierać przynajmniej jedno ćwiczenie");
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });
}