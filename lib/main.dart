import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/app.dart';
import 'package:work_plan_front/core/app_initializer.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ UŻYJ APP_INITIALIZER ZAMIAST BEZPOŚREDNIO HIVE
  await AppInitializer.initialize();
  
  runApp(ProviderScope(child: MyApp()));
}