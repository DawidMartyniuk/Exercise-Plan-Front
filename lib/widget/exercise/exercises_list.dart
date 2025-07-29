import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/screens/exercise_info.dart';
import 'dart:convert'; // ✅ DODAJ dla base64
import 'dart:typed_data'; // ✅ DODAJ
import 'package:work_plan_front/utils/imge_untils.dart'; // ✅ DODAJ dla obrazków

class ExerciseList extends StatelessWidget {
  final List<Exercise> exercise;

  const ExerciseList({super.key, required this.exercise});

  // ✅ NOWA METODA: Konwertuj base64 data URL na Uint8List
  Uint8List? _decodeBase64Image(String? gifUrl) {
    if (gifUrl == null || !gifUrl.startsWith('data:image')) {
      return null;
    }
    
    try {
      // Usuń prefix "data:image/gif;base64," lub podobny
      final base64String = gifUrl.split(',').last;
      return base64Decode(base64String);
    } catch (e) {
      print("❌ Błąd dekodowania base64: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: exercise.length,
      itemBuilder: (context, index) {
        final currentExercise = exercise[index];
        
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ExerciseInfoScreen(exercise: currentExercise),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ImageUtils.buildImage(
                        imageUrl: currentExercise.gifUrl,
                         context: context,
                        width: 60,
                        height: 60,
                        placeholder: ImageUtils.buildSmallPlaceholder(context, size: 60),
                         ),
                    ),
                  ),
                  
                  SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentExercise.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          currentExercise.formattedBodyPart,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ExerciseInfoScreen(exercise: currentExercise),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ NOWA METODA: Buduj odpowiedni widget obrazka
  Widget _buildExerciseImage(BuildContext context, Exercise exercise) {
    final imageBytes = _decodeBase64Image(exercise.gifUrl);
    
    if (imageBytes != null) {
      // ✅ Użyj MemoryImage dla base64
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("❌ Błąd MemoryImage dla ${exercise.name}: $error");
          return _buildPlaceholder(context);
        },
      );
    } else if (exercise.gifUrl != null && 
               exercise.gifUrl!.isNotEmpty && 
               exercise.gifUrl!.startsWith('http')) {
      // ✅ Użyj NetworkImage dla HTTP URL
      return Image.network(
        exercise.gifUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print("❌ Błąd NetworkImage dla ${exercise.name}: $error");
          return _buildPlaceholder(context);
        },
      );
    } else {
      // ✅ Fallback placeholder
      return _buildPlaceholder(context);
    }
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Icon(
      Icons.fitness_center,
      color: Theme.of(context).colorScheme.primary,
      size: 30,
    );
  }
}
