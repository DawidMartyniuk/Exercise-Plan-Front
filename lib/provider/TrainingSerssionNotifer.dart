import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/TrainingSesions.dart';
import 'package:work_plan_front/serwis/trainingSessions.dart';

// StateNotifier do zarządzania listą sesji
class CompletedTrainingSessionNotifier extends StateNotifier<List<TrainingSession>> {
  CompletedTrainingSessionNotifier() : super([]);

  final TrainingSessionService _service = TrainingSessionService();

  void addSession(TrainingSession session) {
    print("🔍 Provider: Dodaję sesję do stanu");
    state = [...state, session];
    print("🔍 Provider: Nowy stan ma ${state.length} sesji");
  }

  // ✅ Pobierz sesje dla zalogowanego użytkownika
  Future<void> fetchSessions() async {
    try {
      print("🔍 Provider: Rozpoczynam pobieranie sesji...");
      final sessions = await _service.getUserTrainingSessions();
      print("🔍 Provider: Pobrano ${sessions.length} sesji z serwisu");
      print("🔍 Provider: Sesje: $sessions");
      
      state = sessions;
      print("🔍 Provider: Stan zaktualizowany, teraz ma ${state.length} sesji");
    } catch (e) {
      print('❌ Provider: Błąd pobierania sesji: $e');
    }
  }

  // ✅ Zapisz sesję do backendu i dodaj do stanu
  Future<void> saveSession(TrainingSession session) async {
    try {
      await _service.saveTrainingSession(session);
      addSession(session);
    } catch (e) {
      print('Error saving session: $e');
      rethrow;
    }
  }
}

final completedTrainingSessionProvider = StateNotifierProvider<CompletedTrainingSessionNotifier, List<TrainingSession>>(
  (ref) => CompletedTrainingSessionNotifier(),
);