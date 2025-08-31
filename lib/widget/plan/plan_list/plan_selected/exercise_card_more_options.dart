import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';

class ExerciseCardMoreOptions extends ConsumerWidget {
  //final ExerciseTable exercise;
  final VoidCallback? onDeleteCard;
  final VoidCallback? onReplace;
  final VoidCallback? onDuplicateCard;

  ExerciseCardMoreOptions({
   // required this.exercise,
    this.onDeleteCard,
    this.onReplace,
    this.onDuplicateCard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String >(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onSelected: (value) => _handleMenuSelection(value, context),
      itemBuilder: (BuildContext context) => [
          PopupMenuItem(
            value: 'delete',
            child: _buildMenuItem(
              icon: Icons.delete,
              title: 'Delete',
              context: context,
              isDestructive: true,
              ),
            ),
            PopupMenuItem(
            value: 'replace',
            child: _buildMenuItem(
              icon: Icons.swap_horiz,
              title: 'Replace',
              context: context,
              isDestructive: false,
              ),
            ),
            PopupMenuItem(
            value: 'duplicate',
            child: _buildMenuItem(
              icon: Icons.content_copy,
              title: 'Duplicate',
              context: context,
              isDestructive: false,
              ),
            ),
      ],
      );
  }

  Widget _buildMenuItem({
     required IconData icon,
    required String title,
    required BuildContext context,
    bool isDestructive = false,
  }){
    return Row(
      children: [
        Icon(
          icon,
          color: isDestructive
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurface,
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isDestructive
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'delete':

        _showDeleteExerciseCard(context);
        break;
      case 'replace':
        if (onReplace != null) onReplace!();
        break;
      case 'duplicate':
        if (onDuplicateCard != null) onDuplicateCard!();
        break;
      default:
        print('Unknown action: $value');
    }
  }
  void _showDeleteExerciseCard(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Exercise Card'),
          content: Text('Are you sure you want to delete this exercise card?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (onDeleteCard != null) onDeleteCard!();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}