
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/authResponse.dart';
import 'package:work_plan_front/serwis/AuthService.dart';

class AuthNotifier extends StateNotifier<AuthResponse?> {
  AuthNotifier() : super(null);

  Future<void> login(String email, String password) async {
    final authService = Authservice();
    final response = await authService.login(email, password);

    if (response != null) {
      state = response; 
    } else {
      state = null;
    }
  }

  Future<void> register(String name, String email, String password, String repeatPassword) async {
    final authService = Authservice();
    final response = await authService.register(name, email, password, repeatPassword);

   if(response != null){
    state =response;
    }else{
      state = null;
    }
   
  }
}

final authProviderLogin = StateNotifierProvider<AuthNotifier, AuthResponse?>(
  (ref) => AuthNotifier(),
);
final authProviderRegister = StateNotifierProvider<AuthNotifier, AuthResponse?>(
  (ref) => AuthNotifier(),
);