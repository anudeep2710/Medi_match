class HealthTips {
  final String medications;
  final GeneralHealthAdvice generalAdvice;
  final DietaryConsiderations dietary;
  final LifestyleRecommendations lifestyle;
  final SideEffectsMonitoring sideEffects;
  final DoctorConsultationGuidance doctorGuidance;
  final MedicationAdherenceTips adherence;
  final DateTime generatedAt;

  HealthTips({
    required this.medications,
    required this.generalAdvice,
    required this.dietary,
    required this.lifestyle,
    required this.sideEffects,
    required this.doctorGuidance,
    required this.adherence,
    required this.generatedAt,
  });

  factory HealthTips.fromApiResponse(String response, String medications) {
    return HealthTips(
      medications: medications,
      generalAdvice: GeneralHealthAdvice.fromResponse(response),
      dietary: DietaryConsiderations.fromResponse(response),
      lifestyle: LifestyleRecommendations.fromResponse(response),
      sideEffects: SideEffectsMonitoring.fromResponse(response),
      doctorGuidance: DoctorConsultationGuidance.fromResponse(response),
      adherence: MedicationAdherenceTips.fromResponse(response),
      generatedAt: DateTime.now(),
    );
  }

  factory HealthTips.fallback(String medications) {
    return HealthTips(
      medications: medications,
      generalAdvice: GeneralHealthAdvice.fallback(),
      dietary: DietaryConsiderations.fallback(),
      lifestyle: LifestyleRecommendations.fallback(),
      sideEffects: SideEffectsMonitoring.fallback(),
      doctorGuidance: DoctorConsultationGuidance.fallback(),
      adherence: MedicationAdherenceTips.fallback(),
      generatedAt: DateTime.now(),
    );
  }
}

class GeneralHealthAdvice {
  final String title;
  final List<String> tips;
  final String description;

  GeneralHealthAdvice({
    required this.title,
    required this.tips,
    required this.description,
  });

  factory GeneralHealthAdvice.fromResponse(String response) {
    final tips = _extractSection(response, ['General health advice', 'General Guidelines', 'General advice']);
    return GeneralHealthAdvice(
      title: 'General Health Advice',
      tips: tips,
      description: 'Essential health recommendations for your current medications',
    );
  }

  factory GeneralHealthAdvice.fallback() {
    return GeneralHealthAdvice(
      title: 'General Health Advice',
      tips: [
        'Take medications exactly as prescribed by your healthcare provider',
        'Maintain consistent timing for medication doses',
        'Keep a medication diary to track effects and side effects',
        'Stay hydrated and maintain a balanced diet',
        'Get adequate rest and sleep',
        'Follow up with your healthcare provider regularly',
      ],
      description: 'Essential health recommendations for your current medications',
    );
  }
}

class DietaryConsiderations {
  final String title;
  final List<String> recommendations;
  final List<String> restrictions;
  final List<String> interactions;

  DietaryConsiderations({
    required this.title,
    required this.recommendations,
    required this.restrictions,
    required this.interactions,
  });

  factory DietaryConsiderations.fromResponse(String response) {
    final dietary = _extractSection(response, ['dietary considerations', 'diet', 'food', 'nutrition']);
    return DietaryConsiderations(
      title: 'Dietary Considerations',
      recommendations: dietary.where((tip) => !tip.toLowerCase().contains('avoid')).toList(),
      restrictions: dietary.where((tip) => tip.toLowerCase().contains('avoid')).toList(),
      interactions: _extractSection(response, ['food interactions', 'drug interactions']),
    );
  }

  factory DietaryConsiderations.fallback() {
    return DietaryConsiderations(
      title: 'Dietary Considerations',
      recommendations: [
        'Maintain a balanced diet rich in fruits and vegetables',
        'Stay well hydrated throughout the day',
        'Take medications with food if recommended',
        'Include probiotics to support digestive health',
      ],
      restrictions: [
        'Avoid alcohol while taking medications',
        'Limit caffeine intake if it affects medication absorption',
        'Avoid grapefruit if taking certain medications',
      ],
      interactions: [
        'Check with your pharmacist about food-drug interactions',
        'Read medication labels for specific dietary instructions',
      ],
    );
  }
}

class LifestyleRecommendations {
  final String title;
  final List<String> exercise;
  final List<String> sleep;
  final List<String> stress;
  final List<String> habits;

  LifestyleRecommendations({
    required this.title,
    required this.exercise,
    required this.sleep,
    required this.stress,
    required this.habits,
  });

  factory LifestyleRecommendations.fromResponse(String response) {
    final lifestyle = _extractSection(response, ['lifestyle', 'exercise', 'activity', 'habits']);
    return LifestyleRecommendations(
      title: 'Lifestyle Recommendations',
      exercise: lifestyle.where((tip) => tip.toLowerCase().contains('exercise') || tip.toLowerCase().contains('activity')).toList(),
      sleep: lifestyle.where((tip) => tip.toLowerCase().contains('sleep') || tip.toLowerCase().contains('rest')).toList(),
      stress: lifestyle.where((tip) => tip.toLowerCase().contains('stress') || tip.toLowerCase().contains('relax')).toList(),
      habits: lifestyle.where((tip) => !tip.toLowerCase().contains('exercise') && !tip.toLowerCase().contains('sleep') && !tip.toLowerCase().contains('stress')).toList(),
    );
  }

  factory LifestyleRecommendations.fallback() {
    return LifestyleRecommendations(
      title: 'Lifestyle Recommendations',
      exercise: [
        'Engage in light to moderate exercise as approved by your doctor',
        'Take regular walks to improve circulation',
        'Avoid strenuous activities if medications cause dizziness',
      ],
      sleep: [
        'Maintain a regular sleep schedule',
        'Aim for 7-9 hours of quality sleep',
        'Create a comfortable sleep environment',
      ],
      stress: [
        'Practice stress-reduction techniques like meditation',
        'Maintain social connections and support systems',
        'Consider relaxation exercises or yoga',
      ],
      habits: [
        'Avoid smoking and limit alcohol consumption',
        'Maintain good hygiene practices',
        'Keep a consistent daily routine',
      ],
    );
  }
}

class SideEffectsMonitoring {
  final String title;
  final List<String> commonSideEffects;
  final List<String> seriousSideEffects;
  final List<String> monitoringTips;

  SideEffectsMonitoring({
    required this.title,
    required this.commonSideEffects,
    required this.seriousSideEffects,
    required this.monitoringTips,
  });

  factory SideEffectsMonitoring.fromResponse(String response) {
    final sideEffects = _extractSection(response, ['side effects', 'adverse effects', 'reactions']);
    return SideEffectsMonitoring(
      title: 'Side Effects to Monitor',
      commonSideEffects: sideEffects.where((effect) => effect.toLowerCase().contains('common') || effect.toLowerCase().contains('mild')).toList(),
      seriousSideEffects: sideEffects.where((effect) => effect.toLowerCase().contains('serious') || effect.toLowerCase().contains('severe')).toList(),
      monitoringTips: _extractSection(response, ['monitor', 'watch for', 'observe']),
    );
  }

  factory SideEffectsMonitoring.fallback() {
    return SideEffectsMonitoring(
      title: 'Side Effects to Monitor',
      commonSideEffects: [
        'Nausea or stomach upset',
        'Drowsiness or fatigue',
        'Headache',
        'Dizziness',
      ],
      seriousSideEffects: [
        'Severe allergic reactions (rash, swelling, difficulty breathing)',
        'Unusual bleeding or bruising',
        'Severe stomach pain',
        'Changes in heart rate',
      ],
      monitoringTips: [
        'Keep a symptom diary',
        'Monitor your vital signs if recommended',
        'Report any unusual symptoms to your healthcare provider',
        'Don\'t ignore persistent or worsening symptoms',
      ],
    );
  }
}

class DoctorConsultationGuidance {
  final String title;
  final List<String> whenToCall;
  final List<String> emergencySignals;
  final List<String> regularCheckups;

  DoctorConsultationGuidance({
    required this.title,
    required this.whenToCall,
    required this.emergencySignals,
    required this.regularCheckups,
  });

  factory DoctorConsultationGuidance.fromResponse(String response) {
    final guidance = _extractSection(response, ['consult', 'doctor', 'healthcare provider', 'physician']);
    return DoctorConsultationGuidance(
      title: 'When to Consult Your Doctor',
      whenToCall: guidance.where((tip) => !tip.toLowerCase().contains('emergency')).toList(),
      emergencySignals: guidance.where((tip) => tip.toLowerCase().contains('emergency') || tip.toLowerCase().contains('urgent')).toList(),
      regularCheckups: _extractSection(response, ['follow-up', 'regular', 'checkup']),
    );
  }

  factory DoctorConsultationGuidance.fallback() {
    return DoctorConsultationGuidance(
      title: 'When to Consult Your Doctor',
      whenToCall: [
        'If you experience unusual side effects',
        'If symptoms worsen or don\'t improve',
        'Before starting any new medications or supplements',
        'If you have questions about your treatment plan',
      ],
      emergencySignals: [
        'Severe allergic reactions',
        'Difficulty breathing',
        'Chest pain',
        'Severe bleeding',
      ],
      regularCheckups: [
        'Schedule regular follow-up appointments',
        'Monitor medication effectiveness',
        'Review and adjust treatment plans as needed',
      ],
    );
  }
}

class MedicationAdherenceTips {
  final String title;
  final List<String> reminders;
  final List<String> organization;
  final List<String> motivation;

  MedicationAdherenceTips({
    required this.title,
    required this.reminders,
    required this.organization,
    required this.motivation,
  });

  factory MedicationAdherenceTips.fromResponse(String response) {
    final adherence = _extractSection(response, ['adherence', 'compliance', 'taking medication', 'medication schedule']);
    return MedicationAdherenceTips(
      title: 'Medication Adherence Tips',
      reminders: adherence.where((tip) => tip.toLowerCase().contains('reminder') || tip.toLowerCase().contains('alarm')).toList(),
      organization: adherence.where((tip) => tip.toLowerCase().contains('organize') || tip.toLowerCase().contains('pill box')).toList(),
      motivation: adherence.where((tip) => !tip.toLowerCase().contains('reminder') && !tip.toLowerCase().contains('organize')).toList(),
    );
  }

  factory MedicationAdherenceTips.fallback() {
    return MedicationAdherenceTips(
      title: 'Medication Adherence Tips',
      reminders: [
        'Set daily alarms for medication times',
        'Use smartphone apps for medication reminders',
        'Link medication taking to daily routines',
      ],
      organization: [
        'Use a weekly pill organizer',
        'Keep medications in a visible location',
        'Store medications properly according to instructions',
      ],
      motivation: [
        'Understand the importance of your medications',
        'Track your progress and improvements',
        'Communicate with your healthcare team about challenges',
      ],
    );
  }
}

// Helper function to extract sections from API response
List<String> _extractSection(String response, List<String> keywords) {
  final lines = response.split('\n');
  final tips = <String>[];
  bool inSection = false;
  
  for (final line in lines) {
    final lowerLine = line.toLowerCase();
    
    // Check if we're entering a relevant section
    if (keywords.any((keyword) => lowerLine.contains(keyword.toLowerCase()))) {
      inSection = true;
      continue;
    }
    
    // Check if we're leaving the section (new section starts)
    if (inSection && line.startsWith('**') && !keywords.any((keyword) => lowerLine.contains(keyword.toLowerCase()))) {
      inSection = false;
      continue;
    }
    
    // Extract bullet points or numbered items
    if (inSection && (line.trim().startsWith('•') || line.trim().startsWith('-') || line.trim().startsWith('*') || RegExp(r'^\d+\.').hasMatch(line.trim()))) {
      final cleaned = line.trim()
          .replaceFirst(RegExp(r'^[•\-*]'), '')
          .replaceFirst(RegExp(r'^\d+\.'), '')
          .trim();
      if (cleaned.isNotEmpty) {
        tips.add(cleaned);
      }
    }
  }
  
  return tips;
}
