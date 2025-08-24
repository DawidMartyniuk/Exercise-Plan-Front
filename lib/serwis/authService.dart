import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:work_plan_front/model/LoginResult.dart';
import 'package:work_plan_front/model/authResponse.dart';
import 'package:work_plan_front/utils/tokenStorage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;


class Authservice {
  final String _baseUrl = () {
  if (kIsWeb) {
    return "http://127.0.0.1:8000/api"; // dla przeglądarki
  } else if (Platform.isAndroid) {
    return "http://10.0.2.2:8000/api"; // dla emulatora Androida
  } else {
    return "http://127.0.0.1:8000/api"; // dla iOS lub innych
  }
}();
  final String _loginUrl = "/login";
  final String _registerUrl = "/register";
  final String _logoutUrl = "/logout";
  final String _resetPasswordUrl = "/reset-request";
  final String _resetPasswordConfirmUrl = "/reset-password";

  Future<bool> resetPassword(
    String email,
    String token,
    String newPassword,
    String repeatPassword,
  ) async {
    print("🔑 Reset Password Request:");
    print("  - Email: $email");
    print("  - Token: ${token.substring(0, 10)}...");
    print("  - URL: $_baseUrl$_resetPasswordConfirmUrl");

    try {
      
      final requestBody = {
        'email': email,
        'token': token,
        'password': newPassword,
        'password_confirmation': repeatPassword, 
      };

      print("📤 Request body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse("$_baseUrl$_resetPasswordConfirmUrl"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response headers: ${response.headers}");
      print("📥 Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Password reset successful");
        return true;
      } else if (response.statusCode == 422) {
        print("❌ Validation error (422)");
        try {
          final errorBody = json.decode(response.body);
          print("❌ Validation errors: $errorBody");
          
          // ✅ WYCIĄGNIJ SZCZEGÓŁOWE BŁĘDY
          if (errorBody['errors'] != null) {
            final errors = errorBody['errors'] as Map<String, dynamic>;
            errors.forEach((field, messages) {
              print("❌ Field '$field': ${messages.join(', ')}");
            });
          }
        } catch (e) {
          print("❌ Could not parse error response: ${response.body}");
        }
        return false;
      } else {
        print("❌ Failed to confirm reset: ${response.statusCode}");
        print("❌ Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Exception in resetPassword: $e");
      return false;
    }
  }

  Future<bool> resetRequest(String email) async {
    try {
  final response = await http.post(
    Uri.parse("$_baseUrl$_resetPasswordUrl"),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email}),
  );
  
  if (response.statusCode == 200) {
    print("Reset request sent successfully");
    return true;
  } else {
    print("Failed to send reset request: ${response.statusCode}");
     if (response.body.isNotEmpty) {
          final errorBody = json.decode(response.body);
          print("❌ Error details: $errorBody");
        }
    return false;
  }
} catch (e) {
  print("Error occurred while sending reset request: $e");
  return false;
}
  }


  Future<AuthResponse?> logout() async {
    final token = await getToken();
    if (token == null) {
      print("Brak tokena. Użytkownik nie jest zalogowany.");
      return null;
    }
    
    final response = await http.post(
      Uri.parse("$_baseUrl$_logoutUrl"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({}),
    );
    if (response.statusCode == 200) {
    print("Wylogowano pomyślnie");
    await clearToken(); 
  } else {
    print("Błąd wylogowania: ${response.statusCode}");
  }
  }

Future<LoginResult?> login(String email, String password) async {
  final response = await http.post(
    Uri.parse("$_baseUrl$_loginUrl"),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  print("🔍 Login Response Status: ${response.statusCode}");
  print("🔍 Login Response Body: ${response.body}");

  if (response.statusCode == 200 || response.statusCode == 201) {
    try {
      final responseBody = json.decode(response.body);
      print("🔍 Parsed Response: $responseBody");
      
      if (responseBody.containsKey('token') && responseBody.containsKey('user')) {
        // ✅ RĘCZNIE DODAJ MESSAGE JEŚLI BRAK
        if (!responseBody.containsKey('message')) {
          responseBody['message'] = 'Login successful';
        }
        
        final authResponse = AuthResponse.fromJson(responseBody);
        await saveToken(authResponse.token); 
        return LoginResult(authResponse: authResponse, statusCode: response.statusCode);
      } else {
        print("❌ Brak tokenu lub użytkownika w odpowiedzi");
        return LoginResult(authResponse: null, statusCode: response.statusCode);
      }
    } catch (e, stackTrace) {
      print("❌ Error parsing login response: $e");
      print("❌ StackTrace: $stackTrace");
      return LoginResult(authResponse: null, statusCode: 500);
    }
  } else {
    print('❌ Błąd logowania: ${response.statusCode}');
    return LoginResult(authResponse: null, statusCode: response.statusCode);
  }
}
  Future<AuthResponse?> register(
    String name,
    String email,
    String password,
    String repeadPassword,
  ) async {
    final response = await http.post(
      Uri.parse("$_baseUrl$_registerUrl"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': repeadPassword,
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      final responseBody = json.decode(response.body);
      if (responseBody.containsKey('token') &&
          responseBody.containsKey('user')) {
        return AuthResponse.fromJson(responseBody);
      } else {
        print("Brak tokenu lub użytkownika w odpowiedzi");
        return null;
      }
    } else {
      print('Błąd logowania: ${response.statusCode}');
      return null;
    }
  }
}
