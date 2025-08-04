import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'dart:convert'; // ✅ DODAJ
import 'dart:typed_data';

import 'package:work_plan_front/utils/imge_untils.dart'; // ✅ DODAJ

class ExerciseInfoScreen extends ConsumerStatefulWidget {
  const ExerciseInfoScreen({super.key, required this.exercise});

  final Exercise exercise;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ExerciseInfoScreenState();
  }
}

class _ExerciseInfoScreenState extends ConsumerState<ExerciseInfoScreen> {
  void setFavoriteExercise() {
    // TODO: Implementacja dodawania do ulubionych
  }

  // ✅ KOPIUJ metodę z exercises_list.dart
  Uint8List? _decodeBase64Image(String? gifUrl) {
    if (gifUrl == null || !gifUrl.startsWith('data:image')) {
      return null;
    }

    try {
      final base64String = gifUrl.split(',').last;
      return base64Decode(base64String);
    } catch (e) {
      print("❌ Błąd dekodowania base64: $e");
      return null;
    }
  }

  // Widget _buildExerciseImage() {
  //   final exercise = widget.exercise;
  //   final imageBytes = _decodeBase64Image(exercise.gifUrl);

  //   if (imageBytes != null) {
  //     return Image.memory(
  //       imageBytes,
  //       width: double.infinity,
  //       height: 300,
  //       fit: BoxFit.cover,
  //       errorBuilder: (context, error, stackTrace) {
  //         print("❌ Błąd MemoryImage dla ${exercise.name}: $error");
  //         return _buildPlaceholder();
  //       },
  //     );
  //   } else if (exercise.gifUrl != null &&
  //       exercise.gifUrl!.isNotEmpty &&
  //       exercise.gifUrl!.startsWith('http')) {
  //     return Image.network(
  //       exercise.gifUrl!,
  //       width: double.infinity,
  //       height: 300,
  //       fit: BoxFit.cover,
  //       errorBuilder: (context, error, stackTrace) {
  //         return _buildPlaceholder();
  //       },
  //     );
  //   } else {
  //     return _buildPlaceholder();
  //   }
  // }

  // Widget _buildPlaceholder() {
  //   return Container(
  //     width: double.infinity,
  //     height: 300,
  //     color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
  //     child: Icon(
  //       Icons.fitness_center,
  //       size: 100,
  //       color: Theme.of(context).colorScheme.primary,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        actions: [
          IconButton(
            onPressed: setFavoriteExercise,
            icon: Icon(Icons.favorite_border),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ UŻYJ nowej metody
               ImageUtils.buildImage(
                imageUrl: exercise.gifUrl,
                 context: context,
                 width: double.infinity,
                 height: 300,
                 placeholder: ImageUtils.buildLargePlaceholder(context),
                 ),
                const SizedBox(height: 20),
                Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Body Part: ${exercise.bodyPart}', // ✅ UŻYWAJ formattedBodyPart
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Equipment: ${exercise.equipment}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Target: ${exercise.target}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 20),
                // ✅ DODAJ sekcję z instrukcjami
                if (exercise.instructions.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Instructions:',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...exercise.instructions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final instruction = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}. ',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Expanded(
                            child: Text(
                              instruction,
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
