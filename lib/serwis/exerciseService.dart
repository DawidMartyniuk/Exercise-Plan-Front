import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:work_plan_front/model/exercise.dart';
import 'package:hive/hive.dart';
import 'dart:typed_data';

class ExerciseService {
  final String _baseUrl = "https://exercisedb.p.rapidapi.com";
    final String _exercisesEndpoint = "/exercises";
  final String _imageEndpoint = "/image";
  final String _limit = "?limit=50";
  final String _offset = "&offset=0";

   final Map<String, String> _headers = {
    'x-rapidapi-key': '9ab0213a17msh00a1dc6e0dc0d7ap11abe4jsn40c075e5b5a1',
    'x-rapidapi-host': 'exercisedb.p.rapidapi.com',
    'Content-Type': 'application/json',
  };

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
  
  print("⬇️ Pobieram nowe ćwiczenia z API...");

  try {
    final exerciseResponse = await http.get(
      Uri.parse("$_baseUrl$_exercisesEndpoint$_limit$_offset"),
      headers: _headers,
    );

    if(exerciseResponse.statusCode != 200) {
      print('❌ Błąd pobierania ćwiczeń: ${exerciseResponse.statusCode}');
      throw Exception("Failed to load exercises: ${exerciseResponse.statusCode}");
    }

    final List<dynamic> exerciseJson = json.decode(exerciseResponse.body);
    final List<Exercise> exercises = []; // Zmieniono nazwę na exercises (liczba mnoga)
     
    // Poprawka: i < exerciseJson.length (nie i >)
    for(int i = 0; i < exerciseJson.length; i++) {
      final exerciseData = exerciseJson[i];
      
      // Pobieranie zdjęć
      final String gifUrl = await _getExerciseImage(exerciseData['id'], resolution: "180");

      final exerciseItem = Exercise.fromJson({
        ...exerciseData,
        'gifUrl': gifUrl, // Dodaj URL zdjęcia
      });
      
      exercises.add(exerciseItem); // Dodaj do listy exercises
     print("🖼️ Pobrano: ${exerciseItem.name} (${i+1}/${exerciseJson.length})");
    }
    
    // Zapisz do cache
    await box.clear();
    for (var ex in exercises) {
      await box.put(ex.id, ex);
    }
    await box.put('lastSync', now);

    print("✅ Zaktualizowano ${exercises.length} ćwiczeń ze zdjęciami");
    return exercises;
    
  } catch (e) {
    print('❌ Błąd pobierania ćwiczeń: $e');
    return box.values.whereType<Exercise>().toList(); // fallback
  }
}
/// Pobiera URL zdjęcia dla konkretnego ćwiczenia
  Future<String> _getExerciseImage(String exerciseId, {required String resolution}) async {
    try {
      final imageResponse = await http.get(
        Uri.parse("$_baseUrl$_imageEndpoint?exerciseId=$exerciseId&resolution=$resolution"),
        headers: _headers,
      );

      if (imageResponse.statusCode == 200) {
        // ✅ SPRAWDŹ Content-Type zamiast zgadywać
        final contentType = imageResponse.headers['content-type'];
        
        if (contentType?.startsWith('image/') == true) {
          // ✅ To jest rzeczywisty obrazek - zwróć dane jako base64
          final bytes = imageResponse.bodyBytes;
          final base64String = base64Encode(bytes);
          return 'data:$contentType;base64,$base64String';
          
        } else if (contentType?.contains('json') == true) {
          // ✅ To jest JSON z URL
          final imageData = json.decode(imageResponse.body);
          return imageData['url'] ?? imageData['image_url'] ?? '';
          
        } else if (imageResponse.body.startsWith('http')) {
          // ✅ To jest bezpośredni URL
          return imageResponse.body.trim();
          
        } else {
          // ✅ To jest HTML lub coś innego - użyj fallback
          print('⚠️ Nieoczekiwany format odpowiedzi dla $exerciseId: $contentType');
          return _getFallbackGifUrl(exerciseId);
        }
      } else {
        print('❌ Błąd pobierania zdjęcia dla $exerciseId: ${imageResponse.statusCode}');
        return _getFallbackGifUrl(exerciseId);
      }
    } catch (e) {
      print('❌ Błąd pobierania zdjęcia dla $exerciseId: $e');
      return _getFallbackGifUrl(exerciseId);
    }
  }

  // ✅ DODAJ metodę fallback - używa publicznie dostępnych GIF-ów
  String _getFallbackGifUrl(String exerciseId) {
    // ExerciseDB ma publiczne GIF-y pod tym URL
    return 'https://v2.exercisedb.io/image/$exerciseId';
  }
}

