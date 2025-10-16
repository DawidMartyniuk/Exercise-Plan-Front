import 'package:flutter/material.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/features/plan_creation/widgets/exercise_card.dart';
import 'package:work_plan_front/features/plan_creation/widgets/exercise_table.dart';

class ExerciseRowBuilder extends StatefulWidget {
  final Exercise exercise;
  final Map<String, dynamic> exerciseData;
  final Function(Exercise) onRemove;
  final Function(Exercise) onShowInfo;
  final Function(String, List<Map<String, String>>) onRowsChanged;
  final Function(String, String) onNotesChanged;

  const ExerciseRowBuilder({
    Key? key,
    required this.exercise,
    required this.exerciseData,
    required this.onRemove,
    required this.onShowInfo,
    required this.onRowsChanged,
    required this.onNotesChanged,
  }) : super(key: key);

  @override
  State<ExerciseRowBuilder> createState() => _ExerciseRowBuilderState();
}

class _ExerciseRowBuilderState extends State<ExerciseRowBuilder> {
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    notesController = TextEditingController(
      text: widget.exerciseData["notes"]?.toString() ?? "",
    );
    notesController.addListener(_onNotesChanged);
  }

  void _onNotesChanged() {
    widget.onNotesChanged(widget.exercise.id, notesController.text);
  }

  @override
  void dispose() {
    notesController.removeListener(_onNotesChanged);
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rows = widget.exerciseData["rows"] as List<Map<String, String>>? ?? [];
    
    return ExerciseCard(
      exercise: widget.exercise,
      onRemove: () => widget.onRemove(widget.exercise),
      onInfo: () => widget.onShowInfo(widget.exercise),
      trailing: ExerciseTable(
        exerciseId: widget.exercise.id,
        exerciseName: widget.exercise.name,
        initialRows: rows,
        onRowsChanged: (updatedRows) {
          widget.onRowsChanged(widget.exercise.id, updatedRows);
        },
        notesController: notesController,
      ),
    );
  }
}