import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
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
  final int colRep;
  final bool isChecked;
   final String exerciseNumber; 
   final bool isFailure;
  ExerciseRowState({

    required this.colStep,
    required this.colKg,
    required this.colRep,
    required this.isChecked,
    required this.exerciseNumber,
    this.isFailure = false,
  });
   @override
  String toString() {
    return 'ExerciseRowState(colStep: $colStep, colKg: $colKg, colRep: $colRep,isFailure: $isFailure, isChecked: $isChecked, exerciseNumber: $exerciseNumber)';
  }

  Map<String, dynamic> toJson() => {
    'colStep': colStep,
    'colKg': colKg,
    'colRep': colRep,
    'isFailure': isFailure,
    'isChecked': isChecked,
  };

  factory ExerciseRowState.fromJson(Map<String, dynamic> json) => ExerciseRowState(
    colStep: json['colStep'],
    colKg: json['colKg'],
    colRep: json['colRep'],
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

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('workout_plan_state', json.encode(state.toJson()));
  }

  void updateRow(int planId, ExerciseRowState rowState) {
    // print('updateRow: $rowState');
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
    // print('Stan planu po updateRow: ${state.plans[planId]}');
  }

  void setPlanRows(int planId, List<ExerciseRowState> rows) {
    //  print('setPlanRows: $rows');
    state = state.copyWith(plans: {...state.plans, planId: rows});
    _saveToPrefs();
    // print('Stan planu po setPlanRows: ${state.plans[planId]}');
  }

  List<ExerciseRowState> getRows(int planId) {
    return state.plans[planId] ?? [];
  }

  void clearPlan(int planId) {
    final newPlans = {...state.plans};
    newPlans.remove(planId);
    state = state.copyWith(plans: newPlans);
    _saveToPrefs();
  }
}

final workoutPlanStateProvider = StateNotifierProvider<WorkoutPlanStateNotifier, WorkoutPlanState>(
  (ref) => WorkoutPlanStateNotifier(),
);
