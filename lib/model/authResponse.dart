import 'user.dart'; 

class AuthResponse {
  static String? currentToken; 
  final String token;
  final User user;
 

  AuthResponse({
    required this.token,
    required this.user,
   
  }) {
    currentToken = token; 
  }

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
     
      token: json['token'] as String,
      user: User.fromJson(json['user']),
    );
  }
}