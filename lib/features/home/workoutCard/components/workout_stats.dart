import 'package:flutter/material.dart';
import 'package:work_plan_front/model/training_session.dart';
import 'package:work_plan_front/features/home/workoutCard/components/stat_item.dart';
import 'package:work_plan_front/features/home/workoutCard/components/workout_stats_dialog.dart';

class WorkoutStats extends StatelessWidget {
  final String duration;
  final String volume;
  final String sets;
  final String reps;
  final bool isCompact;
  final TrainingSession? trainingSession;

  const WorkoutStats({
    super.key,
    required this.duration,
    required this.volume,
    required this.sets,
    required this.reps,
    this.isCompact = true,
    this.trainingSession,
  });


  @override
  Widget build(BuildContext context) {
    final stats = [
      StatItem(
        label: "Time",
        value: duration,
        icon: Icons.access_time,
        color: Colors.blue,
      ),
      StatItem(
        label: "Volume",
        value: volume,
        icon: Icons.fitness_center,
        color: Colors.orange,
      ),
      StatItem(
        label: "Sets",
        value: sets,
        icon: Icons.repeat,
        color: Colors.green,
      ),
      StatItem(
        label: "Reps",
        value: reps,
        icon: Icons.speed,
        color: Colors.purple,
      ),
    ];

    return Container(
      padding: EdgeInsets.all(isCompact ? 8 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: isCompact ? _buildCompactLayout(stats, context) : _buildFullLayout(stats, context),
    );
  }

  Widget _buildCompactLayout(List<StatItem> stats, BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: stats.asMap().entries.map((entry) {
          final index = entry.key;
          final stat = entry.value;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(child: _buildStatCard(stat, context, true)),
                if (index < stats.length - 1) 
                  Container(
                    width: 1,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.outline.withAlpha(25),
                          Theme.of(context).colorScheme.outline.withAlpha(102),
                          Theme.of(context).colorScheme.outline.withAlpha(25),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFullLayout(List<StatItem> stats, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard(stats[0], context, false)),
            SizedBox(width: 12),
            Expanded(child: _buildStatCard(stats[1], context, false)),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard(stats[2], context, false)),
            SizedBox(width: 12),
            Expanded(child: _buildStatCard(stats[3], context, false)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(StatItem stat, BuildContext context, bool isCompact) {
  return GestureDetector(
    onTap: () {
      
      if (!isCompact && trainingSession != null) {
        print("🔍 Opening dialog for: ${stat.label}");
        WorkoutStatsDialog.show(context, stat, trainingSession!);
      } else {
        print("❌ Dialog not opened: isCompact=$isCompact, trainingSession=${trainingSession != null}");
      }
    },
      child: Container(
        padding: EdgeInsets.all(isCompact ? 6 : 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: isCompact ? _buildCompactContent(stat, context) : _buildFullContent(stat, context),
      ),
    );
  }

  Widget _buildCompactContent(StatItem stat, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
   
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 0 , left: 6, right: 6, top: 6),
          decoration: BoxDecoration(
            color: stat.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            stat.icon,
            size: 16,
            color: stat.color,
          ),
        ),
        SizedBox(height: 6),
        Text(
          stat.value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 1),
        Text(
          stat.label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFullContent(StatItem stat, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: stat.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            stat.icon,
            size: 20,
            color: stat.color,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                stat.value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2),
              Text(
                stat.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Removed _StatItem class because StatItem from import is used instead.



