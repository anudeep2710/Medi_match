import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medimatch/providers/meditation_provider.dart';

class MeditationProgressScreen extends StatelessWidget {
  const MeditationProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation Progress'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<MeditationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final progress = provider.progress;
          if (progress == null) {
            return const Center(child: Text('No progress data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level Progress Card
                _buildLevelProgressCard(context, progress),

                const SizedBox(height: 24),

                // Stats Grid
                _buildStatsGrid(context, progress),

                const SizedBox(height: 24),

                // Achievements Section
                const Text(
                  'Achievements',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildAchievementsSection(context, provider),

                const SizedBox(height: 24),

                // Recent Sessions
                const Text(
                  'Recent Sessions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildRecentSessions(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelProgressCard(BuildContext context, progress) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  child: Text(
                    '${progress.level}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level ${progress.level}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${progress.totalRewardPoints} total points',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress.progressToNextLevel.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'Progress to Level ${progress.level + 1}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, progress) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'Total Sessions',
          progress.totalSessions.toString(),
          Icons.self_improvement,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Minutes',
          progress.totalMinutes.toString(),
          Icons.timer,
          Colors.green,
        ),
        _buildStatCard(
          'Current Streak',
          '${progress.currentStreak} days',
          Icons.local_fire_department,
          Colors.orange,
        ),
        _buildStatCard(
          'Longest Streak',
          '${progress.longestStreak} days',
          Icons.emoji_events,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context, provider) {
    final unlockedAchievements = provider.unlockedAchievements;
    final lockedAchievements = provider.achievements
        .where((a) => !a.isUnlocked)
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (unlockedAchievements.isNotEmpty) ...[
          const Text(
            'Unlocked',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...unlockedAchievements.map((achievement) => Card(
            color: Colors.amber.withOpacity(0.1),
            child: ListTile(
              leading: Icon(
                achievement.icon,
                color: Colors.amber,
              ),
              title: Text(achievement.title),
              subtitle: Text(achievement.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+${achievement.rewardPoints}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),
          )),
          const SizedBox(height: 16),
        ],

        if (lockedAchievements.isNotEmpty) ...[
          const Text(
            'Next Goals',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...lockedAchievements.map((achievement) => Card(
            child: ListTile(
              leading: Icon(
                achievement.icon,
                color: Colors.grey,
              ),
              title: Text(achievement.title),
              subtitle: Text(achievement.description),
              trailing: Text(
                '${achievement.rewardPoints} pts',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildRecentSessions(BuildContext context, provider) {
    final completedSessions = provider.completedSessions.take(5).toList();

    if (completedSessions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.self_improvement, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No completed sessions yet.\nStart your first meditation!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: completedSessions.map((session) => Card(
        child: ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: Text(session.title),
          subtitle: Text('${session.durationMinutes} minutes'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '+${session.rewardPoints}',
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}
