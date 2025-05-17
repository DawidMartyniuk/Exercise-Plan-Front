import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/screens/tabs.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
 // nie jest potzrebny bo app mam w main 



final colorScheme = const ColorScheme.dark(
  primary: Colors.black,
  surface: Color.fromARGB(239, 65, 61, 61),
  secondary: Color.fromARGB(238, 124, 117, 117),
  onPrimary: Colors.white,
  onSurface: Colors.white,
);

final theme =ThemeData().copyWith(
  scaffoldBackgroundColor: colorScheme.surface,
  colorScheme: colorScheme,
  textTheme: GoogleFonts.ubuntuCondensedTextTheme().copyWith(
    titleSmall: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
    ),
    titleMedium: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
    ),
    
  ),
);


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Hive.initFlutter(); // Web: wszystko zainicjalizowane bez katalogu
  } else {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path); // Mobile/Desktop: z path_provider
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
