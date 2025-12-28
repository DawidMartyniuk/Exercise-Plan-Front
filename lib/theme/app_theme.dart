import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ DEFINICJA KOLORÓW
final colorScheme = const ColorScheme.dark(
  // Główne kolory według palety
  primary: Color(0xFFAE9174),        // #AE9174 - główny kolor akcent
  secondary: Color(0xFF4C2F1F),      // #4C2F1F - drugorzędny
  surface: Color(0xFF1C1B1B),        // #1C1B1B - najciemniejszy (tło)
  surfaceContainerHighest: Color(0xFFBAB1A4), // Jasny akcent
  
  // Kolory tekstów - wszystko białe dla czytelności
  onPrimary: Colors.white,           // Tekst na primary
  onSecondary: Colors.white,         // Tekst na secondary  
  onSurface: Colors.white,           // Tekst na surface
  onSurfaceVariant: Color(0xFF1C1B1B),        // Tekst na tle
  outline: Color(0xFF4C2F1F),       // Obramowania
);

// ✅ GŁÓWNY THEME APLIKACJI
final appTheme = ThemeData().copyWith(
  scaffoldBackgroundColor: colorScheme.surface, // Ciemne tło
  colorScheme: colorScheme,
  
  // Karty
  cardTheme: CardThemeData(
    color: colorScheme.surfaceContainerHighest.withAlpha(25),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  
  // AppBar
  appBarTheme: AppBarTheme(
    backgroundColor: colorScheme.surface,
    foregroundColor: colorScheme.onSurface,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.ubuntuCondensed(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  
  // Przyciski
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: GoogleFonts.ubuntuCondensed(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  
  // Outlined Button
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: colorScheme.primary,
      side: BorderSide(color: colorScheme.primary),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: GoogleFonts.ubuntuCondensed(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  
  // Text Button
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: colorScheme.primary,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      textStyle: GoogleFonts.ubuntuCondensed(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  // Input Field
  // inputDecorationTheme: InputDecorationTheme(
  //   filled: true,
  //   fillColor: colorScheme.surface,
  //   border: OutlineInputBorder(
  //     borderRadius: BorderRadius.circular(8),
  //     borderSide: BorderSide(color: colorScheme.outline),
  //   ),
  //   enabledBorder: OutlineInputBorder(
  //     borderRadius: BorderRadius.circular(8),
  //     borderSide: BorderSide(color: colorScheme.outline),
  //   ),
  //   focusedBorder: OutlineInputBorder(
  //     borderRadius: BorderRadius.circular(8),
  //     borderSide: BorderSide(color: colorScheme.primary, width: 2),
  //   ),
  //   hintStyle: GoogleFonts.ubuntuCondensed(
  //     color: Colors.white.withAlpha(153), // 60% opacity
  //   ),
  //   labelStyle: GoogleFonts.ubuntuCondensed(
  //     color: colorScheme.primary,
  //     fontWeight: FontWeight.w600,
  //   ),
  // ),
  
  // List Tile
  listTileTheme: ListTileThemeData(
    textColor: Colors.white,
    iconColor: colorScheme.primary,
    tileColor: colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  
  // Bottom Navigation Bar
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: colorScheme.surface,
    selectedItemColor: colorScheme.primary,
    unselectedItemColor: Colors.white.withAlpha(153),
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedLabelStyle: GoogleFonts.ubuntuCondensed(
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
    unselectedLabelStyle: GoogleFonts.ubuntuCondensed(
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
  ),
  
  // Floating Action Button
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: colorScheme.primary,
    foregroundColor: colorScheme.onPrimary,
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  
  // Dialog
  dialogTheme: DialogThemeData(
    backgroundColor: colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    titleTextStyle: GoogleFonts.ubuntuCondensed(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    contentTextStyle: GoogleFonts.ubuntuCondensed(
      fontSize: 16,
      color: Colors.white,
    ),
  ),
  
  // Snackbar
  snackBarTheme: SnackBarThemeData(
    backgroundColor: colorScheme.surfaceContainerHighest.withAlpha(230),
    contentTextStyle: GoogleFonts.ubuntuCondensed(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    behavior: SnackBarBehavior.floating,
  ),
  
  // Typografia
  textTheme: GoogleFonts.ubuntuCondensedTextTheme().copyWith(
    displayLarge: GoogleFonts.ubuntuCondensed(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displayMedium: GoogleFonts.ubuntuCondensed(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displaySmall: GoogleFonts.ubuntuCondensed(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineLarge: GoogleFonts.ubuntuCondensed(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineMedium: GoogleFonts.ubuntuCondensed(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineSmall: GoogleFonts.ubuntuCondensed(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleLarge: GoogleFonts.ubuntuCondensed(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleMedium: GoogleFonts.ubuntuCondensed(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleSmall: GoogleFonts.ubuntuCondensed(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: GoogleFonts.ubuntuCondensed(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    bodyMedium: GoogleFonts.ubuntuCondensed(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    bodySmall: GoogleFonts.ubuntuCondensed(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Colors.white.withAlpha(204), // 80% opacity
    ),
    labelLarge: GoogleFonts.ubuntuCondensed(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    labelMedium: GoogleFonts.ubuntuCondensed(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    labelSmall: GoogleFonts.ubuntuCondensed(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: Colors.white.withAlpha(153), // 60% opacity
    ),
  ),
);

// ✅ DODATKOWE KOLORY DLA TOASTÓW I STANÓW
class AppColors {
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  static const Color primary = Color(0xFFAE9174);
  static const Color secondary = Color(0xFF4C2F1F);
  static const Color surface = Color(0xFF1C1B1B);
  static const Color accent = Color(0xFFBAB1A4);
}

// ✅ ROZMIARY I ODSTĘPY
class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double borderRadius = 8.0;
  static const double borderRadiusLarge = 16.0;
  
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
}