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

Future<List<ExerciseTable>> fetchExercises() async {
  final url = Uri.parse("$_baseUrl$_exerciseUrl");
  print("Fetching data from URL: $url");

  final response = await http.get(
    url,
    headers: await _getHeaders(),
  );

  print("Response status: ${response.statusCode}");
  print("Response body: ${response.body}");

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
   // print("Decoded JSON data: $data");
   // print("Decoded JSON data type: ${data.runtimeType}");

    final mappedData = data
        .map((json) => ExerciseTable.fromJson(json as Map<String, dynamic>))
        .toList();

   // print("Mapped data to ExerciseTable: $mappedData");
  //  print("Mapped data type: ${mappedData.runtimeType}");

    return mappedData;
  } else {
    throw Exception("Failed to fetch exercises: ${response.body}");
  }
}

Future<int> saveExercisePlan(List<ExerciseTable> exercises) async {
  try {
    final userId = await _getUserIdFromToken();
    if (userId == null) {
      throw Exception("User ID not found.");
    }

    final payload = {
      "exercises": exercises.map((e) => e.toJson()).toList(),
    };

    final url = Uri.parse("$_baseUrl$_exerciseUrl");
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode(payload),
    );
     print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 201 || response.statusCode == 200)  {
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
  Future<void> deleteExercise(String id) async {
    final url = Uri.parse("$_baseUrl$_exerciseUrl/$id");
    final response = await http.delete(
      url,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      print("Exercise deleted successfully!");
    } else {
      throw Exception("Failed to delete exercise: ${response.body}");
    }
  }
  Future<String?> _getUserIdFromToken() async {
  final token = await getToken();
  if (token == null) {
    throw Exception("No token found. User is not logged in.");
  }

  try {
    final decodedToken = JwtDecoder.decode(token);
    return decodedToken['sub']; // Zakładamy, że `sub` zawiera `user_id`
  } catch (e) {
    throw Exception("Failed to decode token: $e");
  }
}


  // Pobierz nagłówki z tokenem
 Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    if (token == null) {
      throw Exception("No token found. User is not logged in.");
    }
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };
  }
}