import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class WorkoutPlanState {

  final Map<int, List<ExerciseRowState>> plans;

  WorkoutPlanState({required this.plans});

  // Dodaj getter getRows
  List<ExerciseRowState> getRows(int planId) {
    return plans[planId] ?? [];
  }

  WorkoutPlanState copyWith({Map<int, List<ExerciseRowState>>? plans}) {
    return WorkoutPlanState(plans: plans ?? this.plans);
  }

  Map<String, dynamic> toJson() => {
    'plans': plans.map((k, v) => MapEntry(k.toString(), v.map((e) => e.toJson()).toList())),
  };

  factory WorkoutPlanState.fromJson(Map<String, dynamic> json) {
    final plansJson = json['plans'] as Map<String, dynamic>? ?? {};
    return WorkoutPlanState(
      plans: plansJson.map((k, v) => MapEntry(
        int.parse(k),
        (v as List).map((e) => ExerciseRowState.fromJson(e)).toList(),
      )),
    );
  }
}

class ExerciseRowState {
  final int colStep;
  final int colKg;
  final int colRepMin;
  final int colRepMax;
  final bool isChecked;
   final String exerciseNumber; 
   final bool isFailure;
  ExerciseRowState({

    required this.colStep,
    required this.colKg,
    required this.colRepMin,
    required this.colRepMax,
    required this.isChecked,
    required this.exerciseNumber,
    this.isFailure = false,
  });
   @override
  String toString() {
    return 'ExerciseRowState(colStep: $colStep, colKg: $colKg, colRepMin: $colRepMin, colRepMax: $colRepMax, isFailure: $isFailure, isChecked: $isChecked, exerciseNumber: $exerciseNumber)';
  }

  Map<String, dynamic> toJson() => {
    'colStep': colStep,
    'colKg': colKg,
    'colRepMin': colRepMin,
    'colRepMax': colRepMax,
    'isFailure': isFailure,
    'isChecked': isChecked,
    'exerciseNumber': exerciseNumber, 
  };

  factory ExerciseRowState.fromJson(Map<String, dynamic> json) => ExerciseRowState(
    colStep: json['colStep'],
    colKg: json['colKg'],
    colRepMin: json['colRepMin'],
    colRepMax: json['colRepMax'],
    isFailure: json['isFailure'] ?? false,
    isChecked: json['isChecked'],
    exerciseNumber: json['exerciseNumber'] ?? "Unknown Number",
  );
}

class WorkoutPlanStateNotifier extends StateNotifier<WorkoutPlanState> {
  WorkoutPlanStateNotifier() : super(WorkoutPlanState(plans: {})) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('workout_plan_state');
    if (jsonString != null) {
      state = WorkoutPlanState.fromJson(json.decode(jsonString));
    }
  }

  void clearPlan(int planId) {
    final updatedPlans = Map<int, List<ExerciseRowState>>.from(state.plans);
    updatedPlans.remove(planId);
    
    state = state.copyWith(plans: updatedPlans);
    _saveToPrefs();
    
    print("🗑️ Wyczyszczono workout state dla planu ID: $planId");
  }

  void updatePlan(int planId, List<ExerciseRowState> updatedRows) {
    final updatedPlans = Map<int, List<ExerciseRowState>>.from(state.plans);
    updatedPlans[planId] = updatedRows;
    state = state.copyWith(plans: updatedPlans);
    _saveToPrefs();
    print("✅ Zaktualizowano plan ID: $planId");
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('workout_plan_state', json.encode(state.toJson()));
  }

  void updateRow(int planId, ExerciseRowState rowState) {
    final planRows = List<ExerciseRowState>.from(state.plans[planId] ?? []);
    final idx = planRows.indexWhere((e) =>
      e.colStep == rowState.colStep &&
      e.exerciseNumber == rowState.exerciseNumber
    );
    if (idx >= 0) {
      planRows[idx] = rowState;
    } else {
      planRows.add(rowState);
    }
    state = state.copyWith(plans: {...state.plans, planId: planRows});
    
    _saveToPrefs();
  }

  void setPlanRows(int planId, List<ExerciseRowState> rows) {
    state = state.copyWith(plans: {...state.plans, planId: rows});
    _saveToPrefs();
  }

  List<ExerciseRowState> getRows(int planId) {
    return state.plans[planId] ?? [];
  }

  // ✅ DODANA BRAKUJĄCA METODA removeExercise
  void removeExercise(int planId, String exerciseNumber) {
    print("🗑️ Usuwanie ćwiczenia $exerciseNumber z planu $planId");
    
    final planRows = List<ExerciseRowState>.from(state.plans[planId] ?? []);
    final originalCount = planRows.length;
    
    // Usuń wszystkie wiersze dla danego ćwiczenia
    planRows.removeWhere((row) => row.exerciseNumber == exerciseNumber);
    
    final removedCount = originalCount - planRows.length;
    print("🗑️ Usunięto $removedCount wierszy dla ćwiczenia $exerciseNumber");
    
    // Zaktualizuj stan
    state = state.copyWith(plans: {...state.plans, planId: planRows});
    _saveToPrefs();
    
    print("✅ Stan zaktualizowany: plan $planId ma teraz ${planRows.length} wierszy");
  }

  // ✅ DODATKOWA METODA - usuń konkretny wiersz
  void removeRow(int planId, int colStep, String exerciseNumber) {
    print("🗑️ Usuwanie wiersza: planId=$planId, step=$colStep, exercise=$exerciseNumber");
    
    final planRows = List<ExerciseRowState>.from(state.plans[planId] ?? []);
    final originalCount = planRows.length;
    
    planRows.removeWhere((row) => 
        row.colStep == colStep && 
        row.exerciseNumber == exerciseNumber
    );
    
    final removedCount = originalCount - planRows.length;
    print("🗑️ Usunięto $removedCount wiersz");
    
    state = state.copyWith(plans: {...state.plans, planId: planRows});
    _saveToPrefs();
  }

  //  DODATKOWA METODA - sprawdź czy ćwiczenie istnieje w planie
  bool hasExercise(int planId, String exerciseNumber) {
    final planRows = state.plans[planId] ?? [];
    return planRows.any((row) => row.exerciseNumber == exerciseNumber);
  }

  //  DODATKOWA METODA - pobierz wiersze dla konkretnego ćwiczenia
  List<ExerciseRowState> getExerciseRows(int planId, String exerciseNumber) {
    final planRows = state.plans[planId] ?? [];
    return planRows.where((row) => row.exerciseNumber == exerciseNumber).toList();
  }

  //  DODATKOWA METODA - dodaj nowe ćwiczenie do planu
  void addExercise(int planId, String exerciseNumber, {int initialStep = 1, int initialKg = 0, int initialRep = 0}) {
    print("➕ Dodawanie ćwiczenia $exerciseNumber do planu $planId");
    
    final planRows = List<ExerciseRowState>.from(state.plans[planId] ?? []);
    
    // Sprawdź czy ćwiczenie już nie istnieje
    if (planRows.any((row) => row.exerciseNumber == exerciseNumber)) {
      print("⚠️ Ćwiczenie $exerciseNumber już istnieje w planie $planId");
      return;
    }
    
    // Dodaj nowy wiersz
    planRows.add(ExerciseRowState(
      colStep: initialStep,
      colKg: initialKg,
      colRepMin: initialRep,
      colRepMax: initialRep,
      isChecked: false,
      isFailure: false,
      exerciseNumber: exerciseNumber,
    ));
    
    state = state.copyWith(plans: {...state.plans, planId: planRows});
    _saveToPrefs();
    
    print("✅ Dodano ćwiczenie $exerciseNumber do planu $planId");
  }

  // ✅ DEBUG - wyświetl stan planu
  void debugPlan(int planId) {
    final planRows = state.plans[planId] ?? [];
    print("🔍 DEBUG Plan $planId:");
    print("  - Łącznie wierszy: ${planRows.length}");
    
    final exerciseGroups = <String, int>{};
    for (final row in planRows) {
      exerciseGroups[row.exerciseNumber] = (exerciseGroups[row.exerciseNumber] ?? 0) + 1;
    }
    
    exerciseGroups.forEach((exerciseNumber, count) {
      print("  - Ćwiczenie $exerciseNumber: $count wierszy");
    });
  }
}

final workoutPlanStateProvider = StateNotifierProvider<WorkoutPlanStateNotifier, WorkoutPlanState>(
  (ref) => WorkoutPlanStateNotifier(),
);
