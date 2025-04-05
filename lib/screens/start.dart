import 'package:flutter/material.dart';
import 'package:work_plan_front/screens/login.dart';

class Startscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Screen'),
        actions: [
          IconButton(
            padding: EdgeInsets.symmetric(horizontal: 30),
            onPressed: () {
              Navigator.of(context,).push(
                MaterialPageRoute(builder: (ctx) => LoginScreen(),
               ),
              );
            },
            icon: Icon(Icons.login),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome to the Start Screen!',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
