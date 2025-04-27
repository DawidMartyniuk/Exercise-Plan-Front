import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:work_plan_front/model/exercise_plan.dart';

Future<void> saveExercisePlan(ExercisePlan exercisePlan) async {
  final url = Uri.parse("https://example.com/api/exercise-plans");
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(exercisePlan.toJson()),
  );

  if (response.statusCode == 200) {
    print("Exercise plan saved successfully!");
  } else {
    print("Failed to save exercise plan: ${response.body}");
  }
}