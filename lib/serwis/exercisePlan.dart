import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/utils/tokenStorage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

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

 Future<int> saveExercisePlan(List<ExerciseTable> exercises) async {
  try {
    final userId = await getUserIdFromToken();
    if (userId == null) {
      throw Exception("User ID not found.");
    }

    // ✅ DODAJ DEBUGGING - SPRAWDŹ CO WYSYŁASZ
    print("🔍 saveExercisePlan - Input exercises count: ${exercises.length}");
    for (int i = 0; i < exercises.length; i++) {
      final exercise = exercises[i];
      print("  - Exercise $i: ${exercise.exercise_table}");
      print("    - Rows count: ${exercise.rows.length}");
      exercise.rows.asMap().forEach((j, row) {
        print("      - Row $j: ${row.exercise_name} (${row.exercise_number})");
        print("        - Data count: ${row.data.length}");
      });
    }

    final payload = {"exercises": exercises.map((e) => e.toJson()).toList()};

    // ✅ DODAJ DEBUGGING - SPRAWDŹ PAYLOAD
    print("📤 Final payload being sent to backend:");
    print("  - Payload keys: ${payload.keys.toList()}");
    print("  - Exercises count in payload: ${(payload['exercises'] as List).length}");
    print("  - Full payload: ${jsonEncode(payload)}");

    final url = Uri.parse("$_baseUrl$_exerciseUrl");
    final response = await http.post(
      url,
      headers: await getHeaders(),
      body: jsonEncode(payload),
    );

    // ✅ DODAJ DEBUGGING - SPRAWDŹ ODPOWIEDŹ
    print("📥 Backend response:");
    print("  - Status code: ${response.statusCode}");
    print("  - Response body: ${response.body}");

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
}
