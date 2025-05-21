import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  // Extract text from image
  Future<String> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      String text = recognizedText.text;
      return text;
    } catch (e) {
      debugPrint('Error extracting text: $e');
      return '';
    }
  }

  // Clean up resources
  void dispose() {
    _textRecognizer.close();
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
