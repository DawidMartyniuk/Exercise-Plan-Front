import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/LoginResult.dart';
import 'package:work_plan_front/model/authResponse.dart';
import 'package:work_plan_front/serwis/AuthService.dart';
import 'package:work_plan_front/serwis/profileService.dart';
import 'package:work_plan_front/utils/token_storage.dart';

class AuthNotifier extends StateNotifier<AuthResponse?> {
  final Authservice _authService = Authservice();

  AuthNotifier() : super(null) {
    
    _checkPersistedLogin();
  }

 
  Future<void> _checkPersistedLogin() async {
    print("🔍 Sprawdzanie zapisanego tokena...");
    
    try {
      // TYMCZASOWO UŻYJ PROSTEJ METODY
      final token = await getToken();
      if (token == null || token.isEmpty) {
        print("🔍 Brak tokena - wymagane logowanie");
        return;
      }

      print("✅ Znaleziono token - próbuję pobrać profil użytkownika");

      //SPRÓBUJ POBRAĆ PROFIL BEZ WALIDACJI JWT
      try {
        final userProfile = await ProfileService().getCurrentUserProfile();
        if (userProfile != null) {
          final authResponse = AuthResponse(
            message: "Auto-login successful",
            token: token,
            user: userProfile,
          );
          state = authResponse;
          print("✅ Auto-login pomyślny dla: ${userProfile.name}");
        } else {
          print("❌ Nie udało się pobrać profilu - token może być nieważny");
          await clearToken();
        }
      } catch (profileError) {
        print("❌ Błąd pobierania profilu: $profileError");
        await clearToken();
      }
    } catch (e) {
      print("❌ Błąd auto-login: $e");
      await clearToken();
    }
  }

  //LOGOWANIE Z ZAPISANIEM TOKENA
  Future<LoginResult?> login(String email, String password) async {
    try {
      print("🔐 Próba logowania dla: $email");
      final result = await _authService.login(email, password);
      
      if (result?.authResponse != null) {
        state = result!.authResponse;
        print("✅ Logowanie pomyślne, token zapisany");
      }
      
      return result;
    } catch (e) {
      print("❌ Błąd logowania: $e");
      rethrow;
    }
  }

  //  DODANA BRAKUJĄCA METODA RESET PASSWORD
  Future<bool> resetPassword(String email) async {
    try {
      print("🔐 Wysyłanie linku resetowania hasła do: $email");
      final success = await _authService.resetRequest(email);
      
      if (success) {
        print("✅ Link resetowania hasła wysłany pomyślnie");
      } else {
        print("❌ Nie udało się wysłać linku resetowania hasła");
      }
      
      return success;
    } catch (e) {
      print("❌ Błąd wysyłania linku resetowania hasła: $e");
      return false;
    }
  }

  //  POTWIERDZENIE RESETU HASŁA
  Future<bool> confirmPasswordReset({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      print("🔐 Resetowanie hasła dla: $email");
      final result = await _authService.resetPassword(
        email,
        token,
        newPassword,
        confirmPassword,
      );
      
      if (result) {
        print("✅ Hasło zostało pomyślnie zresetowane");
      } else {
        print("❌ Nie udało się zresetować hasła");
      }
      
      return result;
    } catch (e) {
      print("❌ Błąd resetowania hasła: $e");
      return false;
    }
  }

  //  REJESTRACJA
  Future<void> register(String name, String email, String password, String repeatPassword) async {
    try {
      print("📝 Próba rejestracji dla: $email");
      final response = await _authService.register(name, email, password, repeatPassword);
      
      if (response != null) {
        state = response;
        print("✅ Rejestracja pomyślna");
      } else {
        state = null;
        print("❌ Rejestracja nieudana");
      }
    } catch (e) {
      print("❌ Błąd rejestracji: $e");
      state = null;
      rethrow;
    }
  }

  // WYLOGOWANIE Z WYCZYSZCZENIEM TOKENA
  Future<void> logout() async {
    try {
      print("🚪 Wylogowywanie...");
      await _authService.logout();
      await clearToken();
      state = null;
      print("✅ Wylogowanie pomyślne");
    } catch (e) {
      print("❌ Błąd wylogowania: $e");
      await clearToken();
      state = null;
    }
  }

  //  SPRAWDŹ CZY TOKEN JEST NADAL WAŻNY
  Future<bool> validateToken() async {
    if (state == null) return false;
    
    final isValid = await isTokenValid();
    if (!isValid) {
      print("⏰ Token wygasł - automatyczne wylogowanie");
      state = null;
      await clearToken();
    }
    return isValid;
  }

  //  ODŚWIEŻ TOKEN (jeśli backend obsługuje refresh tokens)
  Future<void> refreshToken() async {
    try {
     
      print("🔄 Odświeżanie tokena...");
    } catch (e) {
      print("❌ Błąd odświeżania tokena: $e");
      await logout();
    }
  }
}

final authProviderLogin = StateNotifierProvider<AuthNotifier, AuthResponse?>(
  (ref) => AuthNotifier(),
);

final authProviderRegister = StateNotifierProvider<AuthNotifier, AuthResponse?>(
  (ref) => AuthNotifier(),
);

final authProviderResetPassword = StateNotifierProvider<AuthNotifier, AuthResponse?>(
  (ref) => AuthNotifier(),
);