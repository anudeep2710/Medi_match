import 'package:flutter/material.dart';
import 'package:medimatch/models/health_tips.dart';

class HealthTipsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> tips;
  final String? description;
  final bool isExpanded;
  final VoidCallback? onTap;

  const HealthTipsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.tips,
    this.description,
    this.isExpanded = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey.shade600,
                    ),
                ],
              ),
              if (isExpanded && tips.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tip,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GeneralHealthAdviceCard extends StatelessWidget {
  final GeneralHealthAdvice advice;
  final bool isExpanded;
  final VoidCallback? onTap;

  const GeneralHealthAdviceCard({
    super.key,
    required this.advice,
    this.isExpanded = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HealthTipsCard(
      title: advice.title,
      icon: Icons.health_and_safety_rounded,
      color: Colors.green,
      tips: advice.tips,
      description: advice.description,
      isExpanded: isExpanded,
      onTap: onTap,
    );
  }
}

class DietaryConsiderationsCard extends StatelessWidget {
  final DietaryConsiderations dietary;
  final bool isExpanded;
  final VoidCallback? onTap;

  const DietaryConsiderationsCard({
    super.key,
    required this.dietary,
    this.isExpanded = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final allTips = [
      if (dietary.recommendations.isNotEmpty) ...[
        '📋 Recommendations:',
        ...dietary.recommendations,
      ],
      if (dietary.restrictions.isNotEmpty) ...[
        '⚠️ Restrictions:',
        ...dietary.restrictions,
      ],
      if (dietary.interactions.isNotEmpty) ...[
        '🔄 Interactions:',
        ...dietary.interactions,
      ],
    ];

    return HealthTipsCard(
      title: dietary.title,
      icon: Icons.restaurant_rounded,
      color: Colors.orange,
      tips: allTips,
      description: 'Important dietary guidelines for your medications',
      isExpanded: isExpanded,
      onTap: onTap,
    );
  }
}

class LifestyleRecommendationsCard extends StatelessWidget {
  final LifestyleRecommendations lifestyle;
  final bool isExpanded;
  final VoidCallback? onTap;

  const LifestyleRecommendationsCard({
    super.key,
    required this.lifestyle,
    this.isExpanded = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final allTips = [
      if (lifestyle.exercise.isNotEmpty) ...[
        '🏃‍♂️ Exercise & Activity:',
        ...lifestyle.exercise,
      ],
      if (lifestyle.sleep.isNotEmpty) ...[
        '😴 Sleep & Rest:',
        ...lifestyle.sleep,
      ],
      if (lifestyle.stress.isNotEmpty) ...[
        '🧘‍♀️ Stress Management:',
        ...lifestyle.stress,
      ],
      if (lifestyle.habits.isNotEmpty) ...[
        '🔄 Daily Habits:',
        ...lifestyle.habits,
      ],
    ];

    return HealthTipsCard(
      title: lifestyle.title,
      icon: Icons.fitness_center_rounded,
      color: Colors.blue,
      tips: allTips,
      description: 'Lifestyle adjustments to support your treatment',
      isExpanded: isExpanded,
      onTap: onTap,
    );
  }
}

class SideEffectsMonitoringCard extends StatelessWidget {
  final SideEffectsMonitoring sideEffects;
  final bool isExpanded;
  final VoidCallback? onTap;

  const SideEffectsMonitoringCard({
    super.key,
    required this.sideEffects,
    this.isExpanded = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final allTips = [
      if (sideEffects.commonSideEffects.isNotEmpty) ...[
        '⚡ Common Side Effects:',
        ...sideEffects.commonSideEffects,
      ],
      if (sideEffects.seriousSideEffects.isNotEmpty) ...[
        '🚨 Serious Side Effects:',
        ...sideEffects.seriousSideEffects,
      ],
      if (sideEffects.monitoringTips.isNotEmpty) ...[
        '👁️ Monitoring Tips:',
        ...sideEffects.monitoringTips,
      ],
    ];

    return HealthTipsCard(
      title: sideEffects.title,
      icon: Icons.monitor_heart_rounded,
      color: Colors.red,
      tips: allTips,
      description: 'Important side effects to watch for',
      isExpanded: isExpanded,
      onTap: onTap,
    );
  }
}

class DoctorConsultationCard extends StatelessWidget {
  final DoctorConsultationGuidance guidance;
  final bool isExpanded;
  final VoidCallback? onTap;

  const DoctorConsultationCard({
    super.key,
    required this.guidance,
    this.isExpanded = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final allTips = [
      if (guidance.whenToCall.isNotEmpty) ...[
        '📞 When to Call:',
        ...guidance.whenToCall,
      ],
      if (guidance.emergencySignals.isNotEmpty) ...[
        '🚨 Emergency Signals:',
        ...guidance.emergencySignals,
      ],
      if (guidance.regularCheckups.isNotEmpty) ...[
        '📅 Regular Checkups:',
        ...guidance.regularCheckups,
      ],
    ];

    return HealthTipsCard(
      title: guidance.title,
      icon: Icons.medical_services_rounded,
      color: Colors.purple,
      tips: allTips,
      description: 'Know when to seek medical attention',
      isExpanded: isExpanded,
      onTap: onTap,
    );
  }
}

class MedicationAdherenceCard extends StatelessWidget {
  final MedicationAdherenceTips adherence;
  final bool isExpanded;
  final VoidCallback? onTap;

  const MedicationAdherenceCard({
    super.key,
    required this.adherence,
    this.isExpanded = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final allTips = [
      if (adherence.reminders.isNotEmpty) ...[
        '⏰ Reminders:',
        ...adherence.reminders,
      ],
      if (adherence.organization.isNotEmpty) ...[
        '📦 Organization:',
        ...adherence.organization,
      ],
      if (adherence.motivation.isNotEmpty) ...[
        '💪 Motivation:',
        ...adherence.motivation,
      ],
    ];

    return HealthTipsCard(
      title: adherence.title,
      icon: Icons.schedule_rounded,
      color: Colors.teal,
      tips: allTips,
      description: 'Stay consistent with your medication routine',
      isExpanded: isExpanded,
      onTap: onTap,
    );
  }
}
