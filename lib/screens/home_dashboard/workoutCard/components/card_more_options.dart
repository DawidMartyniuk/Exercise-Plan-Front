import 'package:flutter/material.dart';

class CardMoreOption extends StatelessWidget{
  final VoidCallback onInfo;
  final VoidCallback onDelete;

  const CardMoreOption({
    super.key,
    required this.onInfo,
    required this.onDelete,
  });

  Widget build(BuildContext context) {

    return MenuAnchor(
      builder: (context, controller, child) =>
    IconButton(onPressed: () {
      if (controller.isOpen) {
        controller.close();
      } else {
        controller.open();
      }
    },

    icon: Icon(
      Icons.more_vert,
      color: Theme.of(context).colorScheme.onSurface,
    ),
    ),
   
    menuChildren: [
      MenuItemButton(
        onPressed: () {
          onInfo();
        },
        child: Icon(
          Icons.info,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      MenuItemButton(
        onPressed: () {
          onDelete();
        },
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ],
    );
  }
}
