import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:work_plan_front/model/User.dart';
import 'package:work_plan_front/utils/token_storage.dart';
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
  final String _profileUrl = "/profile";


   Future<User?> getCurrentUserProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        print("❌ Brak tokena do pobrania profilu");
        return null;
      }

      final response = await http.get(
        Uri.parse("$_baseUrl$_profileUrl"),
        headers: await getHeaders(),
      );

      print("📡 Profile response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // ✅ SPRAWDŹ FORMAT ODPOWIEDZI
        if (responseData.containsKey('user')) {
          return User.fromJson(responseData['user']);
        } else if (responseData.containsKey('data')) {
          return User.fromJson(responseData['data']);
        } else {
          // ✅ JEŚLI ODPOWIEDŹ TO BEZPOŚREDNIO OBIEKT USER
          return User.fromJson(responseData);
        }
      } else if (response.statusCode == 401) {
        print("🔐 Token nieważny - wymagane ponowne logowanie");
        await clearToken();
        return null;
      } else {
        print("❌ Błąd pobierania profilu: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Błąd getCurrentUserProfile: $e");
      return null;
    }
  }

  // ✅ DODAJ METODĘ Z PARAMETRAMI (której używa provider)
  Future<User> updateProfile({
    required int userId,
    required String name,
    required String email,
    String? description,
    String? weight,
    String? avatar,
  }) async {
    try {
      final requestBody = {
        'name': name,
        'email': email,
        if (description != null && description.isNotEmpty) 'description': description,
        if (weight != null && weight.isNotEmpty) 'weight': weight,
        if (avatar != null && avatar.isNotEmpty) 'avatar': avatar,
      };

      print("📤 Update Request: $requestBody");

      final response = await http.put(
        Uri.parse("$_baseUrl$_profile"),
        headers: await getHeaders(), // ✅ UŻYJ getHeaders() zamiast ręcznego tworzenia
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

  // ✅ AKTUALIZACJA AVATARA - też użyj getHeaders()
  Future<User> updateAvatar(String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl$_avatarUpdate"),
        headers: await getHeaders(), // ✅ UŻYJ getHeaders() zamiast ręcznego tworzenia
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
