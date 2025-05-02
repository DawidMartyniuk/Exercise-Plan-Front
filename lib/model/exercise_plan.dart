class ExercisePlan {
  final userId;
  final Map<String, List<Map<String, dynamic>>> exercises;

  ExercisePlan({
    required this.userId,
    required this.exercises,
  });

  Map<String,dynamic> toJson(){ 
    return {
      'user_id': userId,
      'exercises': exercises,
    };
  }
  

  factory ExercisePlan.fromJson(Map<String, dynamic> json) {
    return ExercisePlan(
      userId: json["userId"] as String,
      exercises: Map<String, List<Map<String, String>>>.from(
        json["exercises"] as Map,
      ),
    );
  }
  
}