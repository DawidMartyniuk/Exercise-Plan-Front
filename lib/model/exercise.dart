class Exercise{
  final String id;
  final String name;
  final String bodyPart;
  final String equipment;
  final String gifUrl;
  final String target;
  final List<String> secondaryMuscles;
  final List<String> instructions;

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
      id: json['id'] as String,
      name: json['name'] as String,
      bodyPart: json['bodyPart'] as String,
      equipment: json['equipment'] as String,
      gifUrl: json['gifUrl'] as String,
      target: json['target'] as String,
      secondaryMuscles: List<String>.from(json['secondaryMuscles']),
      instructions: List<String>.from(json['instructions']),
    );
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

// extension TargetListExtension on TargetList {
//   String get name {
//     switch (this) {
//       case TargetList.abductors:
//         return "abductors";
//       case TargetList.abs:
//         return "abs";
//       case TargetList.adductors:
//         return "adductors";
//       case TargetList.biceps:
//         return "biceps";
//       case TargetList.calves:
//         return "calves";
//       case TargetList.cardiovascularSystem:
//         return "cardiovascular system";
//       case TargetList.delts:
//         return "delts";
//       case TargetList.forearms:
//         return "forearms";
//       case TargetList.glutes:
//         return "glutes";
//       case TargetList.hamstrings:
//         return "hamstrings";
//       case TargetList.lats:
//         return "lats";
//       case TargetList.levatorScapulae:
//         return "levator scapulae";
//       case TargetList.pectorals:
//         return "pectorals";
//       case TargetList.quads:
//         return "quads";
//       case TargetList.serratusAnterior:
//         return "serratus anterior";
//       case TargetList.spine:
//         return "spine";
//       case TargetList.traps:
//         return "traps";
//       case TargetList.triceps:
//         return "triceps";
//       case TargetList.upperBack:
//         return "upper back";
//     }
//   }
// }


       