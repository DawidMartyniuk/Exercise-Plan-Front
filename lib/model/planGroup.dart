import 'package:work_plan_front/model/exercise_plan.dart';

class PlanGroup {
  final String id;
  String name;
  List<ExerciseTable> plans;
  bool isExpanded;

  PlanGroup({
    required this.id,
    required this.name,
    required this.plans,
    this.isExpanded = true,
  });

  PlanGroup copyWith({
    String? id,
    String? name,
    List<ExerciseTable>? plans,
    bool? isExpanded,
  }) {
    return PlanGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      plans: plans ?? this.plans,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plans': plans.map((p) => p.toJson()).toList(),
      'isExpanded': isExpanded,
    };
  }

  factory PlanGroup.fromJson(Map<String, dynamic> json) {
    return PlanGroup(
      id: json['id'],
      name: json['name'],
      plans: (json['plans'] as List)
          .map((p) => ExerciseTable.fromJson(p))
          .toList(),
      isExpanded: json['isExpanded'] ?? true,
    );
  }
}