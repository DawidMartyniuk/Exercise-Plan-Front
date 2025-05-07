//  odpowiada za komunikację z backendem.
import 'dart:convert';
import 'package:http/http.dart' as http;
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

  Future<AuthResponse?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$_baseUrl$_loginUrl"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      print(response.body);
      final responseBody = json.decode(response.body);
      if (responseBody.containsKey('token') && responseBody.containsKey('user')) 
      {
        final  authResponse = AuthResponse.fromJson(responseBody);
        await saveToken(authResponse.token); 
        return authResponse;
      } else {
        print("Brak tokenu lub użytkownika w odpowiedzi");
        return null;
      }
    } else {
      print('Błąd logowania: ${response.statusCode}');
      return null;
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
