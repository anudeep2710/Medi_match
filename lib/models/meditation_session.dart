import 'package:hive/hive.dart';

part 'meditation_session.g.dart';

@HiveType(typeId: 10)
class MeditationSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  int durationMinutes;

  @HiveField(4)
  MeditationType type;

  @HiveField(5)
  String? audioUrl;

  @HiveField(6)
  String? imageUrl;

  @HiveField(7)
  MeditationLevel level;

  @HiveField(8)
  List<String> tags;

  @HiveField(9)
  String? instructions;

  @HiveField(10)
  bool isCompleted;

  @HiveField(11)
  DateTime? completedAt;

  @HiveField(12)
  int rewardPoints;

  MeditationSession({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.type,
    this.audioUrl,
    this.imageUrl,
    required this.level,
    required this.tags,
    this.instructions,
    this.isCompleted = false,
    this.completedAt,
    this.rewardPoints = 0,
  });

  factory MeditationSession.fromJson(Map<String, dynamic> json) {
    return MeditationSession(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      durationMinutes: json['durationMinutes'],
      type: MeditationType.values[json['type']],
      audioUrl: json['audioUrl'],
      imageUrl: json['imageUrl'],
      level: MeditationLevel.values[json['level']],
      tags: List<String>.from(json['tags']),
      instructions: json['instructions'],
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      rewardPoints: json['rewardPoints'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'durationMinutes': durationMinutes,
      'type': type.index,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'level': level.index,
      'tags': tags,
      'instructions': instructions,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'rewardPoints': rewardPoints,
    };
  }
}

@HiveType(typeId: 11)
enum MeditationType {
  @HiveField(0)
  guided,
  @HiveField(1)
  breathing,
  @HiveField(2)
  mindfulness,
  @HiveField(3)
  sleep,
  @HiveField(4)
  focus,
  @HiveField(5)
  anxiety,
  @HiveField(6)
  stress,
  @HiveField(7)
  gratitude,
  @HiveField(8)
  bodyScanning,
  @HiveField(9)
  visualization,
}

@HiveType(typeId: 12)
enum MeditationLevel {
  @HiveField(0)
  beginner,
  @HiveField(1)
  intermediate,
  @HiveField(2)
  advanced,
}

@HiveType(typeId: 13)
class MeditationProgress extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  int totalSessions;

  @HiveField(2)
  int totalMinutes;

  @HiveField(3)
  int currentStreak;

  @HiveField(4)
  int longestStreak;

  @HiveField(5)
  DateTime? lastSessionDate;

  @HiveField(6)
  int totalRewardPoints;

  @HiveField(7)
  List<String> completedSessionIds;

  @HiveField(8)
  Map<String, int> categoryProgress; // category -> minutes

  @HiveField(9)
  List<DateTime> sessionDates;

  @HiveField(10)
  int level;

  @HiveField(11)
  List<String> unlockedAchievements;

  MeditationProgress({
    required this.userId,
    this.totalSessions = 0,
    this.totalMinutes = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastSessionDate,
    this.totalRewardPoints = 0,
    List<String>? completedSessionIds,
    Map<String, int>? categoryProgress,
    List<DateTime>? sessionDates,
    this.level = 1,
    List<String>? unlockedAchievements,
  }) : completedSessionIds = completedSessionIds ?? [],
       categoryProgress = categoryProgress ?? {},
       sessionDates = sessionDates ?? [],
       unlockedAchievements = unlockedAchievements ?? [];

  void addCompletedSession(MeditationSession session) {
    if (!completedSessionIds.contains(session.id)) {
      completedSessionIds.add(session.id);
      totalSessions++;
      totalMinutes += session.durationMinutes;
      totalRewardPoints += session.rewardPoints;
      
      // Update category progress
      String category = session.type.toString().split('.').last;
      categoryProgress[category] = (categoryProgress[category] ?? 0) + session.durationMinutes;
      
      // Update streak
      DateTime today = DateTime.now();
      DateTime todayDate = DateTime(today.year, today.month, today.day);
      
      if (lastSessionDate == null || 
          !sessionDates.any((date) => 
            DateTime(date.year, date.month, date.day) == todayDate)) {
        sessionDates.add(today);
        
        if (lastSessionDate != null) {
          DateTime lastDate = DateTime(
            lastSessionDate!.year, 
            lastSessionDate!.month, 
            lastSessionDate!.day
          );
          DateTime yesterday = todayDate.subtract(const Duration(days: 1));
          
          if (lastDate == yesterday) {
            currentStreak++;
          } else if (lastDate != todayDate) {
            currentStreak = 1;
          }
        } else {
          currentStreak = 1;
        }
        
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      }
      
      lastSessionDate = today;
      
      // Update level based on total minutes
      int newLevel = (totalMinutes / 60).floor() + 1;
      if (newLevel > level) {
        level = newLevel;
      }
    }
  }

  double get progressToNextLevel {
    int minutesForCurrentLevel = (level - 1) * 60;
    int minutesForNextLevel = level * 60;
    int progressMinutes = totalMinutes - minutesForCurrentLevel;
    return progressMinutes / 60.0;
  }
}
