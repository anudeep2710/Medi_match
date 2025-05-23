import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Gemini Vision API service for medicine expiry verification
class GeminiVisionService {
  static const String _apiKey = 'AIzaSyDtJcQfikjvgpYYWEYOO777fgtuGn2Oudw';
  static const String _model = 'gemma-3-27b-it';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  /// Analyze medicine image for expiry date verification
  Future<MedicineVerificationResult> analyzeMedicineImage(File imageFile) async {
    try {
      print('🔍 Starting medicine image analysis...');
      
      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      // Prepare the request
      final url = '$_baseUrl/$_model:generateContent?key=$_apiKey';
      
      final requestBody = {
        "contents": [
          {
            "parts": [
              {
                "text": """
Analyze this medicine package/bottle image and extract the following information:

1. Medicine name (brand name and generic name if visible)
2. Expiry date (look for "EXP", "EXPIRY", "USE BY", "BEST BEFORE")
3. Manufacturing date (look for "MFG", "MFD", "MANUFACTURED")
4. Batch number (look for "BATCH", "LOT", "B.NO")
5. Manufacturer name

Please return ONLY a JSON response in this exact format:
{
  "medicine_name": "extracted medicine name",
  "expiry_date": "DD/MM/YYYY",
  "manufacturing_date": "DD/MM/YYYY", 
  "batch_number": "extracted batch number",
  "manufacturer": "manufacturer name",
  "is_expired": false,
  "confidence": 0.95,
  "error": null
}

If you cannot find any information, set the field to null.
If the image is unclear or not a medicine package, set error to "Unable to analyze image".
"""
              },
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image
                }
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.1,
          "topK": 1,
          "topP": 1,
          "maxOutputTokens": 1024,
        }
      };

      print('📤 Sending request to Gemini API...');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('📥 Received response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['candidates'] != null && 
            responseData['candidates'].isNotEmpty) {
          
          final content = responseData['candidates'][0]['content']['parts'][0]['text'];
          print('🤖 AI Response: $content');
          
          // Parse the JSON response from AI
          try {
            // Extract JSON from the response (in case there's extra text)
            final jsonStart = content.indexOf('{');
            final jsonEnd = content.lastIndexOf('}') + 1;
            
            if (jsonStart != -1 && jsonEnd > jsonStart) {
              final jsonString = content.substring(jsonStart, jsonEnd);
              final aiData = jsonDecode(jsonString);
              
              return MedicineVerificationResult.fromAI(aiData);
            } else {
              throw Exception('No valid JSON found in AI response');
            }
          } catch (e) {
            print('❌ Error parsing AI response: $e');
            return MedicineVerificationResult.error('Failed to parse AI response');
          }
        } else {
          return MedicineVerificationResult.error('No response from AI');
        }
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.body}');
        return MedicineVerificationResult.error('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception in analyzeMedicineImage: $e');
      return MedicineVerificationResult.error('Analysis failed: $e');
    }
  }

  /// Test the API connection
  Future<bool> testConnection() async {
    try {
      final url = '$_baseUrl/$_model:generateContent?key=$_apiKey';
      
      final testRequest = {
        "contents": [
          {
            "parts": [
              {"text": "Hello, respond with 'API Working'"}
            ]
          }
        ]
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(testRequest),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ API Test failed: $e');
      return false;
    }
  }
}

/// Medicine verification result model
class MedicineVerificationResult {
  final String? medicineName;
  final String? expiryDate;
  final String? manufacturingDate;
  final String? batchNumber;
  final String? manufacturer;
  final bool isExpired;
  final double confidence;
  final String? error;
  final bool isSuccess;

  MedicineVerificationResult({
    this.medicineName,
    this.expiryDate,
    this.manufacturingDate,
    this.batchNumber,
    this.manufacturer,
    this.isExpired = false,
    this.confidence = 0.0,
    this.error,
    this.isSuccess = true,
  });

  factory MedicineVerificationResult.fromAI(Map<String, dynamic> data) {
    try {
      // Parse dates and check if expired
      DateTime? expiry;
      bool expired = false;
      
      if (data['expiry_date'] != null) {
        try {
          final parts = data['expiry_date'].toString().split('/');
          if (parts.length == 3) {
            expiry = DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[1]), // month
              int.parse(parts[0]), // day
            );
            expired = expiry.isBefore(DateTime.now());
          }
        } catch (e) {
          print('⚠️ Error parsing expiry date: $e');
        }
      }

      return MedicineVerificationResult(
        medicineName: data['medicine_name']?.toString(),
        expiryDate: data['expiry_date']?.toString(),
        manufacturingDate: data['manufacturing_date']?.toString(),
        batchNumber: data['batch_number']?.toString(),
        manufacturer: data['manufacturer']?.toString(),
        isExpired: data['is_expired'] ?? expired,
        confidence: (data['confidence'] ?? 0.0).toDouble(),
        error: data['error']?.toString(),
        isSuccess: data['error'] == null,
      );
    } catch (e) {
      return MedicineVerificationResult.error('Failed to parse AI data: $e');
    }
  }

  factory MedicineVerificationResult.error(String errorMessage) {
    return MedicineVerificationResult(
      error: errorMessage,
      isSuccess: false,
      confidence: 0.0,
    );
  }

  /// Check if the medicine is safe to donate
  bool get isSafeToDonate => isSuccess && !isExpired && confidence > 0.5;

  /// Get user-friendly status message
  String get statusMessage {
    if (!isSuccess) return error ?? 'Analysis failed';
    if (isExpired) return 'Medicine is expired - cannot donate';
    if (confidence < 0.5) return 'Low confidence - please verify manually';
    return 'Safe to donate';
  }

  /// Get status color for UI
  String get statusColor {
    if (!isSuccess || isExpired) return 'red';
    if (confidence < 0.5) return 'orange';
    return 'green';
  }

  @override
  String toString() {
    return 'MedicineVerificationResult(medicine: $medicineName, expiry: $expiryDate, expired: $isExpired, confidence: $confidence)';
  }
}
