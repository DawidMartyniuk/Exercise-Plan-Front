import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';

class ListItemExerciseCreate extends StatelessWidget {
  final VoidCallback openModelaToSelectedParet;
  final String rowTitle;
  final String selectedItem;

  const ListItemExerciseCreate({
    Key? key,
    required this.openModelaToSelectedParet,
    required this.rowTitle,
    required this.selectedItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Row(
        children: [
          Text(
            rowTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: openModelaToSelectedParet,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      selectedItem,
                      style: TextStyle(
                        fontSize: 14,
                        color: (selectedItem.startsWith("No ") || selectedItem.isEmpty)
                        ? const Color.fromARGB(255, 69, 155, 226)
                        : Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: null,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_right,
                    color: Theme.of(context).colorScheme.primary.withAlpha(180),
                    size: 35,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
