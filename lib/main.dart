import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/app.dart';
import 'package:work_plan_front/core/app_initializer.dart';
///TODO: Przechowywanie danych w pamięci lokalnej – zapewnia dostęp do danych bez połączenia z Internetem.
///TODO: Synchronizacja z serwerem – automatyczne aktualizowanie danych po odzyskaniu połączenia.
///TODO: Obsługa offline – możliwość korzystania z podstawowych funkcjonalności bez Internetu
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ UŻYJ APP_INITIALIZER ZAMIAST BEZPOŚREDNIO HIVE
  await AppInitializer.initialize();
  
  runApp(ProviderScope(child: MyApp()));
}