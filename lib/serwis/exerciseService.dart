import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:work_plan_front/model/exercise.dart';
import 'package:hive/hive.dart';

class ExerciseService {
  final String _baseUrl = "https://exercisedb.p.rapidapi.com/exercises";
  final String _limit = "?limit=50";
  final String _offset = "&offset=0";

  Future<List<Exercise>?> exerciseList({bool forceRefresh = false}) async {
  final box = await Hive.openBox('exerciseBox');
  final lastSync = box.get('lastSync') as DateTime?;
  final now = DateTime.now();

  // Jeśli nie wymuszamy odświeżenia i nie minęło 1h → użyj cache
 final bool shouldUpdate = forceRefresh || lastSync == null || now.difference(lastSync).inHours >= 1;

  if (!shouldUpdate) {
    print("✅ Używam lokalnej pamięci ćwiczeń");
    return box.values.whereType<Exercise>().toList();
  }

  // --- Jeśli trzeba pobrać nowe dane z API ---
  final response = await http.get(Uri.parse("$_baseUrl$_limit$_offset"),
    headers: {
      'x-rapidapi-key': '9ab0213a17msh00a1dc6e0dc0d7ap11abe4jsn40c075e5b5a1',
      'x-rapidapi-host': 'exercisedb.p.rapidapi.com',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> responseBody = json.decode(response.body);
    final exercises = responseBody.map((data) => Exercise.fromJson(data)).toList();

    // Wyczyść i zapisz nowe dane do Hive
    await box.clear();
    for (var ex in exercises) {
      await box.put(ex.id, ex);
    }

    await box.put('lastSync', now);
    print("⬇️ Dane zaktualizowane z API i zapisane lokalnie");
    return exercises;
  } else {
    print('❌ Błąd API: ${response.statusCode}. Używam danych z Hive.');
    return box.values.whereType<Exercise>().toList(); // fallback
  }
}

}