import 'package:flutter/material.dart';
import 'package:work_plan_front/model/training_session.dart';
import 'package:work_plan_front/screens/home_dashboard/workout_info/exercise_sets_table.dart';
import 'package:work_plan_front/utils/image_untils.dart';
class ExerciseListItem extends StatefulWidget {
  final CompletedExercise exercise;
  final String? exerciseName;
  final String? exerciseImageUrl;

  const ExerciseListItem({
    Key? key,
    required this.exercise,
    this.exerciseName,
    this.exerciseImageUrl,
  }) : super(key: key);

  @override
  State<ExerciseListItem> createState() => _ExerciseListItemState();
}

class _ExerciseListItemState extends State<ExerciseListItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withAlpha((0.9 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(50),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // ✅ GŁÓWNY WIERSZ Z ĆWICZENIEM (KLIKALNY)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ IKONA/OBRAZEK ĆWICZENIA
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                      color: Theme.of(context).colorScheme.primary.withAlpha(50),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withAlpha(30),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _buildExerciseImage(context),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ NAZWA ĆWICZENIA
                        Text(
                          widget.exerciseName ?? "Unknown Exercise",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        // ✅ LICZBA SETÓW I DODATKOWE INFO
                        Row(
                          children: [
                            Text(
                              "Sets: ${widget.exercise.sets.length}",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              "Total: ${_getTotalWeight()}kg",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                              ),
                            ),
                             SizedBox(width: 16),
                             Text(
                              "Reps : ${widget.exercise.sets.fold(0, (sum, set) => sum + set.actualReps)}",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                              ),
                             )
                          ],
                        ),
                      ],
                    ),
                  ),
                  // ✅ IKONA ROZWIJANIA
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                  ),
                ],
              ),
            ),
          ),
          
          // ✅ TABELA SETÓW (ROZWIJANA)
          ExerciseSetsTable(
            exercise: widget.exercise,
            exerciseName: widget.exerciseName,
            isExpanded: _isExpanded,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseImage(BuildContext context) {
    // ✅ JEŚLI BRAK OBRAZKA - POKAŻ IKONĘ
    if (widget.exerciseImageUrl == null || widget.exerciseImageUrl!.isEmpty) {
      return Icon(
        Icons.fitness_center,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      );
    }
    
    // ✅ JEŚLI JEST OBRAZEK - UŻYJ ImageUtils
    return ImageUtils.buildImage(
      imageUrl: widget.exerciseImageUrl!,
      context: context,
      width: 40,
      height: 40,
      fit: BoxFit.cover,
      placeholder: Icon(
        Icons.fitness_center,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  // ✅ OBLICZ CAŁKOWITY CIĘŻAR
  double _getTotalWeight() {
    return widget.exercise.sets
        .map((set) => set.actualKg)
        .fold(0.0, (sum, weight) => sum + weight);
  }
}