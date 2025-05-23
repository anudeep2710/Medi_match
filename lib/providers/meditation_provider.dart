import 'package:flutter/material.dart';
import 'package:medimatch/models/meditation_session.dart';
import 'package:medimatch/models/meditation_achievement.dart';
import 'package:medimatch/services/hive_service.dart';

class MeditationProvider extends ChangeNotifier {
  final HiveService _hiveService;

  List<MeditationSession> _sessions = [];
  List<MeditationAchievement> _achievements = [];
  MeditationProgress? _progress;
  bool _isLoading = false;

  MeditationProvider(this._hiveService) {
    _initializeData();
  }

  // Getters
  List<MeditationSession> get sessions => _sessions;
  List<MeditationAchievement> get achievements => _achievements;
  MeditationProgress? get progress => _progress;
  bool get isLoading => _isLoading;

  List<MeditationSession> get completedSessions =>
      _sessions.where((session) => session.isCompleted).toList();

  List<MeditationSession> get availableSessions =>
      _sessions.where((session) => !session.isCompleted).toList();

  List<MeditationAchievement> get unlockedAchievements =>
      _achievements.where((achievement) => achievement.isUnlocked).toList();

  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load progress
      _progress = await _hiveService.getMeditationProgress('default_user');
      _progress ??= MeditationProgress(userId: 'default_user');

      // Load achievements
      _achievements = await _hiveService.getMeditationAchievements();
      if (_achievements.isEmpty) {
        _achievements = MeditationAchievement.getDefaultAchievements();
        await _hiveService.saveMeditationAchievements(_achievements);
      }

      // Load sessions
      _sessions = await _hiveService.getMeditationSessions();
      if (_sessions.isEmpty) {
        _sessions = _getDefaultSessions();
        await _hiveService.saveMeditationSessions(_sessions);
      }

      _checkAchievements();
    } catch (e) {
      debugPrint('Error initializing meditation data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<MeditationSession> _getDefaultSessions() {
    return [
      MeditationSession(
        id: 'breathing_basic',
        title: 'Basic Breathing',
        description: 'Learn the fundamentals of mindful breathing',
        durationMinutes: 5,
        type: MeditationType.breathing,
        level: MeditationLevel.beginner,
        tags: ['breathing', 'beginner', 'relaxation'],
        instructions: 'Sit comfortably and focus on your breath. Breathe in for 4 counts, hold for 4, breathe out for 4.',
        rewardPoints: 10,
      ),
      MeditationSession(
        id: 'mindfulness_intro',
        title: 'Introduction to Mindfulness',
        description: 'Discover the basics of mindful awareness',
        durationMinutes: 10,
        type: MeditationType.mindfulness,
        level: MeditationLevel.beginner,
        tags: ['mindfulness', 'awareness', 'beginner'],
        instructions: 'Focus on the present moment. Notice your thoughts without judgment.',
        rewardPoints: 15,
      ),
      MeditationSession(
        id: 'stress_relief',
        title: 'Stress Relief',
        description: 'Release tension and find calm',
        durationMinutes: 15,
        type: MeditationType.stress,
        level: MeditationLevel.intermediate,
        tags: ['stress', 'relief', 'calm'],
        instructions: 'Progressive muscle relaxation combined with deep breathing.',
        rewardPoints: 20,
      ),
      MeditationSession(
        id: 'focus_boost',
        title: 'Focus Booster',
        description: 'Enhance your concentration and mental clarity',
        durationMinutes: 12,
        type: MeditationType.focus,
        level: MeditationLevel.intermediate,
        tags: ['focus', 'concentration', 'clarity'],
        instructions: 'Single-pointed focus meditation on a chosen object.',
        rewardPoints: 18,
      ),
      MeditationSession(
        id: 'sleep_preparation',
        title: 'Sleep Preparation',
        description: 'Prepare your mind and body for restful sleep',
        durationMinutes: 20,
        type: MeditationType.sleep,
        level: MeditationLevel.beginner,
        tags: ['sleep', 'relaxation', 'bedtime'],
        instructions: 'Body scan meditation to release tension and prepare for sleep.',
        rewardPoints: 25,
      ),
      MeditationSession(
        id: 'gratitude_practice',
        title: 'Gratitude Practice',
        description: 'Cultivate appreciation and positive emotions',
        durationMinutes: 8,
        type: MeditationType.gratitude,
        level: MeditationLevel.beginner,
        tags: ['gratitude', 'positivity', 'appreciation'],
        instructions: 'Reflect on things you are grateful for in your life.',
        rewardPoints: 12,
      ),
    ];
  }

  Future<void> completeSession(String sessionId) async {
    try {
      final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex != -1 && !_sessions[sessionIndex].isCompleted) {
        _sessions[sessionIndex].isCompleted = true;
        _sessions[sessionIndex].completedAt = DateTime.now();

        // Update progress
        _progress!.addCompletedSession(_sessions[sessionIndex]);

        // Save data
        await _hiveService.saveMeditationSessions(_sessions);
        await _hiveService.saveMeditationProgress(_progress!);

        // Check for new achievements
        _checkAchievements();

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error completing session: $e');
    }
  }

  void _checkAchievements() {
    if (_progress == null) return;

    bool hasNewAchievements = false;

    for (var achievement in _achievements) {
      if (!achievement.isUnlocked) {
        bool shouldUnlock = false;

        switch (achievement.type) {
          case AchievementType.sessions:
            shouldUnlock = _progress!.totalSessions >= achievement.requiredValue;
            break;
          case AchievementType.totalMinutes:
            shouldUnlock = _progress!.totalMinutes >= achievement.requiredValue;
            break;
          case AchievementType.streak:
            shouldUnlock = _progress!.currentStreak >= achievement.requiredValue;
            break;
          case AchievementType.level:
            shouldUnlock = _progress!.level >= achievement.requiredValue;
            break;
          case AchievementType.category:
            shouldUnlock = false; // Not implemented yet
            break;
        }

        if (shouldUnlock) {
          achievement.isUnlocked = true;
          achievement.unlockedAt = DateTime.now();
          _progress!.totalRewardPoints += achievement.rewardPoints;
          _progress!.unlockedAchievements.add(achievement.id);
          hasNewAchievements = true;
        }
      }
    }

    if (hasNewAchievements) {
      _hiveService.saveMeditationAchievements(_achievements);
      _hiveService.saveMeditationProgress(_progress!);
    }
  }

  List<MeditationSession> getSessionsByType(MeditationType type) {
    return _sessions.where((session) => session.type == type).toList();
  }

  List<MeditationSession> getSessionsByLevel(MeditationLevel level) {
    return _sessions.where((session) => session.level == level).toList();
  }

  Future<void> resetProgress() async {
    _progress = MeditationProgress(userId: 'default_user');
    for (var session in _sessions) {
      session.isCompleted = false;
      session.completedAt = null;
    }
    for (var achievement in _achievements) {
      achievement.isUnlocked = false;
      achievement.unlockedAt = null;
    }

    await _hiveService.saveMeditationProgress(_progress!);
    await _hiveService.saveMeditationSessions(_sessions);
    await _hiveService.saveMeditationAchievements(_achievements);

    notifyListeners();
  }
}
