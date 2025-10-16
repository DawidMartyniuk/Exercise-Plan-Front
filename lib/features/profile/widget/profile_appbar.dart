import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:work_plan_front/features/profile/screens/profile_user_edit.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const ProfileAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // ❌ USUŃ: leadingWidth: 150, - to powodowało asymetrię
      centerTitle: true, // ✅ DODAJ: wycentrowanie tytułu

      // ❌ ZAKOMENTOWANA SEKCJA EDIT PROFILE
      // leading: OpenContainer<bool>(
      //   transitionType: ContainerTransitionType.fade,
      //   transitionDuration: Duration(milliseconds: 600),
      //   openColor: Theme.of(context).colorScheme.surface,
      //   closedColor: Colors.transparent,
      //   openShape: RoundedRectangleBorder(),
      //   closedShape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(20),
      //   ),
      //   openElevation: 0,
      //   closedElevation: 0,
      //
      //   // ✅ PRZYCISK ZAMKNIĘTY (Edit Profile)
      //   closedBuilder: (context, action) => Container(
      //     margin: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      //     decoration: BoxDecoration(
      //       color: Theme.of(context).colorScheme.secondary,
      //       borderRadius: BorderRadius.circular(20),
      //     ),
      //     child:
      //     TextButton.icon(
      //       onPressed: action,
      //       style: TextButton.styleFrom(
      //         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      //         minimumSize: Size.zero,
      //         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(20),
      //         ),
      //       ),
      //       icon: Icon(
      //         Icons.edit,
      //         size: 16,
      //         color: Theme.of(context).colorScheme.onSecondary,
      //       ),
      //       label: Text(
      //         'Edit Profile',
      //         style: TextStyle(
      //           color: Theme.of(context).colorScheme.onSecondary,
      //           fontSize: 14,
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //     ),
      //   ),
      //
      //   // ✅ EKRAN OTWARTY (ProfileUserEdit)
      //   openBuilder: (context, action) => ProfileUserEdit(),
      // ),
      actions: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.secondary.withAlpha(100),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.onSecondary,
              size: 22,
            ),
            onPressed: () {},
            style: IconButton.styleFrom(
              padding: EdgeInsets.all(12),
              minimumSize: Size(48, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],

      title: Text(title), // ✅ USUŃ Center() - centerTitle: true wystarczy
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 2,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
