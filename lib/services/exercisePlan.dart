import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:work_plan_front/utils/token_storage.dart';
import 'package:hive/hive.dart';
import 'package:work_plan_front/services/exercise_plan_local_service.dart';

class ExerciseService {
  final String _baseUrl = () {
    if (kIsWeb) {
      return "http://127.0.0.1:8000/api";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:8000/api";
    } else {
      return "http://127.0.0.1:8000/api";
    }
  }();
  final String _exerciseUrl = "/exercises";
  //final _getHeaders = 

  Future<List<ExerciseTable>> fetchExercises() async {
    final url = Uri.parse("$_baseUrl$_exerciseUrl");
    print("Fetching data from URL: $url");

    final response = await http.get(url, headers: await getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final mappedData =
          data
              .map(
                (json) => ExerciseTable.fromJson(json as Map<String, dynamic>),
              )
              .toList();

      return mappedData;
    } else {
      throw Exception("Failed to fetch exercises: ${response.body}");
    }
  }
   Future<Map<String, dynamic>> updateExercisePlan(int planId, Map<String, dynamic> updatedData) async {
    try {
      final userId = await getUserIdFromToken();
      if (userId == null) {
        throw Exception("User ID not found.");
      }

      print("🔄 Updating exercise plan with ID: $planId");
      print("📤 Update payload: ${jsonEncode(updatedData)}");
       

 
      final url = Uri.parse("$_baseUrl$_exerciseUrl/$planId");
      final response = await http.put(
        url,
        headers: await getHeaders(),
        body: jsonEncode(updatedData),
      );

      print("📥 Update response status: ${response.statusCode}");
      print("📥 Update response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("✅ Exercise plan updated successfully!");
        return responseData;
      } else {
        throw Exception("Failed to update exercise plan: ${response.body}");
      }
    } catch (e) {
      print("❌ Failed to update exercise plan: $e");
      rethrow;
    }
  }

 Future<int> saveExercisePlan(List<ExerciseTable> exercises) async {
  try {
    final userId = await getUserIdFromToken();
    if (userId == null) {
      throw Exception("User ID not found.");
    }

    

    for (int i = 0; i < exercises.length; i++) {
      final exercise = exercises[i];

      exercise.rows.asMap().forEach((j, row) {

      });
    }

    final payload = {"exercises": exercises.map((e) => e.toJson()).toList()};


    final url = Uri.parse("$_baseUrl$_exerciseUrl");
    final response = await http.post(
      url,
      headers: await getHeaders(),
      body: jsonEncode(payload),
    );


    if (response.statusCode == 201 || response.statusCode == 200) {
      print("Exercise plan saved successfully!");
    } else {
      throw Exception("Failed to save exercise plan: ${response.body}");
    }
    return response.statusCode;
  } catch (e) {
    print("Failed to save exercise plan: $e");
    rethrow;
  }
}

  // Usuń plan ćwiczeń
  Future<void> deleteExercise(int id) async {
    final url = Uri.parse("$_baseUrl$_exerciseUrl/$id");
    final response = await http.delete(
      url, 
      headers: await getHeaders()
      );

    if (response.statusCode == 200) {
      print("Exercise deleted successfully!");
    } else {
      throw Exception("Failed to delete exercise: ${response.body}");
    }
  }

  /// Pobierz plany z serwera i zapisz do Hive
  Future<List<ExerciseTable>> fetchPlansFromServerAndSave() async {
    final url = Uri.parse("$_baseUrl$_exerciseUrl");
    final response = await http.get(url, headers: await getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final plans = data.map((json) => ExerciseTable.fromJson(json)).toList();

      // ZAPISZ DO HIVE
      await ExercisePlanLocalService().savePlans(plans.cast<ExerciseTable>());
      print("💾 Plany zapisane do Hive po pobraniu z serwera: ${plans.length}");

      return plans.cast<ExerciseTable>();
    } else {
      throw Exception("Failed to fetch plans: ${response.body}");
    }
  }
}

// class ExercisePlanLocalService {
//   static const String _boxName = 'plansBox';

//   Future<void> savePlans(List<ExerciseTable> plans) async {
//     final box = await Hive.openBox<ExerciseTable>(_boxName);
//     await box.clear();
//     for (final plan in plans) {
//       await box.put(plan.id, plan);
//     }
//   }

//   Future<List<ExerciseTable>> getPlans() async {
//     final box = await Hive.openBox<ExerciseTable>(_boxName);
//     return box.values.toList();
//   }

//   Future<void> deletePlan(int planId) async {
//     final box = await Hive.openBox<ExerciseTable>(_boxName);
//     await box.delete(planId);
//   }
// }
