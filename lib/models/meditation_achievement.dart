import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'meditation_achievement.g.dart';

@HiveType(typeId: 14)
class MeditationAchievement extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String iconName;

  @HiveField(4)
  int requiredValue;

  @HiveField(5)
  AchievementType type;

  @HiveField(6)
  int rewardPoints;

  @HiveField(7)
  bool isUnlocked;

  @HiveField(8)
  DateTime? unlockedAt;

  @HiveField(9)
  String category;

  MeditationAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.requiredValue,
    required this.type,
    required this.rewardPoints,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.category,
  });

  IconData get icon {
    switch (iconName) {
      case 'star':
        return Icons.star;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'timer':
        return Icons.timer;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'psychology':
        return Icons.psychology;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'trending_up':
        return Icons.trending_up;
      case 'diamond':
        return Icons.diamond;
      default:
        return Icons.star;
    }
  }

  Color get color {
    if (isUnlocked) {
      switch (category) {
        case 'streak':
          return Colors.orange;
        case 'time':
          return Colors.blue;
        case 'sessions':
          return Colors.green;
        case 'level':
          return Colors.purple;
        default:
          return Colors.amber;
      }
    }
    return Colors.grey;
  }

  static List<MeditationAchievement> getDefaultAchievements() {
    return [
      MeditationAchievement(
        id: 'first_session',
        title: 'First Steps',
        description: 'Complete your first meditation session',
        iconName: 'star',
        requiredValue: 1,
        type: AchievementType.sessions,
        rewardPoints: 10,
        category: 'sessions',
      ),
      MeditationAchievement(
        id: 'streak_3',
        title: 'Getting Started',
        description: 'Meditate for 3 days in a row',
        iconName: 'local_fire_department',
        requiredValue: 3,
        type: AchievementType.streak,
        rewardPoints: 25,
        category: 'streak',
      ),
      MeditationAchievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Meditate for 7 days in a row',
        iconName: 'local_fire_department',
        requiredValue: 7,
        type: AchievementType.streak,
        rewardPoints: 50,
        category: 'streak',
      ),
      MeditationAchievement(
        id: 'time_60',
        title: 'Hour of Peace',
        description: 'Meditate for a total of 60 minutes',
        iconName: 'timer',
        requiredValue: 60,
        type: AchievementType.totalMinutes,
        rewardPoints: 30,
        category: 'time',
      ),
      MeditationAchievement(
        id: 'sessions_10',
        title: 'Dedicated Practitioner',
        description: 'Complete 10 meditation sessions',
        iconName: 'self_improvement',
        requiredValue: 10,
        type: AchievementType.sessions,
        rewardPoints: 50,
        category: 'sessions',
      ),
      MeditationAchievement(
        id: 'sessions_5',
        title: 'Mindful Explorer',
        description: 'Complete 5 meditation sessions',
        iconName: 'psychology',
        requiredValue: 5,
        type: AchievementType.sessions,
        rewardPoints: 25,
        category: 'sessions',
      ),
      MeditationAchievement(
        id: 'time_30',
        title: 'Half Hour Hero',
        description: 'Meditate for a total of 30 minutes',
        iconName: 'timer',
        requiredValue: 30,
        type: AchievementType.totalMinutes,
        rewardPoints: 20,
        category: 'time',
      ),
      MeditationAchievement(
        id: 'level_3',
        title: 'Rising Meditator',
        description: 'Reach meditation level 3',
        iconName: 'trending_up',
        requiredValue: 3,
        type: AchievementType.level,
        rewardPoints: 40,
        category: 'level',
      ),
    ];
  }
}

@HiveType(typeId: 15)
enum AchievementType {
  @HiveField(0)
  sessions,
  @HiveField(1)
  totalMinutes,
  @HiveField(2)
  streak,
  @HiveField(3)
  level,
  @HiveField(4)
  category,
}
