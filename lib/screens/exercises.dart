import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/provider/authProvider.dart';
import 'package:work_plan_front/provider/exerciseProvider.dart';
import 'package:work_plan_front/theme/app_constants.dart';
import 'package:work_plan_front/widget/exercise/body_part_grid_item.dart';
import 'package:work_plan_front/widget/exercise/exercise_limit_upload.dart';
import 'package:work_plan_front/widget/exercise/exercises_list.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  final bool isSelectionMode; 
  final String? title; 
  final Function(List<Exercise>)? onMultipleExercisesSelected; // ✅ CALLBACK DLA WYBORU ĆWICZENIA

  const ExercisesScreen({
    super.key,
    this.isSelectionMode = false,
    this.title,
    this.onMultipleExercisesSelected,
  });

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  BodyPart? selectedBodyPart;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(exerciseProvider.notifier).fetchExercises(forceRefresh: true);
    });
  }

  List<Exercise> _filteredExercises(List<Exercise> exercises) {
    return exercises.where((exercises) {
      final matchesBodyPart =
          selectedBodyPart == null ||
          exercises.bodyPart == selectedBodyPart!.name;
      final matchesSearch =
          _searchQuery.isEmpty ||
          exercises.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch && matchesBodyPart;
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
  void _showExrciseLimitUpload() async{
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => ExerciseLimitUpload(
        exerciseStart: AppConstants().exerciseStart,
        exerciseLimit: AppConstants().exerciseBatchSize,
      ),
    );
    if (result != null && result['update'] == true) {
      // Zaktualizuj wartości w AppConstants
    print("✅ Zakres został zaktualizowany: ${result['start']} - ${result['limit']}");
    ref.read(exerciseProvider.notifier).fetchExercises(
        forceRefresh: true,
      );
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Exercises reloaded with new range: ${result['start']} - ${result['limit']}"),
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
              Icon(
                Icons.login,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                'Please log in',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Log in to see your training calendar',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final exercises = ref.watch(exerciseProvider);

   // print('Exercises in build: $exercises');

    return Scaffold(
      appBar: AppBar(
      
        title: Text(widget.isSelectionMode 
            ? (widget.title ?? 'Select Exercise') 
            : 'Exercises'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100), 
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        actions: [
          TextButton(
            onPressed: () {
              _showExrciseLimitUpload();  
            },
             child: Text("current number of exercises : ${AppConstants().exerciseBatchSize}",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
             ),
          )
          // ✅ DODAJ PRZYCISK REFRESH
          // IconButton(
          //   icon: Icon(Icons.refresh),
          //   onPressed: () {
          //     ref.read(exerciseProvider.notifier).fetchExercises(forceRefresh: true);
          //   },
          // ),
        ],
      ),
      body: exercises.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading exercises...'),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Error: $err'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(exerciseProvider.notifier).fetchExercises(forceRefresh: true);
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
        data: (exerciseList) => exerciseList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No exercises available.'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(exerciseProvider.notifier).fetchExercises(forceRefresh: true);
                      },
                      child: Text('Load Exercises'),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // ✅ POKAŻ INSTRUKCJĘ W TRYBIE WYBORU
                    if (widget.isSelectionMode) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withAlpha(50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tap an exercise to add it to your plan',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.primary
                                  .withAlpha((0.2 * 255).toInt()),
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
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha((0.2 * 255).toInt()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Target',
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha((0.2 * 255).toInt()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ExerciseList(
                        exercise: _filteredExercises(exerciseList),
                        isSelectionMode: widget.isSelectionMode, // ✅ PRZEKAŻ TRYB
                        onExerciseSelected: (exercise) {
                          // ✅ CALLBACK ZOSTANIE WYWOŁANY AUTOMATYCZNIE
                          print('Selected exercise: ${exercise.name}');
                        },
                        onMultipleExercisesSelected: widget.onMultipleExercisesSelected  != null
                          ? (exercises) {
                            widget.onMultipleExercisesSelected!(exercises);
                            print('Selected ${exercises.length} exercises');
                          }
                          : null 
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
