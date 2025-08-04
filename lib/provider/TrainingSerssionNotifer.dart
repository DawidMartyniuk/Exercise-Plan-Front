import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/TrainingSesions.dart';
import 'package:work_plan_front/serwis/trainingSessions.dart';

class CompletedTrainingSessionNotifier extends StateNotifier<List<TrainingSession>> {
  CompletedTrainingSessionNotifier() : super([]) {
    print("🚀 KONSTRUKTOR: CompletedTrainingSessionNotifier tworzony!");
    _autoLoad();
  }

  final TrainingSessionService _service = TrainingSessionService();

  void _autoLoad() async {
    print("🔄 _autoLoad: Rozpoczynam!");
    try {
      print("🔄 TrainingSessionNotifier: Auto-loading sessions...");
      await fetchSessions();
      print("✅ TrainingSessionNotifier: Auto-load completed with ${state.length} sessions");
    } catch (e) {
      print("❌ Auto-load training sessions error: $e");
      print("❌ Stack trace: ${StackTrace.current}");
    }
    print("🔄 _autoLoad: Kończę!");
  }

  void addSession(TrainingSession session) {
    print("🔍 Provider: Dodaję sesję do stanu");
    state = [...state, session];
    print("🔍 Provider: Nowy stan ma ${state.length} sesji");
  }

  // ✅ Pobierz sesje dla zalogowanego użytkownika
  Future<void> fetchSessions({bool forceRefresh = false}) async {
    print("🔍 Provider: fetchSessions() WEJŚCIE (forceRefresh: $forceRefresh)");
    
    try {
      print("🔍 Provider: Rozpoczynam pobieranie sesji... (forceRefresh: $forceRefresh)");
      
      // ✅ DODAJ TIMEOUT
      final sessions = await _service.getUserTrainingSessions().timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print("⏰ TIMEOUT: getUserTrainingSessions() trwało zbyt długo");
          return <TrainingSession>[];
        },
      );
      
      print("🔍 Provider: Pobrano ${sessions.length} sesji z serwisu");
      
      if (sessions.isEmpty) {
        print("⚠️ Provider: Serwis zwrócił 0 sesji - sprawdź API");
      }
      
      // ✅ SORTUJ OD NAJNOWSZYCH
      sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      
      // ✅ DEBUG - POKAŻ PIERWSZE 3 SESJE
      for (final session in sessions.take(3)) {
        print("🕐 Sesja ID=${session.id}, Data=${session.startedAt}, PlanID=${session.exerciseTableId}");
      }
      
      state = sessions;
      print("🔍 Provider: Stan zaktualizowany, teraz ma ${state.length} sesji");
      print("🔍 Provider: fetchSessions() WYJŚCIE - SUCCESS");
      
    } catch (e, stackTrace) {
      print('❌ Provider: Błąd pobierania sesji: $e');
      print('❌ Stack trace: $stackTrace');
      print("🔍 Provider: fetchSessions() WYJŚCIE - ERROR");
    }
  }

  // ✅ Zapisz sesję do backendu i dodaj do stanu
  Future<void> saveSession(TrainingSession session) async {
    try {
      await _service.saveTrainingSession(session);
      
      // ✅ ODŚWIEŻ CAŁY STAN PO ZAPISANIU
      await fetchSessions(forceRefresh: true);
      
      print("✅ Sesja zapisana i stan odświeżony");
    } catch (e) {
      print('❌ Error saving session: $e');
      rethrow;
    }
  }

  // ✅ WYCZYŚĆ WSZYSTKIE SESJE
  void clearSessions() {
    state = [];
    print("🗑️ Wyczyszczono wszystkie sesje");
  }
}

final completedTrainingSessionProvider = StateNotifierProvider<CompletedTrainingSessionNotifier, List<TrainingSession>>(
  (ref) => CompletedTrainingSessionNotifier(),
);