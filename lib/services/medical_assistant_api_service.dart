import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
