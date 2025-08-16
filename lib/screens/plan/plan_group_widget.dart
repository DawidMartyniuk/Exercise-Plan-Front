import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/model/planGroup.dart';
import 'package:work_plan_front/provider/planGroupsNotifier.dart';
import 'package:work_plan_front/screens/plan/plan_item_widget.dart';

class PlanGroupWidget extends ConsumerStatefulWidget {
  final PlanGroup group;
  final List<Exercise> allExercises;
  final Function(ExerciseTable, List<Exercise>) onStartWorkout;
  final Function(ExerciseTable, BuildContext, int) onDeletePlan;

  const PlanGroupWidget({
    Key? key,
    required this.group,
    required this.allExercises,
    required this.onStartWorkout,
    required this.onDeletePlan,
  }) : super(key: key);

  @override
  ConsumerState<PlanGroupWidget> createState() => _PlanGroupWidgetState();
}

class _PlanGroupWidgetState extends ConsumerState<PlanGroupWidget> {

  final TextEditingController _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.group.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _saveGroupName() {
    if (_nameController.text.trim().isNotEmpty) {
      ref.read(planGroupsProvider.notifier).updateGroupName(
        widget.group.id,
        _nameController.text.trim(),
      );
    }
    setState(() {
      _isEditing = false;
    });
  }

  void _cancelEditing() {
    _nameController.text = widget.group.name;
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withAlpha((0.8 * 255).toInt()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(80),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withAlpha(50),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      
      child: Column(
        children: [
          // ✅ HEADER GRUPY
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(40),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(80),
                  width: 1.5,
                ),
              ),
            ),
            child: Row(
              children: [
                // ✅ IKONA ROZWIJANIA
                GestureDetector(
                  onTap: () {
                    ref.read(planGroupsProvider.notifier).toggleGroupExpanded(widget.group.id);
                  },
                  child: Icon(
                    widget.group.isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(width: 16),
                
                // ✅ NAZWA GRUPY (EDYTOWALNA)
                Expanded(
                  child: _isEditing
                      ? TextField(
                          controller: _nameController,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _saveGroupName(),
                          autofocus: true,
                        )
                      : GestureDetector(
                          onTap: _startEditing,
                          child: Text(
                            widget.group.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                
                // ✅ LICZBA PLANÓW
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.group.plans.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // ✅ PRZYCISKI AKCJI
                if (_isEditing) ...[
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: _saveGroupName,
                    icon: Icon(Icons.check, color: Colors.green),
                    iconSize: 20,
                  ),
                  IconButton(
                    onPressed: _cancelEditing,
                    icon: Icon(Icons.close, color: Colors.red),
                    iconSize: 20,
                  ),
                ] else ...[
                  SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _startEditing();
                      } else if (value == 'delete') {
                        _showDeleteGroupDialog();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit Name'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Group', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // ✅ LISTA PLANÓW (ROZWIJANA)
          if (widget.group.isExpanded)
            DragTarget<ExerciseTable>(
              builder: (context, candidateData, rejectedData) {
                return Container(
                  constraints: BoxConstraints(minHeight: 80),
                  margin: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? Theme.of(context).colorScheme.primary.withAlpha(20)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: candidateData.isNotEmpty
                       ? Border.all(
                        color: Theme.of(context).colorScheme.outline.withAlpha(80),
                        width: 1.5,
                    )
                       : null,
                  ),
                  child: widget.group.plans.isEmpty
                      ? Container(
                          padding: EdgeInsets.all(25),
                          child: Center(
                            child: Text(
                              'Drop plans here or tap to add',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(8),
                          itemCount: widget.group.plans.length,
                          separatorBuilder: (context, index) => SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final plan = widget.group.plans[index];
                            return PlanItemWidget(
                              plan: plan,
                              allExercises: widget.allExercises,
                              onStartWorkout: widget.onStartWorkout,
                              onDeletePlan: (planToDelete, context, planId) {
                               
                               // ref.read(planGroupsProvider.notifier).removePlanFromGroups(planToDelete, widget.group.id);

                                widget.onDeletePlan(
                                  planToDelete,
                                  context,
                                  planId,
                                );
                              }
                            );
                          },
                        ),
                );
              },
              onWillAcceptWithDetails: (data) => data != null,
              onAcceptWithDetails: (plan) {
                ref.read(planGroupsProvider.notifier).movePlanToGroup(plan.data, widget.group.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Plan moved to ${widget.group.name}'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showDeleteGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Group'),
        content: Text('Are you sure you want to delete "${widget.group.name}"?\n\nAll plans will be moved to another group.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(planGroupsProvider.notifier).deleteGroup(widget.group.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}