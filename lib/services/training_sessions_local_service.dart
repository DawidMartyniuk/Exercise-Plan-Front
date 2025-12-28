import 'package:hive/hive.dart';
import '../model/training_session.dart';

class TrainingSessionLocalService {
  static const String _boxName = 'trainingSessionsBox';

  Future<void> saveSessions(List<TrainingSession> sessions) async {
    final box = await Hive.openBox<TrainingSession>(_boxName);
    await box.clear();
    for (final session in sessions) {
      await box.put(session.id, session);
    }
  }

  Future<List<TrainingSession>> getSessions() async {
    final box = await Hive.openBox<TrainingSession>(_boxName);
    return box.values.toList();
  }

  Future<void> deleteSession(int sessionId) async {
    final box = await Hive.openBox<TrainingSession>(_boxName);
    await box.delete(sessionId);
  }
}