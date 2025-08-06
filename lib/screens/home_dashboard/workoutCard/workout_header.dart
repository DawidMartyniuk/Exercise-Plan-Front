import 'package:flutter/material.dart';

class WorkoutHeader extends StatelessWidget {
  final String userName;
  final DateTime date;
  final bool showMoreIcon;

  const WorkoutHeader({
    super.key,
    required this.userName,
    required this.date,
    this.showMoreIcon = true,
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
          child: Icon(
            Icons.person,
            size: 20,
            color: Theme.of(context).colorScheme.onSecondary,
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
          Icon(
            Icons.more_horiz,
            size: 24,
            color: Theme.of(context).colorScheme.onSurface,
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