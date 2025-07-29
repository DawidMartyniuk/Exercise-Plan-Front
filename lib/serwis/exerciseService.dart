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
    print("⬇️ Pobieram ćwiczenia z API (cache wyłączony)...");

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
      final List<Exercise> exercises = [];
       
      // ✅ OPCJA 1: Pobierz wszystkie obrazki równolegle
      final futures = <Future<String>>[];
      final exerciseItems = <Exercise>[];
      
      for(int i = 0; i < exerciseJson.length; i++) {
        final exerciseData = exerciseJson[i];
        final exerciseItem = Exercise.fromJson(exerciseData);
        exerciseItems.add(exerciseItem);
        
        // ✅ Dodaj zadanie pobierania obrazka do listy
        futures.add(_getExerciseImageUrl(exerciseItem.id));
      }
      
      // ✅ Poczekaj na wszystkie obrazki
      print("🖼️ Pobieram ${futures.length} obrazków równolegle...");
      final gifUrls = await Future.wait(futures);
      
      // ✅ Połącz ćwiczenia z obrazkami
      for(int i = 0; i < exerciseItems.length; i++) {
        final exerciseItem = exerciseItems[i];
        final gifUrl = gifUrls[i];
        
        final finalExercise = Exercise(
          id: exerciseItem.id,
          name: exerciseItem.name,
          bodyPart: exerciseItem.bodyPart,
          equipment: exerciseItem.equipment,
          gifUrl: gifUrl.isNotEmpty ? gifUrl : null, // ✅ Null gdy pusty
          target: exerciseItem.target,
          secondaryMuscles: exerciseItem.secondaryMuscles,
          instructions: exerciseItem.instructions,
          description: exerciseItem.description,
          difficulty: exerciseItem.difficulty,
          category: exerciseItem.category,
        );
        
        exercises.add(finalExercise);
        print("✅ ${exerciseItem.name} - ${gifUrl.isNotEmpty ? 'z obrazkiem' : 'bez obrazka'} (${i+1}/${exerciseItems.length})");
      }
      
      print("✅ Pobrano ${exercises.length} ćwiczeń z API");
      return exercises;
      
    } catch (e) {
      print('❌ Błąd pobierania ćwiczeń: $e');
      return [];
    }
  }

  /// ✅ NOWA METODA: Pobiera URL obrazka dla konkretnego ćwiczenia
  Future<String> _getExerciseImageUrl(String exerciseId) async {
    try {
      // ✅ Formatuj ID do 4 cyfr z zerami wiodącymi
      final String formattedId = exerciseId.padLeft(4, '0');
      
      final imageResponse = await http.get(
        Uri.parse("$_baseUrl$_imageEndpoint?exerciseId=$formattedId&resolution=180"),
        headers: _headers,
      );

      if (imageResponse.statusCode == 200) {
        // ✅ SPRAWDŹ Content-Type odpowiedzi
        final contentType = imageResponse.headers['content-type'];
        
        if (contentType?.contains('json') == true) {
          // ✅ API zwraca JSON z URL
          final imageData = json.decode(imageResponse.body);
          final url = imageData['url'] ?? imageData['image'] ?? imageData['gifUrl'] ?? '';
          print("🔍 JSON response dla $formattedId: $imageData");
          return url;
          
        } else if (imageResponse.body.startsWith('http')) {
          // ✅ API zwraca bezpośrednio URL
          final url = imageResponse.body.trim();
          print("🔍 Direct URL dla $formattedId: $url");
          return url;
          
        } else if (contentType?.startsWith('image/') == true) {
          // ✅ API zwraca bezpośrednio obrazek
          final bytes = imageResponse.bodyBytes;
          final base64String = base64Encode(bytes);
          final dataUrl = 'data:$contentType;base64,$base64String';
          print("🔍 Image data dla $formattedId: ${dataUrl.length} znaków");
          return dataUrl;
          
        } else {
          print('⚠️ Nieoczekiwany format dla $formattedId: $contentType');
          print('⚠️ Body: ${imageResponse.body.substring(0, 100)}...');
          return '';
        }
      } else {
        print('❌ Błąd pobierania obrazka dla $formattedId: ${imageResponse.statusCode}');
        return '';
      }
    } catch (e) {
      print('❌ Błąd pobierania obrazka dla $exerciseId: $e');
      return '';
    }
  }

  // ✅ W exerciseService.dart - dodaj metodę do czyszczenia cache
  Future<void> clearCache() async {
    final box = await Hive.openBox('exerciseBox');
    await box.clear();
    print("🗑️ Cache ćwiczeń wyczyszczony");
  }
}

