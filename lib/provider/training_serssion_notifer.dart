import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/training_session.dart';
import 'package:work_plan_front/services/trainingSessions.dart';

// ✅ ZMIEŃ NA ASYNCVALUE
class CompletedTrainingSessionNotifier extends StateNotifier<AsyncValue<List<TrainingSession>>> {
  final TrainingSessionService _service;

  CompletedTrainingSessionNotifier(this._service) : super(const AsyncValue.loading()) {
    fetchSessions(); // ✅ AUTOMATYCZNE ŁADOWANIE
  }

  Future<void> fetchSessions({bool forceRefresh = false}) async {
    try {
      // ✅ USTAW LOADING TYLKO PRZY FORCE REFRESH
      if (forceRefresh) {
        state = const AsyncValue.loading();
      }
      
      print("🔍 Provider: fetchSessions() WEJŚCIE");
      final sessions = await _service.getUserTrainingSessions();
      print("🔍 Provider: Pobrano ${sessions.length} sesji");
      
      // ✅ USTAW DANE
      state = AsyncValue.data(sessions);
      
      print("🔍 Provider: fetchSessions() WYJŚCIE - SUCCESS");
    } catch (e, stackTrace) {
      print('❌ Provider: Błąd pobierania sesji: $e');
      print('❌ Stack trace: $stackTrace');
      
      // ✅ USTAW BŁĄD
      state = AsyncValue.error(e, stackTrace);
      
      print("🔍 Provider: fetchSessions() WYJŚCIE - ERROR");
    }
  }

  Future<void> deleteTrainingSessions(int id) async {
    try {
      await _service.deleteTrainingSession(id);
      
      // ✅ USUŃ Z AKTUALNEGO STANU
      state.whenData((sessions) {
        state = AsyncValue.data(
          sessions.where((session) => session.id != id).toList()
        );
      });
      
      print("✅ Sesja o ID $id została usunięta");
    } catch (e, stackTrace) {
      print("❌ Błąd podczas usuwania sesji: $e");
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // ✅ DODAJ METODĘ DO DODAWANIA SESJI
  void addSession(TrainingSession session) {
    state.whenData((sessions) {
      state = AsyncValue.data([session, ...sessions]);
    });
  }
}

// ✅ ZMIEŃ PROVIDER NA ASYNCVALUE
final trainingSessionAsyncProvider = 
    StateNotifierProvider<CompletedTrainingSessionNotifier, AsyncValue<List<TrainingSession>>>((ref) {
  return CompletedTrainingSessionNotifier(TrainingSessionService());
});