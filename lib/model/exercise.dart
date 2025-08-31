import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 0)
class Exercise extends HiveObject {
  @HiveField(0)
  final String exerciseId; // ✅ ZMIANA: z 'id' na 'exerciseId'

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> bodyParts; // ✅ ZMIANA: z String na List<String>

  @HiveField(3)
  final List<String> equipments; // ✅ ZMIANA: z String na List<String>

  @HiveField(4)
  final String? gifUrl;

  @HiveField(5)
  final List<String> targetMuscles; // ✅ ZMIANA: z 'target' na 'targetMuscles'

  @HiveField(6)
  final List<String> secondaryMuscles;

  @HiveField(7)
  final List<String> instructions;

  Exercise({
    required this.exerciseId,
    required this.name,
    required this.bodyParts,
    required this.equipments,
    this.gifUrl,
    required this.targetMuscles,
    required this.secondaryMuscles,
    required this.instructions,
  });

  // ✅ GETTER dla kompatybilności
  String get id => exerciseId;
  String get bodyPart => bodyParts.isNotEmpty ? bodyParts.first : '';
  String get equipment => equipments.isNotEmpty ? equipments.first : '';
  String get target => targetMuscles.isNotEmpty ? targetMuscles.first : '';

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseId: json['exerciseId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      bodyParts: List<String>.from(json['bodyParts'] ?? []),
      equipments: List<String>.from(json['equipments'] ?? []),
      gifUrl: json['gifUrl']?.toString(),
      targetMuscles: List<String>.from(json['targetMuscles'] ?? []),
      secondaryMuscles: List<String>.from(json['secondaryMuscles'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'bodyParts': bodyParts,
      'equipments': equipments,
      'gifUrl': gifUrl,
      'targetMuscles': targetMuscles,
      'secondaryMuscles': secondaryMuscles,
      'instructions': instructions,
    };
  }
}


enum BodyPart {
    back,
    cardio,
    chest,
    lower_arms,
    lower_legs,
    neck,
    shoulders,
    upper_arms,
    upper_legs,
    waist
}
extension EquipmentBodyPart on BodyPart {
  String displayNameBodyPart() {
    switch(this) {
      case BodyPart.back:
        return "back";
      case BodyPart.cardio:
        return "cardio";
      case BodyPart.chest:
        return "chest";
      case BodyPart.lower_arms:
        return "lower arms";
      case BodyPart.lower_legs:
        return "lower legs";
      case BodyPart.neck:
        return "neck";
      case BodyPart.shoulders:
        return "shoulders";
      case BodyPart.upper_arms:
        return "upper arms";
      case BodyPart.upper_legs:
        return "upper legs";
      case BodyPart.waist:
        return "waist";
    }
    }
  }
 


enum TargetList {
    abductors,
    abs,
    adductors,
    biceps,
    calves,
    cardiovascularSystem,
    delts,
    forearms,
    glutes,
    hamstrings,
    lats,
    levatorScapulae,
    pectorals,
    quads,
    serratusAnterior,
    spine,
    traps,
    triceps,
    upperBack,
}
enum EquipmentList {
    assisted,
    band,
    barbell,
    bodyWeight,
    bosuBall,
    cable,
    dumbbell,
    ellipticalMachine,
    ezBarbell,
    hammer,
    kettlebell,
    leverageMachine,
    medicineBall,
    olympicBarbell,
    resistanceBand,
    roller,
    rope,
    skiergMachine,
    sledMachine,
    smithMachine,
    stabilityBall,
    stationaryBike,
    stepmillMachine,
    tire,
    trapBar,
    upperBodyErgometer,
    weighted,
    wheelRoller
}

extension EquipmentListExtension on EquipmentList {
  String get displayName {
    switch (this) {
      case EquipmentList.assisted:
        return "assisted";
      case EquipmentList.band:
        return "band";
      case EquipmentList.barbell:
        return "barbell";
      case EquipmentList.bodyWeight:
        return "body weight";
      case EquipmentList.bosuBall:
        return "bosu ball";
      case EquipmentList.cable:
        return "cable";
      case EquipmentList.dumbbell:
        return "dumbbell";
      case EquipmentList.ellipticalMachine:
        return "elliptical machine";
      case EquipmentList.ezBarbell:
        return "ez barbell";
      case EquipmentList.hammer:
        return "hammer";
      case EquipmentList.kettlebell:
        return "kettlebell";
      case EquipmentList.leverageMachine:
        return "leverage machine";
      case EquipmentList.medicineBall:
        return "medicine ball";
      case EquipmentList.olympicBarbell:
        return "olympic barbell";
      case EquipmentList.resistanceBand:
        return "resistance band";
      case EquipmentList.roller:
        return "roller";
      case EquipmentList.rope:
        return "rope";
      case EquipmentList.skiergMachine:
        return "skierg machine";
      case EquipmentList.sledMachine:
        return "sled machine";
      case EquipmentList.smithMachine:
        return "smith machine";
      case EquipmentList.stabilityBall:
        return "stability ball";
      case EquipmentList.stationaryBike:
        return "stationary bike";
      case EquipmentList.stepmillMachine:
        return "stepmill machine";
      case EquipmentList.tire:
        return "tire";
      case EquipmentList.trapBar:
        return "trap bar";
      case EquipmentList.upperBodyErgometer:
        return "upper body ergometer";
      case EquipmentList.weighted:
        return "weighted";
      case EquipmentList.wheelRoller:
        return "wheel roller";
    }
  }
}

