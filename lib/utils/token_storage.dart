
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

  if(token == null || token.isEmpty ){
    return false;
  }

  try{
    if(JwtDecoder.isExpired(token)){
      print("token wygasł");
      await clearToken();
      return false;
    }
    return true;
  } catch (e) {
    print("Error checking token validity: $e");
    await clearToken();
    return false;
  }

  return token != null; 
}

Future<bool> isTokenValid() async {
  final token = await getToken();
  if (token == null || token.isEmpty) {
    return false;
  }

  try {
    return !JwtDecoder.isExpired(token);
  } catch (e) {
    return false;
  }
}

// ✅ POBIERZ DANE Z TOKENA
Future<Map<String, dynamic>?> getTokenData() async {
  final token = await getToken();
  if (token == null || await isTokenValid()) {
    return null;
  }

  try {
    return JwtDecoder.decode(token);
  } catch (e) {
    print("❌ Błąd dekodowania tokena: $e");
    return null;
  }
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