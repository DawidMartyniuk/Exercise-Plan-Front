
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('jwt_token', token);
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt_token');
}

Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('jwt_token');
}
 Future<bool> isLoggedIn() async {
  final token = await getToken();
  return token != null; 
}
Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    if (token == null) {
      throw Exception("No token found. User is not logged in.");
    }
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<String?> getUserIdFromToken() async {
    final token = await getToken();
    if (token == null) {
      throw Exception("No token found. User is not logged in.");
    }

    try {
      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['sub']; // Zakładamy, że `sub` zawiera `user_id`
    } catch (e) {
      throw Exception("Failed to decode token: $e");
    }
  }