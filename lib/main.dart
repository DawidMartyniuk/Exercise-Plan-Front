import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/screens/tabs.dart';
import 'package:work_plan_front/theme/app_theme.dart'; // ✅ IMPORT THEME
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:work_plan_front/serwis/exerciseService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ INICJALIZACJA HIVE
  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  }

  // ✅ REJESTRACJA ADAPTERA
  Hive.registerAdapter(ExerciseAdapter());
  
  // ✅ OTWÓRZ BOX NAJPIERW
  await Hive.openBox<Exercise>('exerciseBox');
  
  // ✅ POTEM ZAŁADUJ ĆWICZENIA
  try {
    final exerciseService = ExerciseService();
    final exercises = await exerciseService.exerciseList();
    print("🚀 Załadowano ${exercises?.length ?? 0} ćwiczeń przy starcie");
  } catch (e) {
    print("❌ Błąd ładowania ćwiczeń przy starcie: $e");
  }

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exercise Plan App',
      debugShowCheckedModeBanner: false,
      theme: appTheme, // ✅ UŻYJ THEME Z PLIKU
      home: TabsScreen(
        selectedPageIndex: 0,
      ),
    );
  }
}


