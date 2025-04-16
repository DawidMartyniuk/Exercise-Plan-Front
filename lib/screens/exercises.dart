import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/provider/exerciseProvider.dart';
import 'package:work_plan_front/widget/body_part_grid_item.dart';
import 'package:work_plan_front/widget/exercise_list.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  BodyPart? selectedBodyPart;
  String _searchQuery = '';


  @override
  void initState() {
  super.initState();
  ref.read(exerciseProvider.notifier).fetchExercises(); // Pobierz dane przy załadowaniu ekranu
}

  List<Exercise> _filteredExercises(List<Exercise> exercises) {
      return exercises.where((exercises) {
          final matchesBodyPart = selectedBodyPart == null || exercises.bodyPart == selectedBodyPart!.name;
          final matchesSearch = _searchQuery.isEmpty || exercises.name.toLowerCase().contains(_searchQuery.toLowerCase());
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
// Zapisz wybraną część ciała
    });
    Navigator.of(context).pop(); // Zamknij BottomSheet
  }

  void _openSelectBodyPart() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => BodyPartSelected(onBodyPartSelected: _bodyPartSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exerciseProvider); // Automatyczne pobieranie danych jako AsyncValue

     print('Exercises in build: $exercises');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
      ),
      body: exercises == null
          ? const Center(child: CircularProgressIndicator()) // Ładowanie
          : exercises.isEmpty
              ? const Center(child: Text('No exercises available.')) // Brak danych
              : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.primary.withAlpha(
                                (0.2 * 255).toInt(),
                              ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Search',
                          prefixIcon: const Icon(Icons.search),
                        ),
                        onChanged: (value){
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
                          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(
                                (0.2 * 255).toInt(),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Target'),
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(
                                (0.2 * 255).toInt(),
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ExerciseList(exercise: _filteredExercises(exercises)),
                          ),
                    ],
                  ),
                ),
    );
  
}
  }
