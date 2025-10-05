import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:work_plan_front/model/training_session.dart';
import 'package:work_plan_front/utils/token_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform, File;
import 'package:http_parser/http_parser.dart';
import 'package:work_plan_front/utils/token_storage.dart' as TokenStorage;
import 'package:work_plan_front/model/exercise.dart';
import 'package:hive/hive.dart';

class userExerciseService {
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
  
  Future<void> addUserExercise(Map<String, dynamic> exerciseData, {File? imageFile, String? imageBase64}) async {
    final uri = Uri.parse('$_baseUrl$_exerciseUrl');
    final token = await getToken();

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    // 1. Dodaj plik jako 'gif' - obsługa web i mobile
    if (kIsWeb && imageBase64 != null) {
      // WEB: base64 na bajty
      final bytes = base64Decode(imageBase64.split(',').last);
      request.files.add(
        http.MultipartFile.fromBytes(
          'gif',
          bytes,
          filename: 'exercise.png',
          contentType: MediaType('image', 'png'), 
        ),
      );
    } else if (imageFile != null) {
      // MOBILE: plik z dysku
      request.files.add(
    await http.MultipartFile.fromPath(
      'gif',
      imageFile.path,
      contentType: MediaType('image', 'png'),
    ),
  );
    }

    // 2. Dodawaj tablice jako pola z []
    exerciseData.forEach((key, value) {
      if (key == 'gif_url') return; // nie wysyłaj gif_url
      if (value is List) {
        for (var v in value) {
          request.fields['${key}[]'] = v.toString();
        }
      } else {
        request.fields[key] = value.toString();
      }
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      throw Exception('Failed to add exercise: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchUserExercises() async {
    // final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl$_exerciseUrl'),
      headers: await getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch exercises: ${response.body}');
    }
  }

  Future<List<Exercise>> fetchUserExercisesTyped() async {
    final data = await fetchUserExercises();
    return data.map((e) => Exercise.fromJson(e as Map<String, dynamic>)).toList();
  }


Future<void> fetchAndSaveUserExercises(int userId) async {
  final exercises = await fetchUserExercisesTyped();
  // Jeśli backend zwraca tylko ćwiczenia usera, nie musisz filtrować
  final box = await Hive.openBox<Exercise>('user_exercises_$userId');
  await box.clear();
  await box.addAll(exercises);
}
}
