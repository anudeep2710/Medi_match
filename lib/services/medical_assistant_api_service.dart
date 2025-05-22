import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:medimatch/models/health_tips.dart';

class MedicalAssistantApiService {
  static const String apiUrl = 'https://us-central1-said-eb2f5.cloudfunctions.net/gemini_medical_assistant';

  /// Converts an image file to base64 encoding
  Future<String> imageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Error converting image to base64: $e');
      throw Exception('Failed to convert image to base64: $e');
    }
  }

  /// Analyzes a prescription image using the Gemini Medical Assistant API
  Future<MedicalAssistantResponse> analyzePrescription(File imageFile) async {
    try {
      // Convert image to base64
      final base64Image = await imageToBase64(imageFile);

      // Prepare request body
      final body = jsonEncode({
        'image_base64': base64Image,
      });

      // Make API request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // Check response status
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return MedicalAssistantResponse.fromJson(jsonResponse);
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to analyze prescription: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error analyzing prescription: $e');
      throw Exception('Failed to analyze prescription: $e');
    }
  }

  /// Get comprehensive health tips for given medications
  Future<HealthTips> getHealthTips(String medications) async {
    try {
      // Since the API doesn't support text-only requests, we'll use the fallback
      // In a real implementation, you might have a separate endpoint for health tips
      debugPrint('Generating health tips for medications: $medications');
      return HealthTips.fallback(medications);
    } catch (e) {
      debugPrint('Error getting health tips: $e');
      return HealthTips.fallback(medications);
    }
  }

  /// Get health tips from image analysis (when we have prescription image)
  Future<HealthTips> getHealthTipsFromImage(File imageFile, String medications) async {
    try {
      // Convert image to base64
      final base64Image = await imageToBase64(imageFile);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image_base64': base64Image,
          'prompt': '''
Based on the medications found in this prescription: $medications

Please provide comprehensive personalized health tips and guidance including:

**1. General Health Advice:**
• Essential health recommendations for someone taking these medications
• Daily health practices and habits
• Overall wellness guidelines

**2. Dietary Considerations and Restrictions:**
• Foods to include in the diet
• Foods and drinks to avoid
• Timing of meals with medications
• Nutritional recommendations
• Food-drug interactions to be aware of

**3. Lifestyle Recommendations:**
• Exercise and physical activity guidelines
• Sleep recommendations
• Stress management techniques
• Daily routine suggestions
• Habits to develop or avoid

**4. Potential Side Effects to Watch For:**
• Common side effects that may occur
• Serious side effects requiring immediate attention
• How to monitor and track side effects
• When side effects are normal vs concerning

**5. When to Consult a Doctor:**
• Specific symptoms that require medical attention
• Emergency warning signs
• Regular follow-up recommendations
• Questions to ask your healthcare provider

**6. Tips for Medication Adherence:**
• Strategies to remember taking medications
• Organization and storage tips
• Dealing with missed doses
• Motivation and compliance strategies

Please format each section clearly with bullet points and provide specific, actionable advice.
Keep the advice evidence-based but general, and remind the user to always consult their healthcare provider for personalized medical advice.

Focus ONLY on health tips and guidance, not on medication analysis or alternatives.
''',
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseText = data['response'] ?? '';
        if (responseText.isNotEmpty) {
          return HealthTips.fromApiResponse(responseText, medications);
        } else {
          return HealthTips.fallback(medications);
        }
      } else {
        debugPrint('Health tips API error: ${response.statusCode}');
        return HealthTips.fallback(medications);
      }
    } catch (e) {
      debugPrint('Error getting health tips from image: $e');
      return HealthTips.fallback(medications);
    }
  }

  /// Get simple health tips as string (for backward compatibility)
  Future<String> getHealthTipsAsString(String medications) async {
    try {
      final healthTips = await getHealthTips(medications);
      return _formatHealthTipsAsString(healthTips);
    } catch (e) {
      debugPrint('Error getting health tips as string: $e');
      return '''
**Health Tips for Your Medications**

Based on your current medications, here are some general health recommendations:

**General Guidelines:**
• Take medications exactly as prescribed by your healthcare provider
• Maintain consistent timing for medication doses
• Keep a medication diary to track effects and side effects
• Stay hydrated and maintain a balanced diet

**Important Reminders:**
• Never stop or change medications without consulting your doctor
• Inform all healthcare providers about your current medications
• Store medications properly according to instructions
• Check expiration dates regularly

**When to Contact Your Doctor:**
• If you experience unusual side effects
• If symptoms worsen or don't improve
• Before starting any new medications or supplements
• If you have questions about your treatment plan

**Note:** This is general advice. Always consult your healthcare provider for personalized medical guidance specific to your condition and medications.
''';
    }
  }

  String _formatHealthTipsAsString(HealthTips healthTips) {
    final buffer = StringBuffer();

    buffer.writeln('**Health Tips for Your Medications: ${healthTips.medications}**\n');

    // General Health Advice
    buffer.writeln('**${healthTips.generalAdvice.title}:**');
    for (final tip in healthTips.generalAdvice.tips) {
      buffer.writeln('• $tip');
    }
    buffer.writeln();

    // Dietary Considerations
    buffer.writeln('**${healthTips.dietary.title}:**');
    if (healthTips.dietary.recommendations.isNotEmpty) {
      buffer.writeln('Recommendations:');
      for (final tip in healthTips.dietary.recommendations) {
        buffer.writeln('• $tip');
      }
    }
    if (healthTips.dietary.restrictions.isNotEmpty) {
      buffer.writeln('Restrictions:');
      for (final tip in healthTips.dietary.restrictions) {
        buffer.writeln('• $tip');
      }
    }
    buffer.writeln();

    // Lifestyle Recommendations
    buffer.writeln('**${healthTips.lifestyle.title}:**');
    for (final tip in [...healthTips.lifestyle.exercise, ...healthTips.lifestyle.sleep, ...healthTips.lifestyle.stress, ...healthTips.lifestyle.habits]) {
      buffer.writeln('• $tip');
    }
    buffer.writeln();

    // Side Effects
    buffer.writeln('**${healthTips.sideEffects.title}:**');
    for (final tip in [...healthTips.sideEffects.commonSideEffects, ...healthTips.sideEffects.seriousSideEffects, ...healthTips.sideEffects.monitoringTips]) {
      buffer.writeln('• $tip');
    }
    buffer.writeln();

    // Doctor Consultation
    buffer.writeln('**${healthTips.doctorGuidance.title}:**');
    for (final tip in [...healthTips.doctorGuidance.whenToCall, ...healthTips.doctorGuidance.emergencySignals, ...healthTips.doctorGuidance.regularCheckups]) {
      buffer.writeln('• $tip');
    }
    buffer.writeln();

    // Medication Adherence
    buffer.writeln('**${healthTips.adherence.title}:**');
    for (final tip in [...healthTips.adherence.reminders, ...healthTips.adherence.organization, ...healthTips.adherence.motivation]) {
      buffer.writeln('• $tip');
    }
    buffer.writeln();

    buffer.writeln('**Note:** This is AI-generated advice. Always consult your healthcare provider for personalized medical guidance specific to your condition and medications.');

    return buffer.toString();
  }
}

class MedicalAssistantResponse {
  final String response;

  MedicalAssistantResponse({required this.response});

  factory MedicalAssistantResponse.fromJson(Map<String, dynamic> json) {
    return MedicalAssistantResponse(
      response: json['response'] ?? '',
    );
  }

  /// Parses the response text to extract medication information
  List<MedicationAnalysis> parseMedications() {
    final List<MedicationAnalysis> medications = [];

    // Split the response by medication sections (usually starts with **)
    final sections = response.split('**');

    for (var section in sections) {
      // Skip empty sections or non-medication sections
      if (section.trim().isEmpty ||
          section.contains('Possible illness') ||
          (!section.contains('Purpose:') && !section.contains('✅ Purpose:'))) {
        continue;
      }

      // Extract medication name (first line of the section)
      final name = section.trim().split('\n').first.trim();

      // Extract purpose - try different patterns
      String purpose = '';
      final purposePatterns = [
        r'Purpose: (.+)',
        r'✅ Purpose: (.+)',
        r'Purpose:(.+)',
      ];

      for (final pattern in purposePatterns) {
        final purposeMatch = RegExp(pattern).firstMatch(section);
        if (purposeMatch != null && purposeMatch.group(1) != null) {
          purpose = purposeMatch.group(1)!.trim();
          break;
        }
      }

      // Extract pros - try different patterns
      String pros = '';
      final prosPatterns = [
        r'Pros: (.+)',
        r'➕ Pros: (.+)',
        r'Pros:(.+)',
      ];

      for (final pattern in prosPatterns) {
        final prosMatch = RegExp(pattern).firstMatch(section);
        if (prosMatch != null && prosMatch.group(1) != null) {
          pros = prosMatch.group(1)!.trim();
          break;
        }
      }

      // Extract cons - try different patterns
      String cons = '';
      final consPatterns = [
        r'Cons: (.+)',
        r'⚠️ Cons: (.+)',
        r'Cons:(.+)',
      ];

      for (final pattern in consPatterns) {
        final consMatch = RegExp(pattern).firstMatch(section);
        if (consMatch != null && consMatch.group(1) != null) {
          cons = consMatch.group(1)!.trim();
          break;
        }
      }

      // Extract alternatives
      List<MedicationAlternative> alternatives = [];

      // Low-cost alternative - try different patterns
      final lowCostPatterns = [
        r'Low-cost alternative: (.+) – ₹(\d+)',
        r'Low-cost alternative: (.+) - ₹(\d+)',
        r'Low-cost alternative:(.+)₹(\d+)',
        r'Low-cost alternative: (.+)',
      ];

      for (final pattern in lowCostPatterns) {
        final lowCostMatch = RegExp(pattern).firstMatch(section);
        if (lowCostMatch != null) {
          final name = lowCostMatch.group(1)?.trim() ?? '';
          final priceStr = lowCostMatch.group(2);
          final price = priceStr != null ? int.tryParse(priceStr) ?? 30 : 30; // Default price if not found

          // Extract buy link
          String buyLink = '';
          // Try to find a buy link for this alternative
          if (section.contains('Buy:') && section.contains('1mg.com')) {
            final buyLinkPatterns = [
              'Buy: (https://[^\\s]+)',
              'Buy:(https://[^\\s]+)',
            ];

            for (final buyPattern in buyLinkPatterns) {
              final buyLinkMatch = RegExp(buyPattern).firstMatch(section);
              if (buyLinkMatch != null && buyLinkMatch.group(1) != null) {
                buyLink = buyLinkMatch.group(1)!.trim();
                break;
              }
            }
          }

          // If no buy link found, create a generic one
          if (buyLink.isEmpty) {
            buyLink = 'https://www.1mg.com/search/all?name=${Uri.encodeComponent(name)}';
          }

          alternatives.add(MedicationAlternative(
            name: name,
            price: price,
            buyLink: buyLink,
            type: 'low-cost',
          ));
          break;
        }
      }

      // High-cost alternative - try different patterns
      final highCostPatterns = [
        r'High-cost branded alternative: (.+) – ₹(\d+)',
        r'High-cost branded alternative: (.+) - ₹(\d+)',
        r'High-cost branded alternative:(.+)₹(\d+)',
        r'High-cost branded alternative: (.+)',
        r'High-cost alternative: (.+)',
      ];

      for (final pattern in highCostPatterns) {
        final highCostMatch = RegExp(pattern).firstMatch(section);
        if (highCostMatch != null) {
          final name = highCostMatch.group(1)?.trim() ?? '';
          final priceStr = highCostMatch.group(2);
          final price = priceStr != null ? int.tryParse(priceStr) ?? 100 : 100; // Default price if not found

          // Extract buy link
          String buyLink = '';
          // Try to find a buy link for this alternative
          if (section.contains('Buy:') && section.contains('1mg.com')) {
            final buyLinkPatterns = [
              'Buy: (https://[^\\s]+)',
              'Buy:(https://[^\\s]+)',
            ];

            for (final buyPattern in buyLinkPatterns) {
              final buyLinkMatch = RegExp(buyPattern).firstMatch(section);
              if (buyLinkMatch != null && buyLinkMatch.group(1) != null) {
                buyLink = buyLinkMatch.group(1)!.trim();
                break;
              }
            }
          }

          // If no buy link found, create a generic one
          if (buyLink.isEmpty) {
            buyLink = 'https://www.1mg.com/search/all?name=${Uri.encodeComponent(name)}';
          }

          alternatives.add(MedicationAlternative(
            name: name,
            price: price,
            buyLink: buyLink,
            type: 'high-cost',
          ));
          break;
        }
      }

      // Extract original medicine buy link
      String originalBuyLink = '';
      final originalBuyLinkPatterns = [
        r'Original Medicine:\s+Buy: (https://[^\s]+)',
        r'Original Medicine:\s+Buy:(https://[^\s]+)',
        r'🌐 Original Medicine:\s+Buy: (https://[^\s]+)',
      ];

      for (final pattern in originalBuyLinkPatterns) {
        final originalBuyLinkMatch = RegExp(pattern).firstMatch(section);
        if (originalBuyLinkMatch != null && originalBuyLinkMatch.group(1) != null) {
          originalBuyLink = originalBuyLinkMatch.group(1)!.trim();
          break;
        }
      }

      // If no original buy link found, create a generic one
      if (originalBuyLink.isEmpty) {
        originalBuyLink = 'https://www.1mg.com/search/all?name=${Uri.encodeComponent(name)}';
      }

      medications.add(MedicationAnalysis(
        name: name,
        purpose: purpose,
        pros: pros,
        cons: cons,
        alternatives: alternatives,
        buyLink: originalBuyLink,
      ));
    }

    return medications;
  }

  /// Extracts the possible illness information from the response
  String extractPossibleIllness() {
    // Try different patterns to match the possible illness section
    final patterns = [
      r'Possible illness based on all medicines combined:([\s\S]+?)(?=\n\n|$)',
      r'\*\*🧠 Possible illness based on all medicines combined:\*\*([\s\S]+?)(?=\n\n|$)',
      r'Possible illness([\s\S]+?)(?=\n\n|$)'
    ];

    for (final pattern in patterns) {
      final illnessMatch = RegExp(pattern).firstMatch(response);
      if (illnessMatch != null && illnessMatch.group(1) != null) {
        return illnessMatch.group(1)!.trim();
      }
    }

    // If no match found but the text contains illness-related keywords, extract a reasonable portion
    if (response.contains('illness') || response.contains('infection') || response.contains('condition')) {
      final lines = response.split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('illness') || lines[i].contains('infection') || lines[i].contains('condition')) {
          // Return this line and up to 3 following lines
          final endIndex = i + 4 < lines.length ? i + 4 : lines.length;
          return lines.sublist(i, endIndex).join('\n').trim();
        }
      }
    }

    return '';
  }
}

class MedicationAnalysis {
  final String name;
  final String purpose;
  final String pros;
  final String cons;
  final List<MedicationAlternative> alternatives;
  final String buyLink;

  MedicationAnalysis({
    required this.name,
    required this.purpose,
    required this.pros,
    required this.cons,
    required this.alternatives,
    required this.buyLink,
  });
}

class MedicationAlternative {
  final String name;
  final int price;
  final String buyLink;
  final String type; // 'low-cost' or 'high-cost'

  MedicationAlternative({
    required this.name,
    required this.price,
    required this.buyLink,
    required this.type,
  });
}
