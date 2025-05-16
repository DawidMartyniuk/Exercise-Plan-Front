// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 0;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise(
      id: fields[0] as String,
      name: fields[1] as String,
      bodyPart: fields[2] as String,
      equipment: fields[3] as String,
      gifUrl: fields[4] as String,
      target: fields[5] as String,
      secondaryMuscles: (fields[6] as List).cast<String>(),
      instructions: (fields[7] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.bodyPart)
      ..writeByte(3)
      ..write(obj.equipment)
      ..writeByte(4)
      ..write(obj.gifUrl)
      ..writeByte(5)
      ..write(obj.target)
      ..writeByte(6)
      ..write(obj.secondaryMuscles)
      ..writeByte(7)
      ..write(obj.instructions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
