import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/provider/auth_provider.dart';
import 'package:work_plan_front/provider/exercise_plan_notifier.dart';
import 'package:work_plan_front/provider/exercise_provider.dart';
import 'package:work_plan_front/provider/training_serssion_notifer.dart';
import 'package:work_plan_front/provider/favorite_exercise_notifer.dart';

class AppInitializer {
  static Future<void> initialize() async {
    print("🚀 AppInitializer: Inicjalizacja aplikacji...");
    
    try {
      // ✅ PODSTAWOWA INICJALIZACJA
      await Future.delayed(Duration(milliseconds: 300));
      print("✅ Podstawowa inicjalizacja zakończona");
      
    } catch (e) {
      print("❌ Błąd podczas podstawowej inicjalizacji: $e");
      rethrow;
    }
  }

  // NOWA METODA - ŁADOWANIE WSZYSTKICH DANYCH
  static Future<void> loadAllData(WidgetRef ref) async {
    print("📊 AppInitializer: Ładowanie wszystkich danych...");
    
    try {
      // ✅ 1. SPRAWDŹ TOKEN UŻYTKOWNIKA
      print("🔑 Sprawdzanie tokena użytkownika...");
      final authNotifier = ref.read(authProviderLogin.notifier);
      final isLoggedIn = await authNotifier.validateToken();
      
      if (isLoggedIn) {
        print("✅ Użytkownik zalogowany - ładowanie danych...");
        
        // ✅ 2. ŁADUJ WSZYSTKIE DANE RÓWNOLEGLE
        await Future.wait([
          _loadExercises(ref),
          _loadExercisePlans(ref), 
          _loadTrainingSessions(ref),
          _loadFavoriteExercises(ref),
        ]);
        
        print("✅ Wszystkie dane załadowane pomyślnie");
      } else {
        print("ℹ️ Użytkownik niezalogowany - pominięto ładowanie danych");
      }
      
    } catch (e) {
      print("❌ Błąd podczas ładowania danych: $e");
      // ✅ NIE RZUCAJ BŁĘDU - POZWÓL APLIKACJI SIĘ URUCHOMIĆ
      print("⚠️ Kontynuowanie bez preloadowanych danych");
    }
  }

  // ✅ ŁADOWANIE ĆWICZEŃ
  static Future<void> _loadExercises(WidgetRef ref) async {
    try {
      print("🏃‍♀️ Ładowanie ćwiczeń...");
      await ref.read(exerciseProvider.notifier).fetchExercises();
      print("✅ Ćwiczenia załadowane");
    } catch (e) {
      print("❌ Błąd ładowania ćwiczeń: $e");
    }
  }

  // ✅ ŁADOWANIE PLANÓW TRENINGOWYCH
  static Future<void> _loadExercisePlans(WidgetRef ref) async {
    try {
      print("📋 Ładowanie planów treningowych...");
      await ref.read(exercisePlanProvider.notifier).fetchExercisePlans();
      print("✅ Plany treningowe załadowane");
    } catch (e) {
      print("❌ Błąd ładowania planów: $e");
    }
  }

  // ✅ ŁADOWANIE SESJI TRENINGOWYCH
  static Future<void> _loadTrainingSessions(WidgetRef ref) async {
    try {
      print("📈 Ładowanie sesji treningowych...");
      await ref.read(trainingSessionAsyncProvider.notifier).fetchSessions();
      print("✅ Sesje treningowe załadowane");
    } catch (e) {
      print("❌ Błąd ładowania sesji treningowych: $e");
    }
  }

  // ✅ ŁADOWANIE ULUBIONYCH ĆWICZEŃ
  static Future<void> _loadFavoriteExercises(WidgetRef ref) async {
    try {
      print("⭐ Ładowanie ulubionych ćwiczeń...");
      ref.read(favoriteExerciseProvider.notifier).loadFavorites();
      print("✅ Ulubione ćwiczenia załadowane");
    } catch (e) {
      print("❌ Błąd ładowania ulubionych ćwiczeń: $e");
    }
  }

  // ✅ SPRAWDŹ CZY DANE SĄ GOTOWE
  static bool areDataLoaded(WidgetRef ref) {
    try {
      final exercisesAsync = ref.read(exerciseProvider);
      final plansAsync = ref.read(exercisePlanProvider);
      final sessionsAsync = ref.read(trainingSessionAsyncProvider);

      // ✅ SPRAWDŹ CZY PODSTAWOWE DANE SĄ ZAŁADOWANE
      final hasExercises = exercisesAsync.hasValue && exercisesAsync.value != null && exercisesAsync.value!.isNotEmpty;
      final hasPlans = plansAsync.isNotEmpty;
      final hasSessionsData = sessionsAsync.hasValue;

      print("🔍 Stan danych: exercises=$hasExercises, plans=$hasPlans, sessions=$hasSessionsData");

      return hasExercises && hasPlans && hasSessionsData;
    } catch (e) {
      print("❌ Błąd sprawdzania stanu danych: $e");
      return false;
    }
  }
}