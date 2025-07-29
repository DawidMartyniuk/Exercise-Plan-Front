import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/screens/save_workout.dart';
import 'package:work_plan_front/screens/tabs.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final colorScheme = const ColorScheme.dark(
  // ✅ ZMIANA: Nowe kolory według Twojej palety
  primary: Color(0xFFAE9174),        // #AE9174 - główny kolor akcent
  secondary: Color(0xFF4C2F1F),      // #4C2F1F - drugorzędny
  surface: Color(0xFF1C1B1B),        // #1C1B1B - najciemniejszy (tło)
  surfaceContainerHighest: Color(0xFFBAB1A4), // ✅ ZMIANA: surfaceContainerHighest zamiast surfaceVariant
  
  // ✅ Kolory tekstów - wszystko białe dla czytelności
  onPrimary: Colors.white,           // Tekst na primary
  onSecondary: Colors.white,         // Tekst na secondary  
  onSurface: Colors.white,           // Tekst na surface
  onSurfaceVariant: Color(0xFF1C1B1B), // Ciemny tekst na jasnych elementach
  
  // ✅ Dodatkowe kolory
  background: Color(0xFF1C1B1B),     // Tło aplikacji
  onBackground: Colors.white,        // Tekst na tle
  outline: Color(0xFF4C2F1F),       // Obramowania
);

final theme = ThemeData().copyWith(
  scaffoldBackgroundColor: colorScheme.surface, // Ciemne tło
  colorScheme: colorScheme,
  
  // ✅ POPRAWKA: withAlpha zamiast withOpacity + surfaceContainerHighest
  cardTheme: CardThemeData(
    color: colorScheme.surfaceContainerHighest.withAlpha(25), // ✅ ZMIANA: withAlpha(25) ≈ withOpacity(0.1)
    elevation: 4,
  ),
  
  appBarTheme: AppBarTheme(
    backgroundColor: colorScheme.surface,
    foregroundColor: colorScheme.onSurface,
    elevation: 0,
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    ),
  ),
  
  textTheme: GoogleFonts.ubuntuCondensedTextTheme().copyWith(
    titleSmall: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
      color: Colors.white, // ✅ Białe napisy
    ),
    titleMedium: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
      color: Colors.white, // ✅ Białe napisy
    ),
    titleLarge: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
      color: Colors.white, // ✅ Białe napisy
    ),
    bodySmall: GoogleFonts.ubuntuCondensed(
      color: Colors.white.withAlpha(204), // ✅ ZMIANA: withAlpha(204) ≈ withOpacity(0.8)
    ),
    bodyMedium: GoogleFonts.ubuntuCondensed(
      color: Colors.white, // ✅ Białe napisy
    ),
    bodyLarge: GoogleFonts.ubuntuCondensed(
      color: Colors.white, // ✅ Białe napisy
    ),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  }

  Hive.registerAdapter(ExerciseAdapter());
  await Hive.openBox('exerciseBox');

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
      title: 'App demo',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: TabsScreen(
        selectedPageIndex: 0,
      ),
    );
  }
}


