import 'package:flutter/material.dart';

class RecentWorkoutsSection extends StatefulWidget {
  const RecentWorkoutsSection({
    super.key
    });


  @override
  _RecentWorkoutsSectionState createState() => _RecentWorkoutsSectionState();
}

class _RecentWorkoutsSectionState extends State<RecentWorkoutsSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Card(
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                color:  Theme.of(context).colorScheme.primary.withAlpha(50),
              ),
              child: Icon( // potem ikona osby zalogowanej
                Icons.person,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          ],
        ),
      ),
    );
  }
}