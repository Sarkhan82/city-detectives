// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completed_investigation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompletedInvestigationAdapter
    extends TypeAdapter<CompletedInvestigation> {
  @override
  final int typeId = 1;

  @override
  CompletedInvestigation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompletedInvestigation(
      investigationId: fields[0] as String,
      completedAtMs: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CompletedInvestigation obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.investigationId)
      ..writeByte(1)
      ..write(obj.completedAtMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletedInvestigationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
