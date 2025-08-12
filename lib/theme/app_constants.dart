class AppConstants {
  // SINGLETON PATTERN
  static final AppConstants _instance = AppConstants._internal();
  factory AppConstants() => _instance;
  AppConstants._internal();

  // API URLs
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  // Hive Boxes
  static const String exerciseBoxName = 'exerciseBox';
  static const String userBoxName = 'userBox';
  
  // ✅ MODYFIKOWALNE ZMIENNE ĆWICZEŃ
  int exerciseStart = 0;
  int exerciseLimit = 100;
  
  // Stałe limity
  static const int exerciseMaxLimit = 1000;
  static const int maxImageSize = 512;
  static const int imageQuality = 80;

  // ✅ GETTERY 
  int get exerciseBatchSize => exerciseLimit - exerciseStart;
  int get exerciseStartIndex => exerciseStart;
  int get exerciseLimitIndex => exerciseLimit;

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration toastDuration = Duration(seconds: 3);
  
  // Strings
  static const String appName = 'Exercise Plan App';
  static const String defaultBio = 'Enter your bio here';
  static const String defaultWeight = '70';

  //  METODY DO AKTUALIZACJI
  void updateExerciseRange({required int start, required int limit}) {
    if (limit > start && limit <= exerciseMaxLimit) {
      exerciseStart = start;
      exerciseLimit = limit;
      print(" Zaktualizowano zakres ćwiczeń: $start - $limit");
    } else {
      print(" Nieprawidłowy zakres: limit ($limit) musi być > start ($start) i <= $exerciseMaxLimit");
    }
  }

  void resetToDefaults() {
    exerciseStart = 0;
    exerciseLimit = 100;
    print("🔄 Przywrócono domyślne wartości: 0 - 100");
  }

  //  DEBUG INFO
  void printCurrentSettings() {
    print("📊 Aktualne ustawienia:");
    print("   - Start: $exerciseStart");
    print("   - Limit: $exerciseLimit");
    print("   - Batch Size: $exerciseBatchSize");
  }
}