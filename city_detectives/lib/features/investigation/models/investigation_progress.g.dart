// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investigation_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvestigationProgressAdapter extends TypeAdapter<InvestigationProgress> {
  @override
  final int typeId = 0;

  @override
  InvestigationProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvestigationProgress(
      investigationId: fields[0] as String,
      currentEnigmaIndex: fields[1] as int,
      completedEnigmaIds: (fields[2] as List).cast<String>(),
      updatedAtMs: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, InvestigationProgress obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.investigationId)
      ..writeByte(1)
      ..write(obj.currentEnigmaIndex)
      ..writeByte(2)
      ..write(obj.completedEnigmaIds)
      ..writeByte(3)
      ..write(obj.updatedAtMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvestigationProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
