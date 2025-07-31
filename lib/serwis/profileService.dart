import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:work_plan_front/model/User.dart';
import 'package:work_plan_front/utils/tokenStorage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ProfileService {
  final String _baseUrl = () {
    if (kIsWeb) {
      return "http://127.0.0.1:8000/api"; // dla przeglądarki
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:8000/api"; // dla emulatora Androida
    } else {
      return "http://127.0.0.1:8000/api"; // dla iOS lub innych
    }
  }();

  final String _profile = '/profile';
  final String _avatarUpdate = '/avatar';

  Future<User> updateProfile(User user) async {
    final token = await getToken();

    if (token == null) {
      throw Exception("Brak tokena. Użytkownik nie jest zalogowany.");
    }
    try {
      final response = await http.put(
        Uri.parse("$_baseUrl$_profile"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return User.fromJson(responseBody);
      } else {
        throw Exception("Błąd aktualizacji profilu: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ ProfileService Error: $e");
      throw Exception("Błąd połączenia: $e");
    }
  }

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
        return User.fromJson(responseBody);
      } else {
        throw Exception(
          "Błąd aktualizacji avatara: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("❌ Avatar Update Error: $e");
      throw Exception("Błąd aktualizacji avatara: $e");
    }
  }
}
