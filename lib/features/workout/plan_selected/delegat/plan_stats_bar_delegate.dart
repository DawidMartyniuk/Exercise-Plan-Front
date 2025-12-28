import 'package:flutter/material.dart';

class PlanStatsBarDelegate extends SliverPersistentHeaderDelegate {
  final WidgetBuilder builder;
  PlanStatsBarDelegate({required this.builder});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return builder(context);
  }

  @override
  double get maxExtent => 48;
  @override
  double get minExtent => 48;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}