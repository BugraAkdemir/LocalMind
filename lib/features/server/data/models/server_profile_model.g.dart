// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServerProfileModelAdapter extends TypeAdapter<ServerProfileModel> {
  @override
  final int typeId = 0;

  @override
  ServerProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServerProfileModel(
      id: fields[0] as String,
      name: fields[1] as String,
      host: fields[2] as String,
      port: fields[3] as int,
      isDefault: fields[4] as bool,
      lastConnected: fields[5] as DateTime?,
      isActive: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ServerProfileModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.host)
      ..writeByte(3)
      ..write(obj.port)
      ..writeByte(4)
      ..write(obj.isDefault)
      ..writeByte(5)
      ..write(obj.lastConnected)
      ..writeByte(6)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
