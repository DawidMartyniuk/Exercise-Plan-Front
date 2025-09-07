import 'package:work_plan_front/model/User.dart';

class AuthResponse {
  static String? currentToken; 
  final String? message;
  final String token;
  final User user;
 


  AuthResponse({
     this.message,
    required this.token,
    required this.user,
  }) {
    currentToken = token; 
  }

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    print("🔍 AuthResponse.fromJson: $json"); // ✅ DEBUG
    
    return AuthResponse(
      // ✅ PROBLEM TUTAJ - 'message' może być null w response
      message: json['message'] as String? , // ✅ DODAJ DEFAULT
      token: json['token'] as String,
      user: User.fromJson(json['user']),
    );
  }

  AuthResponse copyWith({
    String? message,
    String? token,
    User? user, // ✅ TO JEST OK - może być nullable w parametrze
  }) {
    return AuthResponse(
      message: message ?? this.message,
      token: token ?? this.token,
      user: user ?? this.user, // ✅ ALE TUTAJ ZAWSZE BĘDZIE non-null
    );
  }
}