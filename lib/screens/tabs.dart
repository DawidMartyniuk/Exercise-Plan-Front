import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/screens/exercises.dart';
import 'package:work_plan_front/screens/start.dart';
import 'package:work_plan_front/screens/profil.dart';
import 'package:work_plan_front/screens/plan.dart';

class TabsScreen extends ConsumerStatefulWidget{
  final int selectedPageIndex;

  const TabsScreen({
    super.key,
    this.selectedPageIndex = 0 ,
    });

  @override
  ConsumerState<TabsScreen> createState() => _TabsScreenState();
}
class _TabsScreenState extends ConsumerState<TabsScreen>{
  int _selectedPageIndex = 0;

  final List<Widget> _pages = [
    Startscreen(),
    ExercisesScreen(),
    PlanScreen(),
    ProfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedPageIndex = widget.selectedPageIndex;
  }

  void _selectPage(int indexPage){
    setState(() {
    _selectedPageIndex = indexPage;
  });
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        body: _pages[_selectedPageIndex],
        bottomNavigationBar: BottomNavigationBar(
          selectedLabelStyle: TextStyle(),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer.withAlpha((0.01 *255 ).toInt()),
        selectedItemColor: Theme.of(context).colorScheme.onSurface, 
        unselectedItemColor: Theme.of(context).colorScheme.secondary.withAlpha((0.95 * 255).toInt()), 
       
        currentIndex: _selectedPageIndex,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        
          onTap: _selectPage, 
          items: [
            BottomNavigationBarItem(
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