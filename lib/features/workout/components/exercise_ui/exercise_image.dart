import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/shared/utils/image_untils.dart';
import '../../helpers/plan_helpers.dart';

class ExerciseImage extends ConsumerWidget with PlanHelpers {
  final String exerciseId;
  final double size;
  final bool showBorder;

  const ExerciseImage({
    super.key,
    required this.exerciseId,
    this.size = 50,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = getExerciseImageUrl(exerciseId, ref);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder ? Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ) : null,
        color: Theme.of(context).colorScheme.primary.withAlpha(50),
      ),
      child: ClipOval(
        child: imageUrl?.isNotEmpty == true
            ? ImageUtils.buildImage(
                imageUrl: imageUrl!,
                context: context,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: _buildPlaceholderIcon(context),
              )
            : _buildPlaceholderIcon(context),
      ),
    );
  }

  Widget _buildPlaceholderIcon(BuildContext context) {
    return Icon(
      Icons.fitness_center,
      size: size * 0.4,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}