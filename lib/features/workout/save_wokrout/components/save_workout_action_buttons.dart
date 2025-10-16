import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/shared/utils/workout_utils.dart';

class SaveWorkoutActionButtons extends ConsumerWidget {
  final VoidCallback onWorkoutList;

  const SaveWorkoutActionButtons({
    super.key,
    required this.onWorkoutList,
    });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  onWorkoutList();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).colorScheme.primary.withAlpha(150),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Workout List",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_sharp,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async{
                 
                  await endWorkoutGlobal(
                    context: context,
                    ref: ref,
                    showConfirmationDialog: true,
                  );
                  
                  // Po zakończeniu treningu wróć do głównego ekranu
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.red.withAlpha(150), // ✅ ZMIEŃ NA CZERWONY
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "End Workout",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.white, 
                        ),
                      ),
                      Icon(
                        Icons.delete, // ✅ ZMIEŃ IKONĘ NA DELETE
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
