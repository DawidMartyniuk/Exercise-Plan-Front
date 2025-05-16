import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:work_plan_front/model/exercise.dart';
import 'package:hive/hive.dart';

class ExerciseService {
  final String _baseUrl = "https://exercisedb.p.rapidapi.com/exercises";
  final String _limit = "?limit=50";
  final String _offset = "&offset=0";

  Future<List<Exercise>?> exerciseList() async {
    final response = await http.get(Uri.parse("$_baseUrl$_limit$_offset"),
    headers: {
      'x-rapidapi-key': '9ab0213a17msh00a1dc6e0dc0d7ap11abe4jsn40c075e5b5a1',
      'x-rapidapi-host': 'exercisedb.p.rapidapi.com',
      'Content-Type': 'application/json',
    },
    );



  if (response.statusCode == 200) {
    final List<dynamic> responseBody = json.decode(response.body);
    return responseBody.map((data) => Exercise.fromJson(data)).toList();
  } else {
    print('Error fetching exercises: ${response.statusCode}');
    return null; 
  }
}
}