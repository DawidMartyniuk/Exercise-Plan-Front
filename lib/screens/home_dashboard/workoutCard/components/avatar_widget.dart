import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard/helper/workout_card_helpers.dart';

class AvatarWidget extends ConsumerWidget with WorkoutCardHelpers {
  final double size;
  final double borderWidth;
  final double iconSize;

  const AvatarWidget({
    super.key,
    this.size = 40,
    this.borderWidth = 2,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: borderWidth,
        ),
        color: Theme.of(context).colorScheme.primary.withAlpha(50),
      ),
      child: ClipOval(
        child: _buildAvatarImage(context, ref),
      ),
    );
  }

  Widget _buildAvatarImage(BuildContext context, WidgetRef ref) {
    final imageBase64 = getProfileImage(ref);

    if (imageBase64.isEmpty) {
      return Icon(
        Icons.person,
        size: iconSize,
        color: Theme.of(context).colorScheme.primary,
      );
    }

    try {
      // ✅ USUŃ PREFIX JEŚLI ISTNIEJE (data:image/jpeg;base64,)
      String cleanBase64 = imageBase64;
      if (imageBase64.contains(',')) {
        cleanBase64 = imageBase64.split(',').last;
      }

      // ✅ DEKODUJ BASE64
      Uint8List imageBytes = base64Decode(cleanBase64);

      // ✅ ZWRÓĆ OBRAZEK Z PAMIĘCI
      return Image.memory(
        imageBytes,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // ✅ JEŚLI BŁĄD DEKODOWANIA - POKAŻ IKONĘ
          return Icon(
            Icons.person,
            size: iconSize,
            color: Theme.of(context).colorScheme.primary,
          );
        },
      );
    } catch (e) {
      print("❌ Błąd dekodowania base64: $e");
      return Icon(
        Icons.person,
        size: iconSize,
        color: Theme.of(context).colorScheme.primary,
      );
    }
  }
}