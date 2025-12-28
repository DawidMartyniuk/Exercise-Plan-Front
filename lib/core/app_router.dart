import 'package:flutter/material.dart';
import 'package:work_plan_front/features/auth/screens/login.dart';
import 'package:work_plan_front/screens/tabs.dart';
import 'package:work_plan_front/screens/splash/splash.dart';

class AppRouter {
//  static const String splash = '/';
  static const String login = '/login';
  static const String tabs = '/tabs';

  static Map<String, Widget Function(BuildContext)> get routes => {
  //  splash: (_) => SplashScreen(),
    login: (_) => LoginScreen(),
    tabs: (_) => TabsScreen(selectedPageIndex: 0),
  };

  static Widget get initialRoute => SplashScreen(); // ✅ ZMIEŃ NA SPLASH
}
