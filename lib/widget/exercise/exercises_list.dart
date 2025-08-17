import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/screens/exercise_info.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:work_plan_front/utils/image_untils.dart';

class ExerciseList extends StatefulWidget {
  final List<Exercise> exercise;
  final bool isSelectionMode;
  final Function(Exercise)? onExerciseSelected;
  final Function(List<Exercise>)? onMultipleExercisesSelected; // ✅ NOWY CALLBACK

  const ExerciseList({
    super.key, 
    required this.exercise,
    this.isSelectionMode = false,
    this.onExerciseSelected,
    this.onMultipleExercisesSelected, // ✅ DODAJ PARAMETR
  });

  @override
  State<ExerciseList> createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  // ✅ LISTA WYBRANYCH ĆWICZEŃ
  Set<String> selectedExerciseIds = <String>{};

  // ✅ SPRAWDŹ CZY ĆWICZENIE JEST WYBRANE
  bool _isExerciseSelected(Exercise exercise) {
    return selectedExerciseIds.contains(exercise.id);
  }

  // ✅ PRZEŁĄCZ WYBÓR ĆWICZENIA
  void _toggleExerciseSelection(Exercise exercise) {
    setState(() {
      if (selectedExerciseIds.contains(exercise.id)) {
        selectedExerciseIds.remove(exercise.id);
      } else {
        selectedExerciseIds.add(exercise.id);
      }
    });
  }

  // ✅ DODAJ WYBRANE ĆWICZENIA
  void _addSelectedExercises() {
    final selectedExercises = widget.exercise
        .where((exercise) => selectedExerciseIds.contains(exercise.id))
        .toList();
    
    if (selectedExercises.isNotEmpty && widget.onMultipleExercisesSelected != null) {
      widget.onMultipleExercisesSelected!(selectedExercises);
      Navigator.of(context).pop(selectedExercises); // ✅ WRÓĆ Z LISTĄ
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ PRZYCISK DODAWANIA - POKAŻ TYLKO GDY JEST TRYB WYBORU I COKOLWIEK WYBRANE
        if (widget.isSelectionMode && selectedExerciseIds.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _addSelectedExercises,
              icon: const Icon(Icons.add),
              label: Text(
                'Dodaj wybrane ćwiczenia (${selectedExerciseIds.length})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

        // ✅ LISTA ĆWICZEŃ
        Expanded(
          child: ListView.builder(
            itemCount: widget.exercise.length,
            itemBuilder: (context, index) {
              final currentExercise = widget.exercise[index];
              final isSelected = _isExerciseSelected(currentExercise);
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                // ✅ ZMIEŃ KOLOR KARTY GDY WYBRANA
                color: isSelected && widget.isSelectionMode
                    ? Colors.green.withOpacity(0.1)
                    : null,
                child: InkWell(
                  onTap: () {
                    if (widget.isSelectionMode) {
                      // ✅ TRYB WYBORU - PRZEŁĄCZ WYBÓR
                      _toggleExerciseSelection(currentExercise);
                      
                      // ✅ WYWOŁAJ STARY CALLBACK DLA KOMPATYBILNOŚCI
                      if (widget.onExerciseSelected != null) {
                        widget.onExerciseSelected!(currentExercise);
                      }
                    } else {
                      // TRYB PRZEGLĄDANIA - POKAŻ SZCZEGÓŁY
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ExerciseInfoScreen(exercise: currentExercise),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ImageUtils.buildImage(
                              imageUrl: currentExercise.gifUrl,
                              context: context,
                              width: 60,
                              height: 60,
                              placeholder: ImageUtils.buildSmallPlaceholder(context, size: 60),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentExercise.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentExercise.bodyParts.join(', '),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // ✅ IKONA - ZMIEŃ KOLOR I TYP W ZALEŻNOŚCI OD STANU
                        Icon(
                          widget.isSelectionMode 
                              ? (isSelected ? Icons.check_circle : Icons.add_circle_outline)
                              : Icons.chevron_right,
                          color: widget.isSelectionMode 
                              ? (isSelected ? Colors.green : Theme.of(context).colorScheme.primary)
                              : Theme.of(context).colorScheme.onSurface.withAlpha(100),
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
