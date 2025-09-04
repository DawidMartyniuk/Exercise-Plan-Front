import 'package:flutter/material.dart';

class PlanSelectedDetails extends StatelessWidget {
  const PlanSelectedDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Strona główna'),
            onTap: () {
              // Navigator.pushNamed(context, '/');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Ustawienia'),
            onTap: () {
              // Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('in develop details workout settings , info series on body parts'),
            onTap: () {
              // Navigator.pushNamed(context, '/info');
            },
          ),
        ],
      ),
    );
  }
}