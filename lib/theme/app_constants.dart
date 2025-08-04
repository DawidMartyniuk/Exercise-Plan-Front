class AppConstants {
  // API URLs
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  // Hive Boxes
  static const String exerciseBoxName = 'exerciseBox';
  static const String userBoxName = 'userBox';
  
  // Limits
  static const int exerciseLimit = 100;
  static const int maxImageSize = 512;
  static const int imageQuality = 80;
  
  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration toastDuration = Duration(seconds: 3);
  
  // Strings
  static const String appName = 'Exercise Plan App';
  static const String defaultBio = 'Enter your bio here';
  static const String defaultWeight = '70';
}