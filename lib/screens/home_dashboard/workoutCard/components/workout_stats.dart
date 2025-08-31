import 'package:flutter/material.dart';

class WorkoutStats extends StatelessWidget {
  final String duration;
  final String volume;
  final String sets;
  final String reps;
  final bool isCompact;

  const WorkoutStats({
    super.key,
    required this.duration,
    required this.volume,
    required this.sets,
    required this.reps,
    this.isCompact = true,
  });

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatItem(label: "Time", value: duration),
      _StatItem(label: "Volume", value: volume),
      _StatItem(label: "Sets", value: sets),
      _StatItem(label: "Reps", value: reps),
    ];

    if (isCompact) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 16), // ✅ TYLKO JEDEN SizedBox
            ...stats.map((stat) => 
              Padding(
                padding: EdgeInsets.only(right: 24),
                child: _buildStatColumn(stat, context),
              ),
            ).toList(),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stats.map((stat) => _buildStatColumn(stat, context)).toList(),
    );
  }

  Widget _buildStatColumn(_StatItem stat, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stat.label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 4.0),
        Text(
          stat.value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  _StatItem({required this.label, required this.value});
}