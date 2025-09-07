import 'package:flutter/material.dart';
import 'package:work_plan_front/utils/image_untils.dart';

class ExerciseImageWidget extends StatelessWidget {
  const ExerciseImageWidget({
    super.key,
    required this.imageUrl,
    required this.height,
    this.isLarge = false,
  });

  final String imageUrl;
  final double height;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      margin: EdgeInsets.only(bottom: isLarge ? 0 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: isLarge ? 12 : 8,
            offset: Offset(0, isLarge ? 6 : 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
        child: ImageUtils.buildImage(
          imageUrl: imageUrl,
          context: context,
          width: double.infinity,
          height: height,
          fit: BoxFit.contain,
          isLargeImage: isLarge,
          placeholder: ImageUtils.buildLargePlaceholder(
            context,
            width: double.infinity,
            height: height,
          ),
        ),
      ),
    );
  }
}