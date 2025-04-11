import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:work_plan_front/screens/start.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/widget/tabs.dart';

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


void main() {
  runApp( const ProviderScope(child:MyApp() ) );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App demo',
      theme: theme,
      home: TabsScreen(),
      );
  }
}
