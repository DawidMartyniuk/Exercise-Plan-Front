import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/provider/planGroupsNotifier.dart';

Widget buildAddGroupDialog(BuildContext context, TextEditingController controller, WidgetRef ref) {
  return AlertDialog(
            title: Center(child: Text('Add New Group')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Group name',
                    border: UnderlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                SizedBox(height: 16),
              ],
            ),
            actions: [
              TextButton(
                
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',style : TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
              TextButton(
                
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    ref
                        .read(planGroupsProvider.notifier)
                        .addGroup(controller.text.trim());
                    Navigator.pop(context);
                  }
                },
                child: Text('Add',style : TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
            ],
          );
}