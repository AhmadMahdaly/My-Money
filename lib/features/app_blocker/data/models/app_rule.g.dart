// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_rule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppRuleAdapter extends TypeAdapter<AppRule> {
  @override
  final int typeId = 1;

  @override
  AppRule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppRule(
      packageName: fields[0] as String,
      isEnabled: fields[1] as bool,
      timeLimitMinutes: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AppRule obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.isEnabled)
      ..writeByte(2)
      ..write(obj.timeLimitMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppRuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
