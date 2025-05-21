import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:medimatch/models/medicine.dart';
import 'package:medimatch/models/pharmacy.dart';
import 'package:medimatch/models/reminder.dart';

class GeminiService {
  // Note: In a real app, you would use environment variables or secure storage for API keys
  // This is just for demonstration purposes
  static const String apiKey = 'AIzaSyCfXU6O4xuHk78Zxq1wAyHXmE1PyNtV4tI';
  static const String apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  // Extract medicines from OCR text
  Future<List<Medicine>> extractMedicines(String ocrText) async {
    final prompt = '''
    Task: Extract medicine names with dosage from the prescription text.
    OCR Text: $ocrText
    Output JSON format:
    [
      { "name": "Medicine Name", "dosage": "Dosage", "instructions": "Instructions" }
    ]
    Return ONLY the JSON array without any markdown formatting or additional text.
    ''';

    final response = await _callGeminiApi(prompt);
    final cleanedJson = _extractJsonFromResponse(response);

    try {
      if (cleanedJson.isEmpty) {
        debugPrint('No valid JSON found in response');
        return [];
      }

      final List<dynamic> medicinesJson = jsonDecode(cleanedJson);
      return medicinesJson.map((json) => Medicine.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error parsing medicines: $e');
      debugPrint('Response was: $response');
      debugPrint('Cleaned JSON was: $cleanedJson');
      return [];
    }
  }

  // Helper method to extract JSON from Gemini response
  String _extractJsonFromResponse(String response) {
    // Remove markdown code blocks if present
    if (response.contains('```json')) {
      final startIndex = response.indexOf('```json') + 7;
      final endIndex = response.lastIndexOf('```');
      if (endIndex > startIndex) {
        return response.substring(startIndex, endIndex).trim();
      }
    }

    // If no markdown, try to find JSON array directly
    final startBracket = response.indexOf('[');
    final endBracket = response.lastIndexOf(']');
    if (startBracket >= 0 && endBracket > startBracket) {
      return response.substring(startBracket, endBracket + 1).trim();
    }

    // Return original if no JSON structure found
    return response;
  }

  // Suggest generic alternatives
  Future<List<Map<String, dynamic>>> suggestAlternatives(
    List<String> medicineNames,
  ) async {
    final prompt = '''
    Task: For each brand, suggest a cheaper generic.
    Input: ${jsonEncode(medicineNames)}
    Output JSON format:
    [
      { "brand": "Brand Name", "generic": "Generic Name", "savings": "₹XX", "effectiveness": "Same/Similar/Lower" }
    ]
    Return ONLY the JSON array without any markdown formatting or additional text.
    ''';

    final response = await _callGeminiApi(prompt);
    final cleanedJson = _extractJsonFromResponse(response);

    try {
      if (cleanedJson.isEmpty) {
        debugPrint('No valid JSON found in response');
        return [];
      }

      return List<Map<String, dynamic>>.from(jsonDecode(cleanedJson));
    } catch (e) {
      debugPrint('Error parsing alternatives: $e');
      debugPrint('Response was: $response');
      return [];
    }
  }

  // Check for drug interactions
  Future<String> checkDrugInteractions(List<String> medicineNames) async {
    final prompt = '''
    Task: Check for risky interactions between these medicines.
    Medicines: ${medicineNames.join(', ')}
    Output: A clear explanation of any potential interactions, or "No known interactions" if none exist.
    ''';

    return await _callGeminiApi(prompt);
  }

  // Generate prescription reminders
  Future<List<Reminder>> generateReminders(List<Medicine> medicines) async {
    final prompt = '''
    Task: Create a user-friendly medicine reminder schedule.
    Medicines: ${jsonEncode(medicines.map((m) => m.toJson()).toList())}
    Output JSON format:
    [
      { "id": "unique_id", "medicineName": "Medicine Name", "time": "8:00 AM", "note": "After food", "daysOfWeek": [1,2,3,4,5,6,7] }
    ]
    Return ONLY the JSON array without any markdown formatting or additional text.
    ''';

    final response = await _callGeminiApi(prompt);
    final cleanedJson = _extractJsonFromResponse(response);

    try {
      if (cleanedJson.isEmpty) {
        debugPrint('No valid JSON found in response');
        return [];
      }

      final List<dynamic> remindersJson = jsonDecode(cleanedJson);
      return remindersJson.map((json) => Reminder.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error parsing reminders: $e');
      debugPrint('Response was: $response');
      return [];
    }
  }

  // Explain medicine instructions
  Future<String> explainInstructions(String medicineInstruction) async {
    final prompt = '''
    Task: Convert technical instructions into simple, friendly explanation.
    Input: "$medicineInstruction"
    Output: A clear, simple explanation that a non-medical person can understand.
    ''';

    return await _callGeminiApi(prompt);
  }

  // Translate text to selected language
  Future<String> translateText(String text, String targetLanguage) async {
    final prompt = '''
    Task: Translate the following text into $targetLanguage.
    Text: "$text"
    Output: The translated text only.
    ''';

    return await _callGeminiApi(prompt);
  }

  // Find nearby pharmacies
  Future<List<Pharmacy>> findNearbyPharmacies(
    double latitude,
    double longitude,
  ) async {
    final prompt = '''
    Task: Help the user find the nearest pharmacy.
    Location: lat: $latitude, lon: $longitude
    Output JSON format:
    [
      { "name": "Pharmacy Name", "distance": "X.X km", "openNow": true/false, "contact": "Phone Number" }
    ]
    Return ONLY the JSON array without any markdown formatting or additional text.
    ''';

    final response = await _callGeminiApi(prompt);
    final cleanedJson = _extractJsonFromResponse(response);

    try {
      if (cleanedJson.isEmpty) {
        debugPrint('No valid JSON found in response');
        return [];
      }

      final List<dynamic> pharmaciesJson = jsonDecode(cleanedJson);
      return pharmaciesJson.map((json) => Pharmacy.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error parsing pharmacies: $e');
      debugPrint('Response was: $response');
      return [];
    }
  }

  // Private method to call Gemini API
  Future<String> _callGeminiApi(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.2,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get response from Gemini API');
      }
    } catch (e) {
      debugPrint('Error calling Gemini API: $e');
      throw Exception('Failed to communicate with Gemini API');
    }
  }
}
