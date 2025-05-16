import 'package:hive/hive.dart';

part 'exercise.g.dart'; // do wygenerowania

@HiveType(typeId: 0)
class Exercise extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String bodyPart;

  @HiveField(3)
  String equipment;

  @HiveField(4)
  String gifUrl;

  @HiveField(5)
  String target;

  @HiveField(6)
  List<String> secondaryMuscles;

  @HiveField(7)
  List<String> instructions;

  Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.equipment,
    required this.gifUrl,
    required this.target,
    required this.secondaryMuscles,
    required this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      bodyPart: json['bodyPart'],
      equipment: json['equipment'],
      gifUrl: json['gifUrl'],
      target: json['target'],
      secondaryMuscles: List<String>.from(json['secondaryMuscles']),
      instructions: List<String>.from(json['instructions']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bodyPart': bodyPart,
      'equipment': equipment,
      'gifUrl': gifUrl,
      'target': target,
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

