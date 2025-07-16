import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/TrainingSesions.dart';

// StateNotifier do zarządzania listą sesji
class CompletedTrainingSessionNotifier extends StateNotifier<List<TrainingSession>> {
  CompletedTrainingSessionNotifier() : super([]);

   void addSession(TrainingSession session) {
    state = [...state, session];
  }

    // Załaduj sesje z backendu (przykład, musisz dodać własny serwis)
  Future<void> fetchSessions(List<Map<String, dynamic>> jsonList) async {
    state = jsonList.map((json) => TrainingSession.fromJson(json)).toList();
  }
}

final completedTrainingSessionProvider = StateNotifierProvider<CompletedTrainingSessionNotifier, List<TrainingSession>>(
  (ref) => CompletedTrainingSessionNotifier(),
);