import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/provider/auth_provider.dart';
import 'package:work_plan_front/provider/exercise_provider.dart';
import 'package:work_plan_front/provider/favorite_exercise_notifer.dart';
import 'package:work_plan_front/services/userExerciseService.dart';
import 'package:work_plan_front/theme/app_constants.dart';
import 'package:work_plan_front/utils/keyboard_dismisser.dart';
import 'package:work_plan_front/utils/token_storage.dart' as TokenStorage;
import 'package:work_plan_front/widget/exercise/widget/body_part_grid_item.dart';
import 'package:work_plan_front/widget/exercise/exercise_create.dart';
import 'package:work_plan_front/widget/exercise/exercise_limit_upload.dart';
import 'package:work_plan_front/widget/exercise/exercises_list.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ExercisesScreen extends ConsumerStatefulWidget {
  //TODO :usuwanie oraz edycja ćwiczeń
  final bool isSelectionMode;
  final String? title;
  final Function(List<Exercise>)? onMultipleExercisesSelected;
  final Function(Exercise)? onSingleExerciseSelected;

  const ExercisesScreen({
    super.key,
    this.isSelectionMode = false,
    this.title,
    this.onMultipleExercisesSelected,
    this.onSingleExerciseSelected,
  });

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  BodyPart? selectedBodyPart;
  String _searchQuery = '';
  bool _isFavorite = false;
  bool _showOnlyFavorites = false;

@override
void initState() {
  super.initState();
 loadData();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final authResponse = ref.read(authProviderLogin);
    if (authResponse != null) {
      final userId = await TokenStorage.getUserId();
      print("🔄 [ExercisesScreen] fetchAndSaveUserExercises dla userId=$userId");
      await userExerciseService().fetchAndSaveUserExercises(userId!);
      await ref.read(exerciseProvider.notifier).fetchExercises(forceRefresh: true);
    }
  });
}


  @override
  void dispose() {
    print("🔄 ExercisesScreen dispose called");
    super.dispose();
  }

  List<Exercise> _filteredExercises(List<Exercise> exercises) {
    final favoritesIds = ref.watch(favoriteExerciseProvider);
    return exercises.where((exercise) {
      final matchesBodyPart =
          selectedBodyPart == null ||
          exercise.bodyPart == selectedBodyPart!.name;

      final matchesSearch =
          _searchQuery.isEmpty ||
          exercise.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFavorites =
          !_showOnlyFavorites || favoritesIds.contains(exercise.exerciseId);
      return matchesSearch && matchesBodyPart && matchesFavorites;
    }).toList();
  }

  void _bodyPartSelected(BodyPart? bodyPart) {
    setState(() {
      if (selectedBodyPart == bodyPart) {
        selectedBodyPart = null;
      } else {
        selectedBodyPart = bodyPart;
      }
    });
    Navigator.of(context).pop();
  }

  void _openSelectBodyPart() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => BodyPartSelected(onBodyPartSelected: _bodyPartSelected),
    );
  }

  void _onFavoritePressed() {
    if (!mounted) return;
    setState(() {
      _showOnlyFavorites = !_showOnlyFavorites;
    });
    print("Show only favorites: $_showOnlyFavorites");
  }
  Future<void> loadData() async {
  final res = await http.get(Uri.parse('http://127.0.0.1:8000/api/test-image'));
  print("RES: ${res.body}");
}

  void _showExrciseLimitUpload() async {
     
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder:
          (ctx) => ExerciseLimitUpload(
            exerciseStart: AppConstants().exerciseStart,
            exerciseLimit: AppConstants().exerciseBatchSize,
          ),
    );
    if (result != null && result['update'] == true) {
      print(
        "✅ Zakres został zaktualizowany: ${result['start']} - ${result['limit']}",
      );
      ref.read(exerciseProvider.notifier).fetchExercises(forceRefresh: true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Exercises reloaded with new range: ${result['start']} - ${result['limit']}",
          ),
          backgroundColor: Colors.blue,
        ),
      );
    } else {
      print("❌ Nie zaktualizowano zakresu ćwiczeń");
    }
  }

  @override
  Widget build(BuildContext context) {
    

    final authResponse = ref.watch(authProviderLogin);
    if (authResponse == null) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withAlpha(127),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Please log in',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                'Log in to see your training calendar',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    final exercises = ref.watch(exerciseProvider);
    final favoritesIds = ref.watch(favoriteExerciseProvider);

    return KeyboardDismisser(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              child: Icon(
                _showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                color:
                    _showOnlyFavorites
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            onPressed: _onFavoritePressed,
            tooltip:
                _showOnlyFavorites ? 'Remove from favorites' : 'Add to favorites',
          ),
          title: Text(
            widget.isSelectionMode
                ? (widget.title ?? 'Select Exercise')
                : (_showOnlyFavorites ? 'Favorite Exercises' : 'Exercises'),
          ),
          elevation: 2,
          // backgroundColor: Theme.of(
          //   context,
          // ).colorScheme.surfaceContainerHighest.withAlpha(100),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                ),
                onPressed: ()async {
                 await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ExerciseCreate(),
                    ),
                  );
                  ref.read(exerciseProvider.notifier).fetchExercises(forceRefresh: true);
                },
                child: Text(
                  "Add Exercise",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
         
            // TextButton(
            //   onPressed: () {
            //     _showExrciseLimitUpload();
            //   },
            //   child: Text(
            //     "exercises : ${AppConstants().exerciseBatchSize}",
            //     style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            //       color: Theme.of(context).colorScheme.onSurface,
            //     ),
            //   ),
            // ),
          ],
        ),
        body: exercises.when(
          loading:
              () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading exercises...'),
                  ],
                ),
              ),
          error:
              (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Error: $err'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(exerciseProvider.notifier)
                            .fetchExercises(forceRefresh: true);
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
          data: (exerciseList) {
            final filteredExercises = _filteredExercises(exerciseList);
      
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  if (widget.isSelectionMode) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                     
                    ),
                  ],
                  if (_showOnlyFavorites) ...[
                   
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Search',
                            prefixIcon: const Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _openSelectBodyPart,
                          child: Text(
                            selectedBodyPart == null
                                ? 'Body part'
                                : '${selectedBodyPart?.displayNameBodyPart()}',
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Target',
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ExerciseList(
                      exercise: filteredExercises,
                      isSelectionMode: widget.isSelectionMode,
                      onExerciseSelected:
                          widget.onSingleExerciseSelected != null
                              ? (exercise) {
                                print(
                                  'Single exercise selected: ${exercise.name}',
                                );
                                widget.onSingleExerciseSelected!(exercise);
                              }
                              : null,
                      onMultipleExercisesSelected:
                          widget.onMultipleExercisesSelected != null
                              ? (exercises) {
                                widget.onMultipleExercisesSelected!(exercises);
                                print('Selected ${exercises.length} exercises');
                              }
                              : null,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
