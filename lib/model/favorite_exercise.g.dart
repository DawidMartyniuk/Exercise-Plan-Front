// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteExerciseAdapter extends TypeAdapter<FavoriteExercise> {
  @override
  final int typeId = 1;

  @override
  FavoriteExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteExercise(
      exerciseId: fields[0] as String,
      addedAt: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteExercise obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.exerciseId)
      ..writeByte(1)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
