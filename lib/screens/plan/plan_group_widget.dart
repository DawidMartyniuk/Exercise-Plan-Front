import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/model/exercise.dart';
import 'package:work_plan_front/model/planGroup.dart';
import 'package:work_plan_front/provider/planGroupsNotifier.dart';
import 'package:work_plan_front/screens/plan/widget/plan_item_widget.dart';

class PlanGroupWidget extends ConsumerStatefulWidget {
  final PlanGroup group;
  final List<Exercise> allExercises;
  final Function(ExerciseTable, List<Exercise>) onStartWorkout;
  final Function(ExerciseTable, BuildContext, int) onDeletePlan;
  final ScrollController mainScrollController;
  final VoidCallback? onCreateNewPlan;


  static double? globalPointerDy;
  static VoidCallback? globalAutoScrollCallback;
  static VoidCallback? globalStopAutoScrollCallback;

  const PlanGroupWidget({
    Key? key,
    required this.group,
    required this.allExercises,
    required this.onStartWorkout,
    required this.onDeletePlan,
    required this.mainScrollController,
    this.onCreateNewPlan,
  }) : super(key: key);

  @override
  ConsumerState<PlanGroupWidget> createState() => _PlanGroupWidgetState();
}

class _PlanGroupWidgetState extends ConsumerState<PlanGroupWidget> {
  final TextEditingController _nameController = TextEditingController();
  bool _isEditing = false;
  Timer? _autoScrollTimer;
  DragTargetDetails? _lastDragDetails;
  bool _isDragging = false;
  double? _lastPointerDy;

@override
void initState() {
  super.initState();
  PlanGroupWidget.globalAutoScrollCallback = _startAutoScroll;
  PlanGroupWidget.globalStopAutoScrollCallback = _stopAutoScroll;
}

 @override
void dispose() {
  PlanGroupWidget.globalAutoScrollCallback = null;
  PlanGroupWidget.globalStopAutoScrollCallback = null;
  _stopAutoScroll();
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
void _startAutoScroll() {
  if (_autoScrollTimer != null && _autoScrollTimer!.isActive) return;

  _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
    final dy = PlanGroupWidget.globalPointerDy;
    if (dy == null) return;

    final scrollPos = widget.mainScrollController.position;
    const edgeThreshold = 100.0;
    const scrollSpeed = 20.0;

    if (dy < edgeThreshold && scrollPos.pixels > scrollPos.minScrollExtent) {
      widget.mainScrollController.jumpTo(
        (scrollPos.pixels - scrollSpeed).clamp(scrollPos.minScrollExtent, scrollPos.maxScrollExtent),
      );
    } else if (dy > scrollPos.viewportDimension - edgeThreshold && scrollPos.pixels < scrollPos.maxScrollExtent) {
      widget.mainScrollController.jumpTo(
        (scrollPos.pixels + scrollSpeed).clamp(scrollPos.minScrollExtent, scrollPos.maxScrollExtent),
      );
    }
  });
}

void _stopAutoScroll() {
  _autoScrollTimer?.cancel();
  _autoScrollTimer = null;
}

  // void _maybeAutoScroll(DragTargetDetails details) {
  //   if (!widget.mainScrollController.hasClients) return;

  //   final scrollPos = widget.mainScrollController.position;
  //   final dy = details.offset.dy;
  //   const edgeThreshold = 100.0;
  //   const scrollSpeed = 40.0;

  //   if (dy < edgeThreshold && scrollPos.pixels > scrollPos.minScrollExtent) {
  //     widget.mainScrollController.jumpTo(
  //       (scrollPos.pixels - scrollSpeed).clamp(scrollPos.minScrollExtent, scrollPos.maxScrollExtent),
  //     );
  //   } else if (dy > scrollPos.viewportDimension - edgeThreshold && scrollPos.pixels < scrollPos.maxScrollExtent) {
  //     widget.mainScrollController.jumpTo(
  //       (scrollPos.pixels + scrollSpeed).clamp(scrollPos.minScrollExtent, scrollPos.maxScrollExtent),
  //     );
  //   }
  // }

  // DRAG TARGET MIĘDZY PLANAMI
  Widget buildDragTargetBetweenItems(int index) {
    return DragTarget<ExerciseTable>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: candidateData.isNotEmpty ? 30 : 12,
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: candidateData.isNotEmpty ? 4 : 0),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty
                ? Theme.of(context).colorScheme.primary.withAlpha(30)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: candidateData.isNotEmpty
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: candidateData.isNotEmpty
              ? Center(
                  child: Text(
                    "Insert here",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        );
      },
      onWillAcceptWithDetails: (details) {
        _isDragging = true;
        return true;
      },
      onMove: (details) {
        _lastDragDetails = DragTargetDetails(
          data: details.data,
          offset: details.offset,
        );
      },
      onLeave: (_) {
        _isDragging = false;
        _stopAutoScroll();
      },
      onAcceptWithDetails: (details) {
         _isDragging = false;
        _stopAutoScroll();
        ref.read(planGroupsProvider.notifier).addPlanToGroupAtPosition(
          details.data,
          widget.group.id,
          index + 1,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plan inserted at position ${index + 2} in ${widget.group.name}'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
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
          // HEADER GRUPY
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
          // LISTA PLANÓW + PRZYCISK DODAWANIA (ROZWIJANA)
          if (widget.group.isExpanded)
            Container(
              constraints: BoxConstraints(minHeight: 80),
              margin: EdgeInsets.all(12),
              child: Column(
                children: [
                  // DRAG TARGET NA GÓRZE
                  DragTarget<ExerciseTable>(
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        height: candidateData.isNotEmpty ? 40 : 20,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: candidateData.isNotEmpty
                              ? Theme.of(context).colorScheme.primary.withAlpha(30)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: candidateData.isNotEmpty
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                  style: BorderStyle.solid,
                                )
                              : null,
                        ),
                        child: candidateData.isNotEmpty
                            ? Center(
                                child: Text(
                                  "Drop here to add to top",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                      );
                    },
                    onWillAcceptWithDetails: (details) {
                      _isDragging = true;
                      return true;
                    },
                    onMove: (details) {
                      _lastDragDetails = DragTargetDetails(
                        data: details.data,
                        offset: details.offset,
                      );
                    },
                    onLeave: (data) {
                      _stopAutoScroll();
                    },
                    onAcceptWithDetails: (details) {
                       _isDragging = false;
                      _stopAutoScroll();
                      ref.read(planGroupsProvider.notifier).addPlanToGroupAtPosition(
                        details.data,
                        widget.group.id,
                        0,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Plan added to top of ${widget.group.name}'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  // LISTA PLANÓW LUB KOMUNIKAT O PUSTEJ GRUPIE
                  widget.group.plans.isEmpty
                      ? Container(
                          padding: EdgeInsets.all(25),
                          child: Center(
                            child: Text(
                              'Drop plans here or create new one',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
                              ),
                            ),
                          ),
                        )
                      : Listener(
                          onPointerMove: (event) {
                            // (opcjonalnie, jeśli chcesz auto-scroll także przy zwykłym scrollowaniu myszą)
                              if (_isDragging) {
                            _lastPointerDy = event.position.dy;
                            _startAutoScroll(); // uruchamiamy auto-scroll, jeśli jesteśmy blisko krawędzi
                          }
                            // final details = DragTargetDetails(
                            //   data: null,
                            //   offset: event.position,
                            // );
                            // _maybeAutoScroll(details);
                          },
                          onPointerUp: (_) => _stopAutoScroll(),
                          child: ListView.separated(
                          //  controller: widget.mainScrollController,
                            shrinkWrap: true,
                            physics: PageScrollPhysics(),
                            padding: EdgeInsets.all(8),
                            itemCount: widget.group.plans.length,
                            separatorBuilder: (context, index) =>
                                buildDragTargetBetweenItems(index),
                            itemBuilder: (context, index) {
                              final plan = widget.group.plans[index];
                              return PlanItemWidget(
                                plan: plan,
                                allExercises: widget.allExercises,
                                onStartWorkout: widget.onStartWorkout,
                                onDeletePlan: (planToDelete, context, planId) {
                                  widget.onDeletePlan(planToDelete, context, planId);
                                },
                              );
                            },
                          ),
                        ),
                  // DRAG TARGET NA DOLE
                  DragTarget<ExerciseTable>(
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        height: candidateData.isNotEmpty ? 40 : 20,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: candidateData.isNotEmpty
                              ? Theme.of(context).colorScheme.primary.withAlpha(30)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: candidateData.isNotEmpty
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                  style: BorderStyle.solid,
                                )
                              : null,
                        ),
                        child: candidateData.isNotEmpty
                            ? Center(
                                child: Text(
                                  "Drop here to add to bottom",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                      );
                    },
                    onWillAcceptWithDetails: (details) {
                      _isDragging = true;
                      return true;
                    },
                    onMove: (details) {
                      _lastDragDetails = DragTargetDetails(
                        data: details.data,
                        offset: details.offset,
                      );
                    },
                    onLeave: (data) {
                      _stopAutoScroll();
                    },
                    onAcceptWithDetails: (details) {
                       _isDragging = false;
                      _stopAutoScroll();
                      ref.read(planGroupsProvider.notifier).addPlanToGroupAtPosition(
                        details.data,
                        widget.group.id,
                        widget.group.plans.length,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Plan added to bottom of ${widget.group.name}'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  if (widget.onCreateNewPlan != null)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        8,
                        widget.group.plans.isEmpty ? 0 : 16,
                        8,
                        8,
                      ),
                      child: _buildCreateNewPlanButton(context),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCreateNewPlanButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: widget.onCreateNewPlan,
        icon: Icon(Icons.add),
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        label: Text(
          "Create exercise plan",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  void _showDeleteGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(child: Text('Delete Group')),
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
