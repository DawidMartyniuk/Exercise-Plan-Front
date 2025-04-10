import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Tabs extends ConsumerStatefulWidget{
  const Tabs({Key? key}) : super(key: key);

  @override
  ConsumerState<Tabs> createState() => _TabsState();
}
class _TabsState extends ConsumerState<Tabs>{

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tabs'),
        ),
        body: const Center(
          child: Text('Tabs'),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Home'
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.fitness_center),
              label: 'Exercises',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'Plan',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
            ),
            ]
          ),
      );
  }

}