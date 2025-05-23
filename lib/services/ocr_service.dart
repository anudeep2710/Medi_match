import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  // final TextRecognizer _textRecognizer = TextRecognizer();

  // Extract text from image - Mock implementation for release build
  Future<String> extractTextFromImage(File imageFile) async {
    try {
      // Simulate processing time
      await Future.delayed(const Duration(seconds: 2));

      // Return mock prescription text for testing
      final mockTexts = [
        '''
        Dr. Sarah Johnson, MD
        City Medical Center

        Patient: John Doe
        Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

        Rx:
        1. Paracetamol 500mg - Take 1 tablet twice daily after meals
        2. Amoxicillin 250mg - Take 1 capsule three times daily
        3. Cetirizine 10mg - Take 1 tablet once daily for allergies

        Dr. Sarah Johnson
        License: MD12345
        ''',
        '''
        Metro Hospital
        Dr. Michael Brown

        Patient Name: Jane Smith

        Prescription:
        - Ibuprofen 400mg: 1 tablet every 6 hours as needed for pain
        - Omeprazole 20mg: 1 capsule daily before breakfast
        - Vitamin D3 1000IU: 1 tablet daily

        Follow up in 1 week
        Dr. Michael Brown
        ''',
        '''
        Family Clinic
        Dr. Emily Davis, MD

        For: Robert Wilson
        Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

        Medications:
        1. Metformin 500mg - Take twice daily with meals
        2. Lisinopril 10mg - Take once daily in the morning
        3. Atorvastatin 20mg - Take once daily at bedtime

        Next appointment: 2 weeks
        Dr. Emily Davis
        '''
      ];

      // Return a random mock text
      final random = Random();
      return mockTexts[random.nextInt(mockTexts.length)];
    } catch (e) {
      debugPrint('Error extracting text: $e');
      return '';
    }
  }

  // Clean up resources
  void dispose() {
    // _textRecognizer.close();
    debugPrint('OCR Service disposed');
  }

  // Clean OCR text to improve medicine extraction
  String cleanOcrText(String ocrText) {
    // Remove extra whitespace
    String cleanedText = ocrText.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Replace common OCR errors
    cleanedText = cleanedText
        .replaceAll('0mg', '0 mg')
        .replaceAll('5mg', '5 mg')
        .replaceAll('0mcg', '0 mcg')
        .replaceAll('5mcg', '5 mcg')
        .replaceAll('0ml', '0 ml')
        .replaceAll('5ml', '5 ml');

    // Add line breaks for better parsing
    cleanedText = cleanedText
        .replaceAll(RegExp(r'(\d+\.)'), '\n\$1')
        .replaceAll(
          RegExp(r'(Tab|Tablet|Cap|Capsule|Syrup|Injection)'),
          '\n\$1',
        );

    return cleanedText;
  }

  // Extract potential medicine names from OCR text
  List<String> extractPotentialMedicineNames(String ocrText) {
    // This is a simple extraction that looks for capitalized words
    // In a real app, you would use a more sophisticated approach with a medicine database
    final medicineRegex = RegExp(
      r'[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*\s+\d+(?:\.\d+)?\s*(?:mg|mcg|ml|g)',
    );
    final matches = medicineRegex.allMatches(ocrText);

    return matches.map((match) => match.group(0)!).toList();
  }
}
