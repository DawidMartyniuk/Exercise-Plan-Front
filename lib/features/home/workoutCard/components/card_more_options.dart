import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardMoreOption extends ConsumerWidget {
  final VoidCallback? onInfo;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final String? itemName; // Nazwa elementu do wyświetlenia w dialogu

  const CardMoreOption({
    this.onEdit,
    super.key,
    this.onInfo,
    this.onDelete,

    this.itemName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onSelected: (value) => _handleMenuSelection(value, context, ref),
      itemBuilder: (BuildContext context) => [
        // ✅ INFO OPTION
        if (onInfo != null)
          PopupMenuItem(
            value: 'info',
            child: _buildMenuItem(
              icon: Icons.info,
              title: 'Info',
              context: context,
              isDestructive: false,
            ),
          ),
        
        // ✅ DIVIDER JEŚLI INFO DOSTĘPNE
        if (onInfo != null && onDelete != null) const PopupMenuDivider(),
        
        // ✅ DELETE OPTION
        if (onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: _buildMenuItem(
              icon: Icons.delete,
              title: 'Delete',
              context: context,
              isDestructive: true,
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
  }) {
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

  void _handleMenuSelection(String value, BuildContext context, WidgetRef ref) {
    switch (value) {
      case 'info':
        if (onInfo != null) onInfo!();
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
      default:
        print('Unknown action: $value');
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Workout'),
          content: Text(
            'Are you sure you want to delete ${itemName ?? "this workout"}? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onDelete != null) onDelete!();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}