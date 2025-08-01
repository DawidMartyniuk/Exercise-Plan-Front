import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:work_plan_front/model/User.dart';
import 'package:work_plan_front/utils/tokenStorage.dart';
import 'package:flutter/foundation.dart';

class ProfileService {
  final String _baseUrl = () {
    if (kIsWeb) {
      return "http://127.0.0.1:8000/api";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:8000/api";
    } else {
      return "http://127.0.0.1:8000/api";
    }
  }();

  final String _profile = '/profile';
  final String _avatarUpdate = '/avatar';

  // ✅ DODAJ METODĘ Z PARAMETRAMI (której używa provider)
  Future<User> updateProfile({
    required int userId,
    required String name,
    required String email,
    String? bio,
    String? weight,
    String? avatar,
  }) async {
    final token = await getToken();

    if (token == null) {
      throw Exception("Brak tokena. Użytkownik nie jest zalogowany.");
    }

    try {
      final requestBody = {
        'name': name,
        'email': email,
        if (bio != null && bio.isNotEmpty) 'bio': bio,
        if (weight != null && weight.isNotEmpty) 'weight': weight,
        if (avatar != null && avatar.isNotEmpty) 'avatar': avatar,
      };

      print("📤 Update Request: $requestBody");

      final response = await http.put(
        Uri.parse("$_baseUrl$_profile"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print("📥 Update Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        
        if (responseBody.containsKey('user')) {
          return User.fromJson(responseBody['user']);
        } else {
          return User.fromJson(responseBody);
        }
      } else {
        throw Exception("Błąd aktualizacji profilu: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ ProfileService Error: $e");
      throw Exception("Błąd połączenia: $e");
    }
  }

  // ✅ METODA DO KONWERSJI FILE NA BASE64
  Future<String> fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw Exception("Błąd konwersji obrazu: $e");
    }
  }

  // ✅ AKTUALIZACJA AVATARA
  Future<User> updateAvatar(String base64Image) async {
    final token = await getToken();

    if (token == null) {
      throw Exception("Brak tokena. Użytkownik nie jest zalogowany.");
    }

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl$_avatarUpdate"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'avatar': base64Image}),
      );

      print("📤 Avatar Request sent");
      print("📥 Avatar Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        
        if (responseBody.containsKey('user')) {
          return User.fromJson(responseBody['user']);
        } else {
          return User.fromJson(responseBody);
        }
      } else {
        throw Exception("Błąd aktualizacji avatara: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Avatar Update Error: $e");
      throw Exception("Błąd aktualizacji avatara: $e");
    }
  }
}
