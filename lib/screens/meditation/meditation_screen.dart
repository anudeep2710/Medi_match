import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medimatch/models/meditation_session.dart';
import 'package:medimatch/providers/meditation_provider.dart';
import 'package:medimatch/screens/meditation/meditation_timer_screen.dart';
import 'package:medimatch/screens/meditation/meditation_progress_screen.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MeditationProgressScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 0
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'Sessions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedTabIndex == 0
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 1
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'Progress',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedTabIndex == 1
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildSessionsTab()
                : _buildProgressTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsTab() {
    return Consumer<MeditationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Summary Card
              if (provider.progress != null) _buildProgressSummaryCard(provider),

              const SizedBox(height: 24),

              // Quick Start Section
              const Text(
                'Quick Start',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildQuickStartGrid(provider),

              const SizedBox(height: 24),

              // All Sessions
              const Text(
                'All Sessions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...provider.sessions.map((session) => _buildSessionCard(session)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressSummaryCard(MeditationProvider provider) {
    final progress = provider.progress!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.self_improvement, size: 32, color: Colors.teal),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level ${progress.level}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${progress.totalRewardPoints} points earned',
                        style: const TextStyle(color: Colors.amber),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Sessions', progress.totalSessions.toString()),
                _buildStatItem('Minutes', progress.totalMinutes.toString()),
                _buildStatItem('Streak', '${progress.currentStreak} days'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildQuickStartGrid(MeditationProvider provider) {
    final quickSessions = provider.sessions.take(4).toList();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: quickSessions.length,
      itemBuilder: (context, index) {
        final session = quickSessions[index];
        return _buildQuickSessionCard(session);
      },
    );
  }

  Widget _buildQuickSessionCard(MeditationSession session) {
    return Card(
      child: InkWell(
        onTap: () => _startSession(session),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getSessionIcon(session.type),
                size: 32,
                color: _getSessionColor(session.type),
              ),
              const SizedBox(height: 8),
              Text(
                session.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${session.durationMinutes} min',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard(MeditationSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getSessionColor(session.type).withOpacity(0.2),
          child: Icon(
            _getSessionIcon(session.type),
            color: _getSessionColor(session.type),
          ),
        ),
        title: Text(session.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${session.durationMinutes} min'),
                const SizedBox(width: 16),
                Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${session.rewardPoints} pts'),
              ],
            ),
          ],
        ),
        trailing: session.isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.play_circle_outline),
        onTap: () => _startSession(session),
      ),
    );
  }

  Widget _buildProgressTab() {
    return Consumer<MeditationProvider>(
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
              // Achievements
              const Text(
                'Achievements',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...provider.achievements.map((achievement) => Card(
                child: ListTile(
                  leading: Icon(
                    achievement.icon,
                    color: achievement.isUnlocked ? Colors.amber : Colors.grey,
                  ),
                  title: Text(achievement.title),
                  subtitle: Text(achievement.description),
                  trailing: achievement.isUnlocked
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : Text('${achievement.rewardPoints} pts'),
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  void _startSession(MeditationSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeditationTimerScreen(session: session),
      ),
    );
  }

  IconData _getSessionIcon(MeditationType type) {
    switch (type) {
      case MeditationType.breathing:
        return Icons.air;
      case MeditationType.mindfulness:
        return Icons.psychology;
      case MeditationType.stress:
        return Icons.healing;
      case MeditationType.focus:
        return Icons.center_focus_strong;
      case MeditationType.sleep:
        return Icons.bedtime;
      case MeditationType.gratitude:
        return Icons.favorite;
      default:
        return Icons.self_improvement;
    }
  }

  Color _getSessionColor(MeditationType type) {
    switch (type) {
      case MeditationType.breathing:
        return Colors.blue;
      case MeditationType.mindfulness:
        return Colors.purple;
      case MeditationType.stress:
        return Colors.green;
      case MeditationType.focus:
        return Colors.orange;
      case MeditationType.sleep:
        return Colors.indigo;
      case MeditationType.gratitude:
        return Colors.pink;
      default:
        return Colors.teal;
    }
  }
}
