import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/features/workout/plan_selected/exercise_card_more_options.dart';
import '../helpers/plan_helpers.dart';
import '../components/exercise_ui/exercise_image.dart';
import 'components/notes_field.dart';

class PlanSelectedCard extends ConsumerWidget with PlanHelpers {
  final String exerciseId;
  final String exerciseName;
  final Widget headerCellTextStep;
  final Widget headerCellTextKg;
  final Widget headerCellTextReps;
  final List<TableRow> exerciseRows;
  final String notes;
  final Function(String)? onNotesChanged;
  final VoidCallback? onTap; 
  final VoidCallback deleteExerciseCard;
  final bool isReadOnly;
  final Function(String)? onAddSet;
  final Function(String)? onRemoveSet;
  final int setsCount;


  final VoidCallback? onReplaceExercise;

  const PlanSelectedCard({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.headerCellTextStep,
    required this.headerCellTextKg,
    required this.headerCellTextReps,
    required this.exerciseRows,
    required this.notes,
    this.onNotesChanged,
    required this.deleteExerciseCard,
    this.onTap,
    this.isReadOnly = false,
    
    this.onAddSet,
    this.onRemoveSet,
    this.setsCount = 1,
    this.onReplaceExercise, //  DODAJ DO KONSTRUKTORA
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCheckboxColumn = exerciseRows.isNotEmpty && exerciseRows.first.children.length > 3;

    return Card(
      color: Theme.of(context).colorScheme.surface.withAlpha((0.9 * 255).toInt()),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  HEADER Z OBRAZKIEM I NAZWĄ
            Row(
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: ExerciseImage(
                    exerciseId: exerciseId,
                    size: 50,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    exerciseName,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if(!isReadOnly)
                ExerciseCardMoreOptions(
                  onDeleteCard: () {
                    deleteExerciseCard();
                    
                  },
                  onInfoExercise: onTap,
                  onReplace: onReplaceExercise, //  PRZEKAŻ CALLBACK
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            if (onNotesChanged != null)
              NotesField(
                notes: notes,
                onChanged: onNotesChanged!,
              )
            else if (notes.isNotEmpty) ...[
              Text(
                'Notes: $notes',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            //  TABELA ĆWICZEŃ
            Table(
              border: TableBorder.all(
                color: Theme.of(context).colorScheme.outline.withAlpha(50),
                width: 1,
              ),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(20),
                  ),
                  children: [
                    headerCellTextStep,
                    headerCellTextKg,
                    headerCellTextReps,
                     if (hasCheckboxColumn)
                     Container(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Done',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                ...exerciseRows,
              ],
            ),
            
            //  DODAJ PRZYCISKI NA DOLE KARTY
            if (!isReadOnly && onAddSet != null && onRemoveSet != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: setsCount > 1 
                      ? MainAxisAlignment.spaceBetween 
                      : MainAxisAlignment.center,
                  
                  children: [
                    // DODAJ SERIĘ
                    ElevatedButton.icon(
                      onPressed: () => onAddSet!(exerciseId),
                      icon: Icon(Icons.add, size: 18),
                      label: Text('Add Set'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                   //SizedBox(width: 5),

                    // USUŃ SERIĘ (tylko jeśli więcej niż 1)
                    if (setsCount > 1)
                      ElevatedButton.icon(
                        onPressed: () => onRemoveSet!(exerciseId),
                        icon: Icon(Icons.remove, size: 18),
                        label: Text('Remove Set'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(context).colorScheme.onError,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
