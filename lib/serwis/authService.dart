//  odpowiada za komunikację z backendem.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:work_plan_front/model/authResponse.dart';
import 'package:work_plan_front/model/user.dart';
import 'package:work_plan_front/model/authResponse.dart';

class Authservice {
  final String  _baseUrl = "http://127.0.0.1:8000/api";
  final String _loginUrl = "/login";
  final String _registerUrl = "/register";

  Future<AuthResponse?> login(String email, String password)async {
    final response = await http.post(
      Uri.parse("$_baseUrl$_loginUrl"),
         headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      final responseBody = json.decode(response.body);
      if (responseBody.containsKey('token') && responseBody.containsKey('user')) {
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
  Future<AuthResponse?> register(String name, String email, String password, String repeadPassword)async {
    final response = await http.post(
      Uri.parse("$_baseUrl$_registerUrl"),
      headers: {
        'Content-Type': 'application/json',
      },
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
      if (responseBody.containsKey('token') && responseBody.containsKey('user')) {
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
