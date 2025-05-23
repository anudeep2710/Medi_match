// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meditation_achievement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MeditationAchievementAdapter extends TypeAdapter<MeditationAchievement> {
  @override
  final int typeId = 14;

  @override
  MeditationAchievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeditationAchievement(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      iconName: fields[3] as String,
      requiredValue: fields[4] as int,
      type: fields[5] as AchievementType,
      rewardPoints: fields[6] as int,
      isUnlocked: fields[7] as bool,
      unlockedAt: fields[8] as DateTime?,
      category: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MeditationAchievement obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconName)
      ..writeByte(4)
      ..write(obj.requiredValue)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.rewardPoints)
      ..writeByte(7)
      ..write(obj.isUnlocked)
      ..writeByte(8)
      ..write(obj.unlockedAt)
      ..writeByte(9)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeditationAchievementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AchievementTypeAdapter extends TypeAdapter<AchievementType> {
  @override
  final int typeId = 15;

  @override
  AchievementType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AchievementType.sessions;
      case 1:
        return AchievementType.totalMinutes;
      case 2:
        return AchievementType.streak;
      case 3:
        return AchievementType.level;
      case 4:
        return AchievementType.category;
      default:
        return AchievementType.sessions;
    }
  }

  @override
  void write(BinaryWriter writer, AchievementType obj) {
    switch (obj) {
      case AchievementType.sessions:
        writer.writeByte(0);
        break;
      case AchievementType.totalMinutes:
        writer.writeByte(1);
        break;
      case AchievementType.streak:
        writer.writeByte(2);
        break;
      case AchievementType.level:
        writer.writeByte(3);
        break;
      case AchievementType.category:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
