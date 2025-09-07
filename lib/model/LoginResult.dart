import 'package:work_plan_front/model/auth_response.dart';

class LoginResult{
  final AuthResponse? authResponse;
  final int statusCode;

  LoginResult({
    required this.authResponse,
     required this.statusCode
  });
}