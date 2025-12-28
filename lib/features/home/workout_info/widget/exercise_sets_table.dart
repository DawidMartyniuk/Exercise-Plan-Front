import 'package:flutter/material.dart';
import 'package:work_plan_front/model/training_session.dart';

class ExerciseSetsTable extends StatelessWidget {
  final CompletedExercise exercise;
  final String? exerciseName;
  final bool isExpanded;

  const ExerciseSetsTable({
    super.key,
    required this.exercise,
    this.exerciseName,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isExpanded) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withAlpha((0.5 * 255).toInt()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(50),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ TYTUŁ SEKCJI
          Center(
            child: Text(
              'Sets Details',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8),
          
          // ✅ TABELA SETÓW - PODOBNA DO plan_selected_card
          Table(
            border: TableBorder.all(
              color: Theme.of(context).colorScheme.outline.withAlpha(50),
              width: 1,
            ),
            children: [
              // ✅ NAGŁÓWEK TABELI
              TableRow(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(20),
                ),
                children: [
                  _buildHeaderCell(context, "Set"),
                  _buildHeaderCell(context, "Weight"),
                  _buildHeaderCell(context, "Reps"),
                  _buildHeaderCell(context, "Status"),
                ],
              ),
              // ✅ WIERSZE Z DANYMI
              ...exercise.sets.asMap().entries.map((entry) {
                final index = entry.key;
                final set = entry.value;
                return _buildSetRow(context, index + 1, set);
              }),
            ],
          ),
          
          // ✅ NOTATKI (jeśli są)
          if (exercise.notes.isNotEmpty) ...[
            SizedBox(height: 12),
            Divider(color: Theme.of(context).dividerColor),
            SizedBox(height: 8),
            Text(
              'Notes:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              exercise.notes,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TableRow _buildSetRow(BuildContext context, int setNumber, CompletedSet set) {
    return TableRow(
      decoration: BoxDecoration(
        color: _getSetRowColor(context, set),
      ),
      children: [
        // ✅ NUMER SETA
        _buildDataCell(context, setNumber.toString()),
        
        // ✅ CIĘŻAR
        _buildDataCell(context, "${set.actualKg.toInt()}kg"),
        
        // ✅ POWTÓRZENIA
        _buildDataCell(context, set.actualReps.toString()),
        
        // ✅ STATUS (completed/failed)
        _buildStatusCell(context, set),
      ],
    );
  }

  Widget _buildDataCell(BuildContext context, String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStatusCell(BuildContext context, CompletedSet set) {
    IconData icon;
    Color iconColor;
    
    // ✅ OKREŚL IKONĘ I KOLOR NA PODSTAWIE STATUSU
    if (set.toFailure) {
      icon = Icons.close;
      iconColor = Colors.orange;
    } else {
      icon = Icons.check;
      iconColor = Colors.green;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Icon(
        icon,
        size: 16,
        color: iconColor,
      ),
    );
  }

  Color _getSetRowColor(BuildContext context, CompletedSet set) {
    if (set.toFailure) {
      return Colors.orange.withAlpha(30); // ✅ LEKKI POMARAŃCZOWY dla failure
    } else {
      return Colors.green.withAlpha(30); // ✅ LEKKI ZIELONY dla completed
    }
  }
}