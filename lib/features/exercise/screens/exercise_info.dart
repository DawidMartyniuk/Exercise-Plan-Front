import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/provider/favorite_exercise_notifer.dart';
import 'package:work_plan_front/features/exercise/exercise_info/tabs/info_tab.dart';
import 'package:work_plan_front/features/exercise/exercise_info/tabs/instruction_tab.dart';
import 'package:work_plan_front/shared/utils/image_untils.dart'; // ✅ DODAJ

class ExerciseInfoScreen extends ConsumerStatefulWidget {
  const ExerciseInfoScreen({super.key, required this.exercise});

  final Exercise exercise;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ExerciseInfoScreenState();
  }
}

class _ExerciseInfoScreenState extends ConsumerState<ExerciseInfoScreen> 
with SingleTickerProviderStateMixin {
   TabController? _tabController;
     final bool _isFavorite = false;
  

  @override
  void initState() {
    super.initState();
      _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
     _tabController?.dispose();
    super.dispose();
  }

  void _onFavoritePressed() {
    if (!mounted) return; 
    ref.read(favoriteExerciseProvider.notifier).toggleFavorite(widget.exercise.exerciseId);
  }




  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final favoriteIds = ref.watch(favoriteExerciseProvider);
    final isFavorite = favoriteIds.contains(exercise.exerciseId);
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        actions: [
          IconButton(
          icon: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color:
                  isFavorite
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          onPressed: _onFavoritePressed,
          tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
        ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.info_outline),
              text: 'Info'
              ),
            Tab(
              icon: Icon(Icons.list_alt),
              text: 'Instructions',
            ),
          ],
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withAlpha(100),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          InfoTab(exercise: exercise),
          InstructionsTab(exercise: exercise),
        ]
    
    ),
    );
  }
}
