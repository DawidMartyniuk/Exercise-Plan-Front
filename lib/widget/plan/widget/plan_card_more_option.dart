import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import '../plan_list/components/plan_validation.dart';

class PlanCardMoreOption extends ConsumerWidget {
  final ExerciseTable plan;
  final VoidCallback? onAddExercise;
  final VoidCallback? onEditPlan;
  final VoidCallback? onDeletePlan;
  final VoidCallback? onDuplicatePlan;
  final VoidCallback? onExportPlan;
  final VoidCallback? onSharePlan;
  final VoidCallback? onResetProgress;

  const PlanCardMoreOption({
    Key? key,
    required this.plan,
    this.onAddExercise,
    this.onEditPlan,
    this.onDeletePlan,
    this.onDuplicatePlan,
    this.onExportPlan,
    this.onSharePlan,
    this.onResetProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onSelected: (value) => _handleMenuSelection(context, value),
      itemBuilder: (BuildContext context) => [
        // ✅ DODAJ ĆWICZENIE
        // PopupMenuItem<String>(
        //   value: 'add_exercise',
        //   child: _buildMenuItem(
        //     icon: Icons.add,
        //     title: 'Add Exercise',
        //     context: context,
        //   ),
        // ),
        
        const PopupMenuDivider(),
        
        // ✅ EDYTUJ PLAN
        PopupMenuItem<String>(
          value: 'edit_plan',
          child: _buildMenuItem(
            icon: Icons.edit,
            title: 'Edit Plan',
            context: context,
          ),
        ),
        
        // ✅ DUPLIKUJ PLAN
        PopupMenuItem<String>(
          value: 'duplicate_plan',
          child: _buildMenuItem(
            icon: Icons.copy,
            title: 'Duplicate Plan',
            context: context,
          ),
        ),
        
        const PopupMenuDivider(),
        
        // ✅ RESETUJ POSTĘP
        // PopupMenuItem<String>(
        //   value: 'reset_progress',
        //   child: _buildMenuItem(
        //     icon: Icons.refresh,
        //     title: 'Reset Progress',
        //     context: context,
        //   ),
        // ),
        
        // ✅ EKSPORTUJ PLAN
        PopupMenuItem<String>(
          value: 'export_plan',
          child: _buildMenuItem(
            icon: Icons.download,
            title: 'Export Plan',
            context: context,
          ),
        ),
        
        // ✅ UDOSTĘPNIJ PLAN
        // PopupMenuItem<String>(
        //   value: 'share_plan',
        //   child: _buildMenuItem(
        //     icon: Icons.share,
        //     title: 'Share Plan',
        //     context: context,
        //   ),
        // ),
        
        const PopupMenuDivider(),
        
        // ✅ USUŃ PLAN
        PopupMenuItem<String>(
          value: 'delete_plan',
          child: _buildMenuItem(
            icon: Icons.delete,
            title: 'Delete Plan',
            context: context,
            isDestructive: true,
          ),
        ),
        
        const PopupMenuDivider(),
        
        // ✅ WALIDUJ PLAN
        PopupMenuItem<String>(
          value: 'validate_plan',
          child: _buildMenuItem(
            icon: Icons.check_circle,
            title: 'Validate Plan',
            context: context,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required BuildContext context,
    bool isDestructive = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDestructive 
              ? Colors.red 
              : Theme.of(context).colorScheme.onSurface,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDestructive 
                ? Colors.red 
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'add_exercise':
        if (onAddExercise != null) onAddExercise!();
        break;
        
      case 'edit_plan':
        if (onEditPlan != null) onEditPlan!();
        break;
        
      case 'duplicate_plan':
        if (onDuplicatePlan != null) onDuplicatePlan!();
        break;
        
      case 'export_plan':
        if (onExportPlan != null) onExportPlan!();
        break;
        
      case 'share_plan':
        if (onSharePlan != null) onSharePlan!();
        break;
        
      case 'reset_progress':
        _showResetProgressDialog(context);
        break;
        
      case 'delete_plan':
        _showDeletePlanDialog(context);
        break;
        
      case 'validate_plan':
        _showPlanValidation(context);
        break;
    }
  }

  void _showResetProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Progress'),
          content: const Text(
            'Are you sure you want to reset all progress for this plan? '
            'This will uncheck all completed sets.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onResetProgress != null) onResetProgress!();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _showDeletePlanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Plan'),
          content: Text(
            'Are you sure you want to delete "${plan.exercise_table}"? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onDeletePlan != null) onDeletePlan!();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showPlanValidation(BuildContext context) {
    final validation = PlanValidation.validatePlan(plan);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                validation.isValid ? Icons.check_circle : Icons.error,
                color: validation.isValid ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(validation.isValid ? 'Plan Valid' : 'Plan Issues'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (validation.errors.isNotEmpty) ...[
                  const Text(
                    'Errors:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  ...validation.errors.map((error) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text('• $error', style: const TextStyle(color: Colors.red)),
                  )),
                  const SizedBox(height: 16),
                ],
                
                if (validation.warnings.isNotEmpty) ...[
                  const Text(
                    'Warnings:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  ...validation.warnings.map((warning) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text('• $warning', style: const TextStyle(color: Colors.orange)),
                  )),
                ],
                
                if (validation.isValid && validation.warnings.isEmpty)
                  const Text(
                    'Your plan looks great! No issues found.',
                    style: TextStyle(color: Colors.green),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}