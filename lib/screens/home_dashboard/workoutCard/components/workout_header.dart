import 'package:flutter/material.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard/components/avatar_widget.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard/components/card_more_options.dart';
import 'package:work_plan_front/utils/toast_untils.dart';

class WorkoutHeader extends StatelessWidget {
  final String userName;
  final DateTime date;
  final bool showMoreIcon;
  final VoidCallback? onInfo;
  final VoidCallback? onDelete;
 // final Widget buildAvatarImage;

  const WorkoutHeader({
    super.key,
    required this.userName,
    required this.date,
    this.showMoreIcon = true,
    this.onInfo,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
            color: Theme.of(context).colorScheme.primary.withAlpha(50),
          ),
          child: AvatarWidget(
            size: 40,
            borderWidth: 2,
            iconSize: 20,
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                _getDaysAgo(date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        if (showMoreIcon)
          CardMoreOption(
            onInfo: onInfo ?? () {

            },
            onDelete: onDelete ?? () {
               print("No delete callback provided");
               ToastUtils.showDeleteSuccess(
                 context,
                 itemName: "Workout", 
               );
            },
          ),
      ],
    );
  }

  String _getDaysAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    if (difference == 0) return "Today";
    if (difference == 1) return "Yesterday";
    return "$difference days ago";
  }
}