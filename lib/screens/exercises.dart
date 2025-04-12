import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/widget/body_part_grid_item.dart';
import 'package:work_plan_front/widget/body_part_selected.dart' as selected;

class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  ///final List<Exercise> exercise;

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  BodyPart? selectedBodyPart;

  void _onBodyPartSelected(BuildContext context, BodyPart bodyPart) {
    print('Selected body part: ${bodyPart.name}');

    // Możesz tutaj np. nawigować do innego ekranu
    // Navigator.of(context).push(...);
  }
  
  void _bodyPartSelected(BodyPart bodyPart) {
    setState(() {
      selectedBodyPart = bodyPart; // Zapisz wybraną część ciała
    });
    Navigator.of(context).pop(); // Zamknij BottomSheet
  }

  void _openSelectBodyPart() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => BodyPartSelected(
        onBodyPartSelected: _bodyPartSelected
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(
                        (0.2 * 255).toInt(),
                      ), // Slightly darker than the background
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _openSelectBodyPart,
                    child: const Text('Body Part'),
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(
                        (0.2 * 255).toInt(),
                      ), // Set background color
                      textStyle: Theme.of(
                        context,
                      ).textTheme.titleSmall!.copyWith(
                        color:
                            Theme.of(context)
                                .colorScheme
                                .onPrimary, // Use onPrimary for white text if primary background is used
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Target'),
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
                      textStyle: Theme.of(
                        context,
                      ).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      //  SizedBox(height: 10,)
    );
  }
}
