// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_prompt_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SystemPromptModelAdapter extends TypeAdapter<SystemPromptModel> {
  @override
  final int typeId = 3;

  @override
  SystemPromptModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SystemPromptModel(
      id: fields[0] as String,
      name: fields[1] as String,
      content: fields[2] as String,
      isDefault: fields[3] as bool,
      createdAt: fields[4] as DateTime?,
      updatedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SystemPromptModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.isDefault)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemPromptModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
