import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:work_plan_front/model/TrainingSesions.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/utils/tokenStorage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class TrainingSessionService {
  final String _baseUrl = () {
    if (kIsWeb) {
      return "http://127.0.0.1:8000/api";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:8000/api";
    } else {
      return "http://127.0.0.1:8000/api";
    }
  }();

  final String _trainingUrl = "/training-sessions";

  Future<int> saveTrainingSession(TrainingSession trainingSession) async {
    try {
      final url = Uri.parse("$_baseUrl$_trainingUrl");

      final userId = await getUserIdFromToken();
      if (userId == null) {
        throw Exception("User ID not found.");
      }

      final payload = {
        "user_id": userId,
        ...trainingSession.toJson(),
      };

      // ✅ DEBUGGING - sprawdź payload przed wysłaniem
      print("🔍 Final payload: ${jsonEncode(payload)}");
      print("🔍 Payload ma exercise_table_name: ${payload.containsKey('exercise_table_name')}");
      print("🔍 exercise_table_name value: '${payload['exercise_table_name']}'");

      final response = await http.post(
        url,
        headers: await getHeaders(),
        body: jsonEncode(payload),
      );

      print("🔍 Response status: ${response.statusCode}");
      print("🔍 Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Data saved successfully: ${response.body}");
      } else {
        print("Failed to save data: ${response.body}");
        throw Exception("Failed to save training session: ${response.body}");
      }
      return response.statusCode;
    } catch (e) {
      print("Error saving training session: $e");
      rethrow;
    }
  }

  // Pobierz sesje treningowe dla zalogowanego użytkownika
  Future<List<TrainingSession>> getUserTrainingSessions() async {
    try {
      final userId = await getUserIdFromToken();
      if (userId == null) {
        throw Exception("User ID not found.");
      }

      final url = Uri.parse("$_baseUrl$_trainingUrl?user_id=$userId");

      final response = await http.get(
        url,
        headers: await getHeaders(),
      );

      if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      // ✅ POPRAWKA: Wyciągnij dane z pola 'data'
      final List<dynamic> jsonData = responseData['data'] as List;
      
      print("✅ Pobrano ${jsonData.length} sesji treningowych");
      
      return jsonData.map((item) => TrainingSession.fromJson(item)).toList();
    } else {
      print("Failed to fetch user training sessions: ${response.body}");
      throw Exception("Failed to fetch user training sessions");
    }
    } catch (e) {
      print("Error fetching user training sessions: $e");
      rethrow;
    }
  }
}
