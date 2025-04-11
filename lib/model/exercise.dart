class Exercise{
  final int id;
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


       