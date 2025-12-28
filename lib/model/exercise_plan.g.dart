// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseTableAdapter extends TypeAdapter<ExerciseTable> {
  @override
  final int typeId = 2;

  @override
  ExerciseTable read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseTable(
      id: fields[0] as int,
      exercise_table: fields[1] as String,
      rows: (fields[2] as List).cast<ExerciseRowsData>(),
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseTable obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exercise_table)
      ..writeByte(2)
      ..write(obj.rows);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseTableAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseRowsDataAdapter extends TypeAdapter<ExerciseRowsData> {
  @override
  final int typeId = 3;

  @override
  ExerciseRowsData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseRowsData(
      exercise_name: fields[0] as String,
      exercise_number: fields[1] as String,
      notes: fields[2] as String,
      data: (fields[3] as List).cast<ExerciseRow>(),
      rep_type: fields[4] as RepsType,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseRowsData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.exercise_name)
      ..writeByte(1)
      ..write(obj.exercise_number)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.data)
      ..writeByte(4)
      ..write(obj.rep_type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseRowsDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseRowAdapter extends TypeAdapter<ExerciseRow> {
  @override
  final int typeId = 4;

  @override
  ExerciseRow read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseRow(
      colStep: fields[0] as int,
      colKg: fields[1] as int,
      colRepMin: fields[2] as int,
      colRepMax: fields[3] as int?,
      weightType: fields[4] as WeightType,
      isChecked: fields[5] as bool,
      isFailure: fields[7] as bool,
      rowColor: fields[6] as Color?,
      isUserModified: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseRow obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.colStep)
      ..writeByte(1)
      ..write(obj.colKg)
      ..writeByte(2)
      ..write(obj.colRepMin)
      ..writeByte(3)
      ..write(obj.colRepMax)
      ..writeByte(4)
      ..write(obj.weightType)
      ..writeByte(5)
      ..write(obj.isChecked)
      ..writeByte(6)
      ..write(obj.rowColor)
      ..writeByte(7)
      ..write(obj.isFailure)
      ..writeByte(8)
      ..write(obj.isUserModified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseRowAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
