import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:work_plan_front/model/TrainingSesions.dart';
import 'package:work_plan_front/utils/token_storage.dart';
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
  Future<void> deleteTrainingSession(int sessionsId) async {

    final url = Uri.parse("$_baseUrl$_trainingUrl/$sessionsId");
    final response = await http.delete(
      url,
      headers: await getHeaders(),
    );
    if (response.statusCode == 200) {
      print("Training session deleted successfully!");
    } else {
      throw Exception("Failed to delete training session: ${response.body}");
    }
  }


  // Pobierz sesje treningowe dla zalogowanego użytkownika
  Future<List<TrainingSession>> getUserTrainingSessions() async {
    print("🌐 TrainingSessionService: getUserTrainingSessions() START");
    
    try {
      print("🌐 TrainingSessionService: Rozpoczynam pobieranie sesji...");
      
      final userId = await getUserIdFromToken();
      print("👤 User ID: $userId");
      
      if (userId == null) {
        print("❌ User ID jest null!");
        throw Exception("User ID not found.");
      }

      final url = Uri.parse("$_baseUrl$_trainingUrl?user_id=$userId");
      print("🌐 Calling URL: $url");

      // ✅ DODAJ TIMEOUT
      final response = await http.get(
        url, 
        headers: await getHeaders(),
      ).timeout(Duration(seconds: 5));

      print("📡 Response status: ${response.statusCode}");
      print("📡 Response body length: ${response.body.length}");
      print("📡 Response body preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> jsonData = responseData['data'] as List;
        
        print("✅ Pobrano ${jsonData.length} sesji treningowych z API");
        
        if (jsonData.isEmpty) {
          print("⚠️ API zwróciło pustą listę sesji");
          return [];
        }
        
        final sessions = jsonData.map((item) => TrainingSession.fromJson(item)).toList();
        print("✅ Sparsowano ${sessions.length} sesji");
        
        return sessions;
      } else {
        print("❌ Błąd API: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e, stackTrace) {
      print("❌ TrainingSessionService ERROR: $e");
      print("❌ Stack trace: $stackTrace");
      return [];
    } finally {
      print("🌐 TrainingSessionService: getUserTrainingSessions() END");
    }
  }
}
