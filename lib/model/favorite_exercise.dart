import 'package:hive/hive.dart';

part 'favorite_exercise.g.dart';

@HiveType(typeId: 1)
class FavoriteExercise extends HiveObject {
  @HiveField(0)
  final String exerciseId;

  @HiveField(1)
  final DateTime addedAt;

  FavoriteExercise({
    required this.exerciseId,
    required this.addedAt,
  });
}