
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/LoginResult.dart';
import 'package:work_plan_front/model/authResponse.dart';
import 'package:work_plan_front/serwis/AuthService.dart';

class AuthNotifier extends StateNotifier<AuthResponse?> {
  AuthNotifier() : super(null);

    final authService = Authservice();

  Future<LoginResult?> login(String email, String password) async {
    //final authService = Authservice();
    final loginResult = await authService.login(email, password);

    if ( loginResult?.authResponse != null ) {
   // final loginResult != null) {
      state = loginResult?.authResponse;
    } else {
      state = null;
    }

    return loginResult;
  }
  Future<bool> resetPassword (String email) async {
    //final Authservice

    try{
      final resetPasswordResponse = await authService.resetRequest(email);
      return resetPasswordResponse;
    }catch (e) {
      print("Error occurred while resetting password: $e");
      return false;
    }
  }


  Future<void> register(String name, String email, String password, String repeatPassword) async {
    //final authService = Authservice();
    final response = await authService.register(name, email, password, repeatPassword);

   if(response != null){
    state =response;
    }else{
      state = null;
    }
   
  }
  Future<void> logout() async {
    final authService = Authservice();
     await authService.logout();
    state = null; 
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