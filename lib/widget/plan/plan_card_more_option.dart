import 'package:flutter/material.dart';
import "package:work_plan_front/widget/plan/plan_list/plan_selected_list.dart";
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/screens/plan.dart';

class PlanCardMoreOption extends StatelessWidget{
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PlanCardMoreOption({
    super.key,
    required this.onEdit,
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
          onEdit();
        },
        child: Icon(
          Icons.edit,
          color: Colors.blue,
        ),
      ),
      MenuItemButton(
        onPressed: () {
          onDelete();
        },
        child: Icon(
          Icons.delete,
          color: Colors.red,
        ),
      ),
    ],
    );
  }
}
