import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/features/workout/components/common_ui/plan_selected_appBar.dart';
import 'package:work_plan_front/features/workout/plan_selected/components/plan_stats_bar.dart';
import 'package:work_plan_front/features/workout/components/plan_ui/progress_bar.dart';

class SliverBuilders {
  static Widget buildAppBarSliver({
    required VoidCallback onBack,
    required String planName,
    required VoidCallback onSavePlan,
    required bool isReadOnly,
    required bool isWorkoutMode,
    required VoidCallback onEditPlan,
  }) {
    return SliverToBoxAdapter(
      child: PlanSelectedAppBar(
        onBack: onBack,
        planName: planName,
        onSavePlan: onSavePlan,
        isReadOnly: isReadOnly,
        isWorkoutMode: isWorkoutMode,
        onEditPlan: onEditPlan,
      ),
    );
  }

  static Widget buildStatsBarSliver({
    required bool isWorkoutMode,
    required bool isWorkoutActive,
    required int currentStep,
  }) {
    return SliverToBoxAdapter(
      child: Consumer(
        builder: (context, ref, _) => PlanStatsBar(
          isWorkoutMode: isWorkoutMode,
          isWorkoutActive: isWorkoutActive,
          sets: currentStep,
        ),
      ),
    );
  }

  static Widget buildProgressBarSliver({
    required int totalSteps,
    required int currentStep,
    required bool isReadOnly,
  }) {
    return SliverToBoxAdapter(
      child: ProgressBar(
        totalSteps: totalSteps,
        currentStep: currentStep,
        isReadOnly: isReadOnly,
      ),
    );
  }
}