import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileUserPanel extends ConsumerWidget {
  final Widget buildAvatarImage;
  final String Function() getProfileName;
  final String Function() getProfileDescription;
  final int Function() getTotalWorkouts;

  const ProfileUserPanel({
    super.key,
    required this.buildAvatarImage,
    required this.getProfileName,
    required this.getProfileDescription,
    required this.getTotalWorkouts,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
                height: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onSecondary,
                          width: 2,
                        ),
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(50),
                      ),
                      child: 
                      ClipOval(child: buildAvatarImage),
                    ),
        
                    SizedBox(width: 16), // ✅ ODSTĘP MIĘDZY AVATAREM A TEKSTEM
                    // ✅ TEKST
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            getProfileName(),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 8), // tutaj będzie mały opis takie Bio
                          Text(
                            getProfileDescription(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlpha(180),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Workouts",
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(180),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          getTotalWorkouts().toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
  }
}
