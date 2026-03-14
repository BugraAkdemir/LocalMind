// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 4;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      themeMode: fields[0] as String,
      textSize: fields[1] as String,
      enableSpeech: fields[2] as bool,
      defaultTemperature: fields[3] as double,
      defaultTopP: fields[4] as double,
      defaultMaxTokens: fields[5] as int,
      isAssistantEnabled: fields[6] == null ? false : fields[6] as bool,
      porcupineAccessKey: fields[7] == null ? '' : fields[7] as String,
      assistantSensitivity: fields[8] == null ? 0.5 : fields[8] as double,
      wakeWord: fields[9] == null ? 'PORCUPINE' : fields[9] as String,
      enableTools: fields[10] == null ? true : fields[10] as bool,
      isBetaEnabled: fields[11] == null ? false : fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.textSize)
      ..writeByte(2)
      ..write(obj.enableSpeech)
      ..writeByte(3)
      ..write(obj.defaultTemperature)
      ..writeByte(4)
      ..write(obj.defaultTopP)
      ..writeByte(5)
      ..write(obj.defaultMaxTokens)
      ..writeByte(6)
      ..write(obj.isAssistantEnabled)
      ..writeByte(7)
      ..write(obj.porcupineAccessKey)
      ..writeByte(8)
      ..write(obj.assistantSensitivity)
      ..writeByte(9)
      ..write(obj.wakeWord)
      ..writeByte(10)
      ..write(obj.enableTools)
      ..writeByte(11)
      ..write(obj.isBetaEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
