import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

/// A simplified handwriting recognition service that uses mock data for demonstration purposes.
/// In a real implementation, this would use TensorFlow Lite for handwriting recognition.
class HandwritingRecognitionService {
  // Common medicine names for mock data
  final List<String> _commonMedicineNames = [
    'Paracetamol',
    'Ibuprofen',
    'Aspirin',
    'Amoxicillin',
    'Metformin',
    'Atorvastatin',
    'Omeprazole',
    'Lisinopril',
    'Levothyroxine',
    'Amlodipine',
    'Simvastatin',
    'Metoprolol',
    'Losartan',
    'Albuterol',
    'Gabapentin',
  ];

  // Singleton pattern
  static final HandwritingRecognitionService _instance =
      HandwritingRecognitionService._internal();

  factory HandwritingRecognitionService() {
    return _instance;
  }

  HandwritingRecognitionService._internal();

  /// Simulates loading a machine learning model
  Future<void> loadModel() async {
    // In a real implementation, this would load a TensorFlow Lite model
    debugPrint('Simulating loading handwriting recognition model...');
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('Mock handwriting recognition model loaded successfully');
  }

  /// Recognizes handwriting in an image and returns a list of medicine names
  /// This is a mock implementation that returns random medicines from the common list
  Future<List<String>> recognizeHandwriting(File imageFile) async {
    debugPrint('Processing image: ${imageFile.path}');

    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));

    // Get random number of medicines (1-3)
    final random = Random();
    final numMedicines = random.nextInt(3) + 1;

    // Get random medicines from the list
    final List<String> recognizedMedicines = [];
    final Set<int> usedIndices = {};

    for (int i = 0; i < numMedicines; i++) {
      int index;
      do {
        index = random.nextInt(_commonMedicineNames.length);
      } while (usedIndices.contains(index));

      usedIndices.add(index);
      recognizedMedicines.add(_commonMedicineNames[index]);
    }

    debugPrint('Recognized medicines: $recognizedMedicines');
    return recognizedMedicines;
  }

  /// Dispose of any resources
  void dispose() {
    // No resources to dispose in this mock implementation
  }
}
