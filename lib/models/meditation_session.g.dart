// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meditation_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MeditationSessionAdapter extends TypeAdapter<MeditationSession> {
  @override
  final int typeId = 10;

  @override
  MeditationSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeditationSession(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      durationMinutes: fields[3] as int,
      type: fields[4] as MeditationType,
      audioUrl: fields[5] as String?,
      imageUrl: fields[6] as String?,
      level: fields[7] as MeditationLevel,
      tags: (fields[8] as List).cast<String>(),
      instructions: fields[9] as String?,
      isCompleted: fields[10] as bool,
      completedAt: fields[11] as DateTime?,
      rewardPoints: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MeditationSession obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.audioUrl)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.level)
      ..writeByte(8)
      ..write(obj.tags)
      ..writeByte(9)
      ..write(obj.instructions)
      ..writeByte(10)
      ..write(obj.isCompleted)
      ..writeByte(11)
      ..write(obj.completedAt)
      ..writeByte(12)
      ..write(obj.rewardPoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeditationSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MeditationTypeAdapter extends TypeAdapter<MeditationType> {
  @override
  final int typeId = 11;

  @override
  MeditationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MeditationType.guided;
      case 1:
        return MeditationType.breathing;
      case 2:
        return MeditationType.mindfulness;
      case 3:
        return MeditationType.sleep;
      case 4:
        return MeditationType.focus;
      case 5:
        return MeditationType.anxiety;
      case 6:
        return MeditationType.stress;
      case 7:
        return MeditationType.gratitude;
      case 8:
        return MeditationType.bodyScanning;
      case 9:
        return MeditationType.visualization;
      default:
        return MeditationType.guided;
    }
  }

  @override
  void write(BinaryWriter writer, MeditationType obj) {
    switch (obj) {
      case MeditationType.guided:
        writer.writeByte(0);
        break;
      case MeditationType.breathing:
        writer.writeByte(1);
        break;
      case MeditationType.mindfulness:
        writer.writeByte(2);
        break;
      case MeditationType.sleep:
        writer.writeByte(3);
        break;
      case MeditationType.focus:
        writer.writeByte(4);
        break;
      case MeditationType.anxiety:
        writer.writeByte(5);
        break;
      case MeditationType.stress:
        writer.writeByte(6);
        break;
      case MeditationType.gratitude:
        writer.writeByte(7);
        break;
      case MeditationType.bodyScanning:
        writer.writeByte(8);
        break;
      case MeditationType.visualization:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeditationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MeditationLevelAdapter extends TypeAdapter<MeditationLevel> {
  @override
  final int typeId = 12;

  @override
  MeditationLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MeditationLevel.beginner;
      case 1:
        return MeditationLevel.intermediate;
      case 2:
        return MeditationLevel.advanced;
      default:
        return MeditationLevel.beginner;
    }
  }

  @override
  void write(BinaryWriter writer, MeditationLevel obj) {
    switch (obj) {
      case MeditationLevel.beginner:
        writer.writeByte(0);
        break;
      case MeditationLevel.intermediate:
        writer.writeByte(1);
        break;
      case MeditationLevel.advanced:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeditationLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MeditationProgressAdapter extends TypeAdapter<MeditationProgress> {
  @override
  final int typeId = 13;

  @override
  MeditationProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeditationProgress(
      userId: fields[0] as String,
      totalSessions: fields[1] as int,
      totalMinutes: fields[2] as int,
      currentStreak: fields[3] as int,
      longestStreak: fields[4] as int,
      lastSessionDate: fields[5] as DateTime?,
      totalRewardPoints: fields[6] as int,
      completedSessionIds: (fields[7] as List?)?.cast<String>(),
      categoryProgress: (fields[8] as Map?)?.cast<String, int>(),
      sessionDates: (fields[9] as List?)?.cast<DateTime>(),
      level: fields[10] as int,
      unlockedAchievements: (fields[11] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, MeditationProgress obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.totalSessions)
      ..writeByte(2)
      ..write(obj.totalMinutes)
      ..writeByte(3)
      ..write(obj.currentStreak)
      ..writeByte(4)
      ..write(obj.longestStreak)
      ..writeByte(5)
      ..write(obj.lastSessionDate)
      ..writeByte(6)
      ..write(obj.totalRewardPoints)
      ..writeByte(7)
      ..write(obj.completedSessionIds)
      ..writeByte(8)
      ..write(obj.categoryProgress)
      ..writeByte(9)
      ..write(obj.sessionDates)
      ..writeByte(10)
      ..write(obj.level)
      ..writeByte(11)
      ..write(obj.unlockedAchievements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeditationProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
