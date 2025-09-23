// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainingSessionAdapter extends TypeAdapter<TrainingSession> {
  @override
  final int typeId = 5;

  @override
  TrainingSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrainingSession(
      id: fields[0] as int?,
      exerciseTableId: fields[1] as int?,
      exercise_table_name: fields[2] as String?,
      startedAt: fields[3] as DateTime,
      duration: fields[4] as int,
      completed: fields[5] as bool,
      totalWeight: fields[6] as double,
      weightType: fields[7] as WeightType,
      description: fields[8] as String?,
      imageBase64: fields[9] as String?,
      exercises: (fields[10] as List).cast<CompletedExercise>(),
    );
  }

  @override
  void write(BinaryWriter writer, TrainingSession obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exerciseTableId)
      ..writeByte(2)
      ..write(obj.exercise_table_name)
      ..writeByte(3)
      ..write(obj.startedAt)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.completed)
      ..writeByte(6)
      ..write(obj.totalWeight)
      ..writeByte(7)
      ..write(obj.weightType)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.imageBase64)
      ..writeByte(10)
      ..write(obj.exercises);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CompletedExerciseAdapter extends TypeAdapter<CompletedExercise> {
  @override
  final int typeId = 6;

  @override
  CompletedExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompletedExercise(
      exerciseId: fields[0] as String,
      notes: fields[1] as String,
      sets: (fields[2] as List).cast<CompletedSet>(),
    );
  }

  @override
  void write(BinaryWriter writer, CompletedExercise obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.exerciseId)
      ..writeByte(1)
      ..write(obj.notes)
      ..writeByte(2)
      ..write(obj.sets);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletedExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CompletedSetAdapter extends TypeAdapter<CompletedSet> {
  @override
  final int typeId = 7;

  @override
  CompletedSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompletedSet(
      colStep: fields[0] as int,
      actualKg: fields[1] as int,
      actualReps: fields[2] as int,
      completed: fields[3] as bool,
      toFailure: fields[4] as bool,
      weightType: fields[5] as WeightType,
    );
  }

  @override
  void write(BinaryWriter writer, CompletedSet obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.colStep)
      ..writeByte(1)
      ..write(obj.actualKg)
      ..writeByte(2)
      ..write(obj.actualReps)
      ..writeByte(3)
      ..write(obj.completed)
      ..writeByte(4)
      ..write(obj.toFailure)
      ..writeByte(5)
      ..write(obj.weightType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletedSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
