import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medimatch/models/meditation_session.dart';
import 'package:medimatch/providers/meditation_provider.dart';

class MeditationTimerScreen extends StatefulWidget {
  final MeditationSession session;

  const MeditationTimerScreen({super.key, required this.session});

  @override
  State<MeditationTimerScreen> createState() => _MeditationTimerScreenState();
}

class _MeditationTimerScreenState extends State<MeditationTimerScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  late AnimationController _breathingController;
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.session.durationMinutes * 60;

    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    if (widget.session.type == MeditationType.breathing) {
      _breathingController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _rippleController.repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeSession();
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
      _isRunning = false;
    });
    _timer?.cancel();
    _rippleController.stop();
  }

  void _resumeTimer() {
    _startTimer();
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = widget.session.durationMinutes * 60;
    });
    _timer?.cancel();
    _rippleController.stop();
  }

  void _completeSession() {
    _timer?.cancel();
    _rippleController.stop();

    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    // Mark session as completed
    Provider.of<MeditationProvider>(context, listen: false)
        .completeSession(widget.session.id);

    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    final provider = Provider.of<MeditationProvider>(context, listen: false);
    final progress = provider.progress;
    final newAchievements = provider.achievements
        .where((a) => a.isUnlocked &&
               a.unlockedAt != null &&
               DateTime.now().difference(a.unlockedAt!).inSeconds < 5)
        .toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Meditation Complete!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Congratulations! You completed "${widget.session.title}"',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Rewards Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '+${widget.session.rewardPoints} Points',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    if (progress != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Total: ${progress.totalRewardPoints} points',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Level ${progress.level}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // New Achievements
              if (newAchievements.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_events, color: Colors.purple, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'New Achievement!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...newAchievements.map((achievement) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(achievement.icon, color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                achievement.title,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              '+${achievement.rewardPoints}',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Motivational Message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getMotivationalMessage(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Reset timer for another session
                    setState(() {
                      _remainingSeconds = widget.session.durationMinutes * 60;
                      _isRunning = false;
                      _isPaused = false;
                    });
                  },
                  child: const Text('Meditate Again'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage() {
    final messages = [
      "Great job! You're building a healthy habit.",
      "Mindfulness is a journey, not a destination.",
      "Every moment of meditation counts.",
      "You're investing in your mental well-being.",
      "Consistency is key to mindfulness.",
      "Your mind is becoming calmer and clearer.",
      "Well done! Keep up the great work.",
      "You're on the path to inner peace.",
    ];
    return messages[DateTime.now().millisecond % messages.length];
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _remainingSeconds / (widget.session.durationMinutes * 60);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.session.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Session Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        widget.session.title,
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.session.description,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      if (widget.session.instructions != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.session.instructions!,
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Timer Circle
              Stack(
                alignment: Alignment.center,
                children: [
                  // Progress circle
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CircularProgressIndicator(
                      value: 1 - progress,
                      strokeWidth: 8,
                      backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),

                  // Timer text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(_remainingSeconds),
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isRunning ? 'Meditating...' :
                        _isPaused ? 'Paused' : 'Ready to start',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!_isRunning && !_isPaused)
                    FloatingActionButton.extended(
                      onPressed: _startTimer,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                      backgroundColor: theme.colorScheme.primary,
                    ),

                  if (_isRunning)
                    FloatingActionButton(
                      onPressed: _pauseTimer,
                      backgroundColor: theme.colorScheme.secondary,
                      child: const Icon(Icons.pause),
                    ),

                  if (_isPaused) ...[
                    FloatingActionButton(
                      onPressed: _resumeTimer,
                      backgroundColor: theme.colorScheme.primary,
                      child: const Icon(Icons.play_arrow),
                    ),
                    const SizedBox(width: 16),
                    FloatingActionButton(
                      onPressed: _stopTimer,
                      backgroundColor: theme.colorScheme.error,
                      child: const Icon(Icons.stop),
                    ),
                  ],

                  if (_isRunning || _isPaused)
                    FloatingActionButton(
                      onPressed: _stopTimer,
                      backgroundColor: theme.colorScheme.outline,
                      child: const Icon(Icons.stop),
                    ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
