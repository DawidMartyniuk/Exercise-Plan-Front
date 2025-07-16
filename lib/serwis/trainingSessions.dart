
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:work_plan_front/model/TrainingSesions.dart';

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

  final String _trainingUrl = "/training-sessions";


    Future<int>saveTrainingSesions(List<TrainingSession> trainingSessions) async {
    try{
      final url = Uri.parse("$_baseUrl$_trainingUrl");
      
      final userId = await getUserIdFromToken();
       if (userId == null) {
        throw Exception("User ID not found.");
      }

      final playaod = {
        "user_id": userId,
        "training_sessions": trainingSessions.map((e) => e.toJson()).toList()
      };

      print ("Saving data to URL: $url");

      final response = await http.post(
        url,
        headers: await getHeaders(),
        body: jsonEncode(playaod),
      );

      if(response.statusCode == 200 || response.statusCode == 201) {
        print("Data saved successfully: ${response.body}");
      } else {
        print("Failed to save data: ${response.body}");
        throw Exception("Failed to save training sessions: ${response.body}");
      }
      return response.statusCode;
        }catch (e) {
      print("Error saving training sessions: $e");
      rethrow;
    }
    }
  
}