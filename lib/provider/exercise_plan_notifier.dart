import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/reps_type.dart';
import 'package:work_plan_front/model/weight_type.dart';
import 'package:work_plan_front/services/exercisePlan.dart';
import 'package:work_plan_front/services/exercise_plan_local_service.dart';
import 'package:work_plan_front/core/auth/token_storage.dart';

class ExercisePlanNotifier extends StateNotifier<List<ExerciseTable>> {
  ExercisePlanNotifier({required ExercisePlanService exerciseService})
      : _exerciseService = exerciseService,
        super([]);

  final ExercisePlanService _exerciseService;

  static const String _boxName = 'plansBox';
  

  Future<void> _savePlansToHive() async {
    final box = await Hive.openBox<ExerciseTable>(_boxName);
    await box.clear(); // nadpisz całość
    for (final plan in state) {
      await box.put(plan.id, plan);
    }
    print("💾 Plany zapisane do Hive: ${state.length}");
  }

  Future<void> _loadPlansFromHive() async {
    final box = await Hive.openBox<ExerciseTable>(_boxName);
    state = box.values.toList();
    print("📥 Plany załadowane z Hive: ${state.length}");
  }

  Future<void> fetchExercisePlans() async {
    try {
      final exercisePlans = await _exerciseService.fetchExercises();

      print("Before assigning to state: ${exercisePlans.runtimeType}");
      state = [...exercisePlans];
      print("After assigning to state: ${state.runtimeType}");
      print("State updated successfully: $state");
    } catch (e) {
      print("Failed to fetch exercise plans: $e");
      state = [];
    }
  }

  Future<int> updateExercisePlan({
    required int exerciseId,
    required String exerciseTableTitle,
    required Map<String, List<Map<String, String>>> tableData,
    required Map<String, String> exerciseNames,
    required Map<String, String> exerciseRepTypes,
    required Map<String, String> exerciseNotes,
    required String weightType,
    List<Exercise>? exerciseOrder,
  }) async {
    try {
      //  SPRAWDŹ CZY PLAN ISTNIEJE
      if (!planExists(exerciseId)) {
        print("❌ Plan with ID $exerciseId does not exist - cannot update");
        throw Exception("Plan with ID $exerciseId not found");
      }

      if (exerciseOrder != null) {
        print("  - Exercise order:");
        for (int i = 0; i < exerciseOrder.length; i++) {
          print(
              "    ${i + 1}. ${exerciseOrder[i].name} (ID: ${exerciseOrder[i].id})");
        }
      }

      final existingPlan = state.firstWhere((plan) => plan.id == exerciseId);
      print("  - OLD Plan title: '${existingPlan.exercise_table}'");

      // FORMATUJ DANE ZGODNIE Z KONTROLEREM SERWERA
      final formattedRows = <Map<String, dynamic>>[];

      if (exerciseOrder != null && exerciseOrder.isNotEmpty) {
        print("📋 Processing exercises in NEW order from exerciseOrder:");

        for (int i = 0; i < exerciseOrder.length; i++) {
          final exercise = exerciseOrder[i];
          final exerciseIdKey = exercise.id;
          final rows = tableData[exerciseIdKey];

          if (rows == null || rows.isEmpty) {
            print("⚠️ No data found for exercise $exerciseIdKey, skipping");
            continue;
          }

          print("  ${i + 1}. Processing exercise: $exerciseIdKey (${exercise.name})");
          print("    - Sets count: ${rows.length}");
          print("    - Rep type: ${exerciseRepTypes[exerciseIdKey]}");

          final formattedData = rows.map((row) {
            final repMin = int.tryParse(row["colRepMin"] ?? "0") ?? 0;
            final repMax = int.tryParse(row["colRepMax"] ?? row["colRepMin"] ?? "0") ?? repMin;

            String cleanWeightType = weightType;
            if (cleanWeightType.startsWith("WeightType.")) {
              cleanWeightType = cleanWeightType.replaceFirst("WeightType.", "");
            }

            return {
              "colStep": int.tryParse(row["colStep"] ?? "1") ?? 1,
              "colKg": _parseWeight(row["colKg"] ?? "0"),
              "colRepMin": repMin,
              "colRepMax": repMax,
              "weight_unit": cleanWeightType,
            };
          }).toList();

          formattedRows.add({
            "exercise_number": exerciseIdKey,
            "exercise_name": exerciseNames[exerciseIdKey] ?? exercise.name,
            "notes": exerciseNotes[exerciseIdKey] ?? "",
            "rep_type": exerciseRepTypes[exerciseIdKey] ?? "single",
            "data": formattedData,
          });
        }
      } else {
        //  FALLBACK - jeśli exerciseOrder jest null
        print("⚠️ No exercise order provided, using default tableData order");

        for (final entry in tableData.entries) {
          final exerciseIdKey = entry.key;
          final rows = entry.value;

          print("  📋 Processing exercise: $exerciseIdKey");
          print("    - Exercise name: ${exerciseNames[exerciseIdKey]}");
          print("    - Sets count: ${rows.length}");
          print("    - Rep type: ${exerciseRepTypes[exerciseIdKey]}");

          final formattedData = rows.map((row) {
            final repMin = int.tryParse(row["colRepMin"] ?? "0") ?? 0;
            final repMax = int.tryParse(row["colRepMax"] ?? row["colRepMin"] ?? "0") ?? repMin;

            String cleanWeightType = weightType;
            if (cleanWeightType.startsWith("WeightType.")) {
              cleanWeightType = cleanWeightType.replaceFirst("WeightType.", "");
            }

            return {
              "colStep": int.tryParse(row["colStep"] ?? "1") ?? 1,
              "colKg": _parseWeight(row["colKg"] ?? "0"),
              "colRepMin": repMin,
              "colRepMax": repMax,
              "weight_unit": cleanWeightType,
            };
          }).toList();

          formattedRows.add({
            "exercise_number": exerciseIdKey,
            "exercise_name": exerciseNames[exerciseIdKey] ?? "Unknown Exercise",
            "notes": exerciseNotes[exerciseIdKey] ?? "",
            "rep_type": exerciseRepTypes[exerciseIdKey] ?? "single",
            "data": formattedData,
          });
        }
      }

      final updatePayload = {
        "exercise_table": exerciseTableTitle, // UŻYJ NOWEJ NAZWY
        "rows": formattedRows,
      };

      print("📤 Sending update payload with title: '$exerciseTableTitle'");

      // ✅ WYWOŁAJ SERWIS
      final response = await _exerciseService.updateExercisePlan(exerciseId, updatePayload);

      print("✅ Update response received from backend:");
      print("  - Message: ${response['message']}");

      //STWÓRZ ZAKTUALIZOWANY PLAN Z NOWĄ NAZWĄ
      print("🔄 Creating updated plan with NEW title: '$exerciseTableTitle'");

      // STWÓRZ NOWE DANE WIERSZY Z LOKALNYCH DANYCH
      final updatedRows = <ExerciseRowsData>[];
      if (exerciseOrder != null && exerciseOrder.isNotEmpty) {
        for (final entry in exerciseOrder) {
          final exerciseId = entry.id;
          final row = tableData[exerciseId];

          final exerciseRowData = row?.map((rowData) {
            final repMin = int.tryParse(rowData["colRepMin"] ?? "0") ?? 0;
            final repMax = int.tryParse(rowData["colRepMax"] ?? rowData["colRepMin"] ?? "0") ?? repMin;

            return ExerciseRow(
              colStep: int.tryParse(rowData["colStep"] ?? "1") ?? 1,
              colKg: _parseWeight(rowData["colKg"] ?? "0"),
              colRepMin: repMin,
              colRepMax: repMax,
              weightType: _getWeightTypeFromString(weightType),
              isChecked: false,
              isFailure: false,
              rowColor: null,
            );
          }).toList();

          updatedRows.add(ExerciseRowsData(
            exercise_name: exerciseNames[exerciseId] ?? "Unknown Exercise",
            exercise_number: exerciseId,
            notes: exerciseNotes[exerciseId] ?? "",
            data: exerciseRowData ?? [],
            rep_type: _parseRepsType(exerciseRepTypes[exerciseId] ?? "single"),
          ));

          print("  ✅ Created updated data for exercise $exerciseId with $exerciseRowData sets");
        }
      } else {
        for (final entry in tableData.entries) {
          final exerciseId = entry.key;
          final rows = entry.value;

          final exerciseRowData = rows.map((rowData) {
            final repMin = int.tryParse(rowData["colRepMin"] ?? "0") ?? 0;
            final repMax = int.tryParse(rowData["colRepMax"] ?? rowData["colRepMin"] ?? "0") ?? repMin;

            return ExerciseRow(
              colStep: int.tryParse(rowData["colStep"] ?? "1") ?? 1,
              colKg: _parseWeight(rowData["colKg"] ?? "0"),
              colRepMin: repMin,
              colRepMax: repMax,
              weightType: _getWeightTypeFromString(weightType),
              isChecked: false,
              isFailure: false,
              rowColor: null,
            );
          }).toList();

          updatedRows.add(ExerciseRowsData(
            exercise_name: exerciseNames[exerciseId] ?? "Unknown Exercise",
            exercise_number: exerciseId,
            notes: exerciseNotes[exerciseId] ?? "",
            data: exerciseRowData,
            rep_type: _parseRepsType(exerciseRepTypes[exerciseId] ?? "single"),
          ));
        }
      }

      final updatedPlan = ExerciseTable(
        id: exerciseId,
        exercise_table: exerciseTableTitle,
        rows: updatedRows,
      );

      print("✅ Updated plan created:");
      print("  - OLD title: '${existingPlan.exercise_table}'");
      print("  - NEW title: '${updatedPlan.exercise_table}'");
      print("  - Exercise groups: ${updatedPlan.rows.length}");

      // ✅ ZAKTUALIZUJ STAN W PROVIDERZE Z NOWĄ NAZWĄ
      state = state.map((plan) {
        if (plan.id == exerciseId) {
          print("🔄 Updating plan in state: '${plan.exercise_table}' -> '${updatedPlan.exercise_table}'");
          return updatedPlan;
        }
        return plan;
      }).toList();

      print("✅ Plan updated in provider state with NEW title");

      //  NATYCHMIASTOWE ODŚWIEŻENIE Z BACKEND DLA SYNCHRONIZACJI
      print("🔄 Immediate refresh from backend to ensure sync...");
      await fetchExercisePlans();
      print("✅ Backend refresh completed");

      return 200; // Success
    } catch (e) {
      print("❌ Failed to update exercise plan: $e");
      rethrow;
    }
  }

  static dynamic _parseWeight(String weightStr) {
    final trimmed = weightStr.trim();
    if (trimmed.isEmpty) return 0;

    if (trimmed.contains('.')) {
      return double.tryParse(trimmed) ?? 0.0;
    } else {
      return int.tryParse(trimmed) ?? 0;
    }
  }

  bool planExists(int planId) {
    return state.any((plan) => plan.id == planId);
  }

  ExerciseTable? getPlanById(int planId) {
    try {
      return state.firstWhere((plan) => plan.id == planId);
    } catch (e) {
      return null;
    }
  }

  Future<void> initializeExercisePlan(Map<String, dynamic> exercisesData) async {
    final userId = await _getLoggedInUserId();
    if (userId == null) {
      print("User is not logged in.");
      return;
    }

    final exercises = (exercisesData["exercises"] as List<dynamic>)
        .map((exercise) => ExerciseTable.fromJson(exercise as Map<String, dynamic>))
        .toList();

    // print("Adding exercises to state: $exercises");
    state = [...state, ...exercises];
    // print("State after adding exercises: $state");

    print("Exercise plan initialized for user $userId.");
  }

  // Zapisz cały planr
  Future<int> saveExercisePlan({ExerciseTable? onlyThis}) async {
    try {
      final toSave = onlyThis != null ? [onlyThis] : state;
      final statusCode = await _exerciseService.saveExercisePlan(toSave);
      print("Exercise plan saved successfully!");
      return statusCode;
    } catch (e) {
      print("Failed to save exercise plan: $e");
      rethrow;
    }
  }

  // Usuń plan ćwiczeń po ID
  Future<void> deleteExercisePlan(int id) async {
    try {
      await _exerciseService.deleteExercise(id);
      state = state.where((plan) => plan.id != id).toList();
      print("Exercise plan deleted successfully!");
    } catch (e) {
      print("Failed to delete exercise plan: $e");
    }
  }

  // Pobierz userId z tokena
  Future<String?> _getLoggedInUserId() async {
    final token = await getToken();
    return token;
  }

  void resetPlanById(int planId) {
    print("🔄 resetPlanById called for plan ID: $planId");

    state = state.map((plan) {
      if (plan.id == planId) {
        print("  - Resetuję plan: ${plan.exercise_table}");
        print("  - Plan ma ${plan.rows.length} ćwiczeń");

        // Resetuj wszystkie wiersze
        final newRows = plan.rows.map((rowData) {
          final newData = rowData.data.map((row) => ExerciseRow(
            colStep: row.colStep,
            colKg: row.colKg,
            colRepMin: row.colRepMin,
            colRepMax: row.colRepMax,
            isChecked: false,
            isFailure: false,
            rowColor: Colors.transparent,
          )).toList();
          return rowData.copyWithData(newData);
        }).toList();

        final resettedPlan = plan.copyWithRows(newRows);
        print("  - Plan po resecie ma ${resettedPlan.rows.length} ćwiczeń");
        return resettedPlan;
      }
      return plan;
    }).toList();

    print("✅ resetPlanById completed");
  }

  WeightType _getWeightTypeFromString(String weightType) {
    switch (weightType.toLowerCase()) {
      case 'kg':
        return WeightType.kg;
      case 'lbs':
        return WeightType.lbs;
      default:
        return WeightType.kg;
    }
  }

  RepsType _parseRepsType(String repsType) {
    switch (repsType.toLowerCase()) {
      case 'single':
        return RepsType.single;
      case 'range':
        return RepsType.range;
      default:
        return RepsType.single;
    }
  }

  // Wyczyść wszystkie plany
  void clearExercisePlans() {
    state = [];
    print("Exercise plans cleared.");
  }

  // ✅ NOWA METODA - AKTUALIZUJ ISTNIEJĄCY PLAN
  void updatePlan(ExerciseTable updatedPlan) {
    state = state.map((plan) {
      if (plan.id == updatedPlan.id) {
        return updatedPlan;
      }
      return plan;
    }).toList();

    print("✅ Plan ${updatedPlan.exercise_table} zaktualizowany w providerze");
  }

  // ✅ NOWA METODA - DODAJ NOWY PLAN
  void addPlan(ExerciseTable newPlan) {
    state = [...state, newPlan];
    print("✅ Nowy plan ${newPlan.exercise_table} dodany do providera");
  }

  // Wywołaj na starcie aplikacji!
  Future<void> initializeFromHive() async {
    await _loadPlansFromHive();
  }

  /// Pobierz plany najpierw z Hive, potem z serwera jeśli trzeba
  Future<void> fetchPlans({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final localPlans = await ExercisePlanLocalService().getPlans();
      if (localPlans.isNotEmpty) {
        state = localPlans;
        print("📥 Plany załadowane z Hive: ${localPlans.length}");
        return;
      }
    }
    // Jeśli forceRefresh lub brak lokalnych, pobierz z serwera i zapisz do Hive
    try {
      final plans = await _exerciseService.fetchPlansFromServerAndSave();
      state = plans;
      print("🌐 Plany pobrane z serwera i zapisane do Hive: ${plans.length}");
    } catch (e) {
      print("❌ Błąd pobierania planów z serwera: $e");
      state = [];
    }
  }
}

final exerciseServiceProvider = Provider<ExercisePlanService>((ref) {
  return ExercisePlanService();
});

// Provider
final exercisePlanProvider =
    StateNotifierProvider<ExercisePlanNotifier, List<ExerciseTable>>((ref) {
  return ExercisePlanNotifier(exerciseService: ref.watch(exerciseServiceProvider));
});

