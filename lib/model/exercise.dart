import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 0)
class Exercise extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String bodyPart;

  @HiveField(3)
  final String equipment;

  @HiveField(4)
  final String? gifUrl; // ✅ Nullable, bo API nie zwraca tego pola

  @HiveField(5)
  final String target;

  @HiveField(6)
  final List<String> secondaryMuscles;

  @HiveField(7)
  final List<String> instructions;

  @HiveField(8)
  final String? description; // ✅ DODAJ: nowe pola z API

  @HiveField(9)
  final String? difficulty; // ✅ DODAJ

  @HiveField(10)
  final String? category; // ✅ DODAJ

  Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.equipment,
    this.gifUrl,
    required this.target,
    required this.secondaryMuscles,
    required this.instructions,
    this.description, // ✅ DODAJ
    this.difficulty,  // ✅ DODAJ
    this.category,    // ✅ DODAJ
  });

  // ✅ DODAJ: getter do formatowania bodyPart
  String get formattedBodyPart {
    return bodyPart.replaceAll('_', ' ').toUpperCase();
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id']?.toString() ?? '', // ✅ Obsługa null
      name: json['name']?.toString() ?? '',
      bodyPart: json['bodyPart']?.toString() ?? '',
      equipment: json['equipment']?.toString() ?? '',
      gifUrl: null, // ✅ API nie zwraca tego pola - ustawimy później
      target: json['target']?.toString() ?? '',
      secondaryMuscles: List<String>.from(json['secondaryMuscles'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      description: json['description']?.toString(), // ✅ DODAJ
      difficulty: json['difficulty']?.toString(),   // ✅ DODAJ
      category: json['category']?.toString(),       // ✅ DODAJ
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
      'description': description, // ✅ DODAJ
      'difficulty': difficulty,   // ✅ DODAJ
      'category': category,       // ✅ DODAJ
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

