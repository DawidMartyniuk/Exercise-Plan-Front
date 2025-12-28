import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

class ToastUtils {
  /// Wyświetla toast sukcesu
  static void showSuccessToast({
    required BuildContext context,
    String? title,
    required String message,
    Duration? duration,
    AnimationType? animationType,
    bool dismissable = true,
  }) {
    MotionToast.success(
      title: title != null
          ? Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          : null,
      description: Text(message),
      toastDuration: duration ?? Duration(seconds: 3),
      animationType: animationType ?? AnimationType.slideInFromTop,
      dismissable: dismissable,
    ).show(context);
  }

  /// Wyświetla toast błędu
  static void showErrorToast({
    required BuildContext context,
    String? title,
    required String message,
    Duration? duration,
    AnimationType? animationType,
    bool dismissable = true,
  }) {
    MotionToast.error(
      title: title != null
          ? Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            )
          : null,
      description: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      toastDuration: duration ?? Duration(seconds: 4),
      animationType: animationType ?? AnimationType.slideInFromLeft,
      dismissable: dismissable,
    ).show(context);
  }

  /// Wyświetla toast informacyjny
  static void showInfoToast({
    required BuildContext context,
    String? title,
    required String message,
    Duration? duration,
    AnimationType? animationType,
    bool dismissable = true,
  }) {
    MotionToast.info(
      title: title != null
          ? Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            )
          : null,
      description: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      toastDuration: duration ?? Duration(seconds: 3),
      animationType: animationType ?? AnimationType.slideInFromRight,
      dismissable: dismissable,
    ).show(context);
  }

  /// Wyświetla toast ostrzeżenia/ładowania
  static void showWarningToast({
    required BuildContext context,
    String? title,
    required String message,
    Duration? duration,
    AnimationType? animationType,
    bool dismissable = true,
  }) {
    MotionToast.warning(
      title: title != null
          ? Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            )
          : null,
      description: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      toastDuration: duration ?? Duration(seconds: 2),
      animationType: animationType ?? AnimationType.slideInFromBottom,
      dismissable: dismissable,
    ).show(context);
  }

  /// Wyświetla toast usuwania
  static void showDeleteToast({
    required BuildContext context,
    String? title,
    required String message,
    Duration? duration,
    AnimationType? animationType,
    bool dismissable = true,
  }) {
    MotionToast.delete(
      title: title != null
          ? Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            )
          : null,
      description: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      toastDuration: duration ?? Duration(seconds: 3),
      animationType: animationType ?? AnimationType.slideInFromLeft,
      dismissable: dismissable,
    ).show(context);
  }

  // ===== PREDEFINIOWANE TOASTY DLA KONKRETNYCH PRZYPADKÓW =====

  /// Toast logowania - sukces
  static void showLoginSuccess(BuildContext context, {String? userName}) {
    showSuccessToast(
      context: context,
      title: "Login Successful!",
      message: userName != null 
          ? "Welcome back, $userName! You have been logged in successfully."
          : "Welcome back! You have been logged in successfully.",
      animationType: AnimationType.slideInFromTop,
    );
  }

  /// Toast logowania - błąd
  static void showLoginError(BuildContext context, {String? customMessage}) {
    showErrorToast(
      context: context,
      title: "Login Failed",
      message: customMessage ?? "Invalid email or password. Please try again.",
      animationType: AnimationType.slideInFromLeft,
    );
  }

  /// Toast ładowania logowania
  static void showLoginLoading(BuildContext context) {
    showWarningToast(
      context: context,
      title: "Logging in...",
      message: "Please wait while we authenticate your credentials.",
      duration: Duration(seconds: 2),
      animationType: AnimationType.slideInFromBottom,
    );
  }

  /// Toast rejestracji - sukces
  static void showRegistrationSuccess(BuildContext context) {
    showSuccessToast(
      context: context,
      title: "Registration Successful!",
      message: "Your account has been created successfully. Please login.",
      animationType: AnimationType.slideInFromTop,
    );
  }

  /// Toast rejestracji - błąd
  static void showRegistrationError(BuildContext context, {String? customMessage}) {
    showErrorToast(
      context: context,
      title: "Registration Failed",
      message: customMessage ?? "Failed to create account. Please try again.",
      animationType: AnimationType.slideInFromLeft,
    );
  }

  /// Toast walidacji formularza
  static void showValidationError(BuildContext context, {String? customMessage}) {
    showErrorToast(
      context: context,
      title: "Validation Error",
      message: customMessage ?? "Please fill in all fields correctly.",
      duration: Duration(seconds: 3),
      animationType: AnimationType.slideInFromLeft,
    );
  }

  /// Toast braku połączenia
  static void showConnectionError(BuildContext context) {
    showErrorToast(
      context: context,
      title: "Connection Error",
      message: "Please check your internet connection and try again.",
      duration: Duration(seconds: 4),
      animationType: AnimationType.slideInFromBottom,
    );
  }

  /// Toast funkcji niedostępnej
  static void showFeatureComingSoon(BuildContext context, {String? featureName}) {
    showInfoToast(
      context: context,
      title: "Coming Soon",
      message: featureName != null 
          ? "$featureName feature is coming soon!"
          : "This feature is coming soon!",
      animationType: AnimationType.slideInFromRight,
    );
  }

  /// Toast zapisywania danych
  static void showSaveSuccess(BuildContext context, {String? itemName}) {
    showSuccessToast(
      context: context,
      title: "Saved Successfully",
      message: itemName != null 
          ? "$itemName has been saved successfully."
          : "Data has been saved successfully.",
      animationType: AnimationType.slideInFromTop,
    );
  }

  /// Toast usuwania danych
  static void showDeleteSuccess(BuildContext context, {String? itemName}) {
    showDeleteToast(
      context: context,
      title: "Deleted Successfully",
      message: itemName != null 
          ? "$itemName has been deleted successfully."
          : "Item has been deleted successfully.",
      animationType: AnimationType.slideInFromLeft,
    );
  }

  /// Toast błędu podczas ładowania
  static void showLoadingError(BuildContext context, {String? customMessage}) {
    showErrorToast(
      context: context,
      title: "Loading Error",
      message: customMessage ?? "Failed to load data. Please try again.",
      animationType: AnimationType.slideInFromBottom,
    );
  }

  /// Toast rozpoczęcia treningu
  static void showWorkoutStarted(BuildContext context, {String? workoutName}) {
    showSuccessToast(
      context: context,
      title: "Workout Started",
      message: workoutName != null 
          ? "Started $workoutName. Good luck!"
          : "Workout started. Good luck!",
      animationType: AnimationType.slideInFromTop,
    );
  }

  /// Toast zakończenia treningu
  static void showWorkoutCompleted(BuildContext context, {String? duration}) {
    showSuccessToast(
      context: context,
      title: "Workout Completed!",
      message: duration != null 
          ? "Great job! You completed your workout in $duration."
          : "Great job! You completed your workout.",
      duration: Duration(seconds: 4),
      animationType: AnimationType.slideInFromTop,
    );
  }

  /// Toast dodania do ulubionych
  static void showAddedToFavorites(BuildContext context, {String? itemName}) {
    showSuccessToast(
      context: context,
      title: "Added to Favorites",
      message: itemName != null 
          ? "$itemName has been added to your favorites."
          : "Item has been added to your favorites.",
      animationType: AnimationType.slideInFromRight,
    );
  }

  /// Toast usunięcia z ulubionych
  static void showRemovedFromFavorites(BuildContext context, {String? itemName}) {
    showInfoToast(
      context: context,
      title: "Removed from Favorites",
      message: itemName != null 
          ? "$itemName has been removed from your favorites."
          : "Item has been removed from your favorites.",
      animationType: AnimationType.slideInFromLeft,
    );
  }
}