import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ INICJALIZACJA PRZENIESIONA DO SPLASH SCREEN
  runApp(ProviderScope(child: MyApp()));
}
