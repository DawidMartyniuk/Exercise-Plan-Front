import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/model/exercise_plan.dart';
import 'package:work_plan_front/screens/plan_creation.dart';
import '../plan_works/components/plan_validation.dart';

class PlanCardMoreOption extends ConsumerWidget {
  final VoidCallback? onDeletePlan;
  final ExerciseTable? plan;
  final VoidCallback? onShowPlan; // ✅ DODAJ NOWY CALLBACK

  const PlanCardMoreOption({
    this.onDeletePlan,
    this.plan,
    this.onShowPlan, // ✅ NOWY PARAMETR
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onSelected: (value) => _handleMenuSelection(value, context, ref),
      itemBuilder: (BuildContext context) => [
        // ✅ DODAJ SHOW PLAN NA GÓRZE
        if (onShowPlan != null)
          PopupMenuItem(
            value: 'show_plan',
            child: _buildMenuItem(
              icon: Icons.visibility,
              title: 'Show Plan',
              context: context,
              isDestructive: false,
            ),
          ),
        
        // ✅ DIVIDER JEŚLI SHOW PLAN DOSTĘPNE
        if (onShowPlan != null) const PopupMenuDivider(),
        
        PopupMenuItem(
          value: 'edit',
          child: _buildMenuItem(
            icon: Icons.edit,
            title: 'Edit',
            context: context,
            isDestructive: false,
          ),
        ),
        PopupMenuItem(
          value: 'duplicate',
          child: _buildMenuItem(
            icon: Icons.content_copy,
            title: 'Duplicate',
            context: context,
            isDestructive: false,
          ),
        ),
        
        const PopupMenuDivider(),
        
        PopupMenuItem(
          value: 'delete',
          child: _buildMenuItem(
            icon: Icons.delete,
            title: 'Delete',
            context: context,
            isDestructive: true,
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
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurface,
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isDestructive
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  void _handleMenuSelection(String value, BuildContext context, WidgetRef ref) {
    switch (value) {
      case 'show_plan': // ✅ DODAJ OBSŁUGĘ SHOW PLAN
        if (onShowPlan != null) onShowPlan!();
        break;
      case 'edit':
        if (plan != null) {
          _editPlan(context);
        }
        break;
      case 'delete':
        _showDeletePlanDialog(context);
        break;
      case 'duplicate':
        //_duplicatePlan(context);
        break;
      default:
        print('Unknown action: $value');
    }
  }

  // ✅ NOWA METODA - EDYTUJ PLAN
  void _editPlan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlanCreation(
          planToEdit: plan, // ✅ PRZEKAŻ PLAN DO EDYCJI
        ),
      ),
    );
  }

  // void _showResetProgressDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Reset Progress'),
  //         content: const Text(
  //           'Are you sure you want to reset all progress for this plan? '
  //           'This will uncheck all completed sets.',
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               if (onResetProgress != null) onResetProgress!();
  //             },
  //             style: TextButton.styleFrom(foregroundColor: Colors.red),
  //             child: const Text('Reset'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showDeletePlanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Plan'),
          content: Text(
            'Are you sure you want to delete "${plan?.exercise_table}"? '
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
    final validation = PlanValidation.validatePlan(plan!);
    
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