import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medimatch/models/prescription.dart';
import 'package:medimatch/services/gemini_service.dart';
import 'package:medimatch/services/hive_service.dart';
import 'package:medimatch/services/ocr_service.dart';
import 'package:uuid/uuid.dart';

class PrescriptionProvider extends ChangeNotifier {
  final HiveService _hiveService;
  final GeminiService _geminiService;
  final OCRService _ocrService;

  List<Prescription> _prescriptions = [];
  bool _isLoading = false;
  String? _error;

  PrescriptionProvider(
    this._hiveService,
    this._geminiService,
    this._ocrService,
  ) {
    _loadPrescriptions();
  }

  List<Prescription> get prescriptions => _prescriptions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadPrescriptions() async {
    _setLoading(true);
    try {
      _prescriptions = _hiveService.getAllPrescriptions();
      _prescriptions.sort(
        (a, b) => b.date.compareTo(a.date),
      ); // Sort by date, newest first
      _setError(null);
    } catch (e) {
      _setError('Failed to load prescriptions: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<Prescription?> scanPrescription(
    File imageFile,
    String patientName,
  ) async {
    _setLoading(true);
    try {
      // Extract text from image
      final ocrText = await _ocrService.extractTextFromImage(imageFile);

      if (ocrText.isEmpty) {
        _setError('No text detected in the image');
        return null;
      }

      // Clean OCR text
      final cleanedText = _ocrService.cleanOcrText(ocrText);

      // Extract medicines using Gemini
      final medicines = await _geminiService.extractMedicines(cleanedText);

      if (medicines.isEmpty) {
        _setError('No medicines detected in the prescription');
        return null;
      }

      // Create prescription
      final prescription = Prescription(
        id: const Uuid().v4(),
        patientName: patientName,
        date: DateTime.now(),
        medicines: medicines,
        rawOcrText: ocrText,
      );

      // Save prescription
      await _hiveService.savePrescription(prescription);

      // Save medicines
      await _hiveService.saveMedicines(medicines);

      // Reload prescriptions
      await _loadPrescriptions();

      _setError(null);
      return prescription;
    } catch (e) {
      _setError('Failed to scan prescription: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> savePrescription(Prescription prescription) async {
    _setLoading(true);
    try {
      // Save prescription
      await _hiveService.savePrescription(prescription);

      // Save medicines
      await _hiveService.saveMedicines(prescription.medicines);

      // Reload prescriptions
      await _loadPrescriptions();

      _setError(null);
    } catch (e) {
      _setError('Failed to save prescription: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePrescription(String id) async {
    _setLoading(true);
    try {
      await _hiveService.deletePrescription(id);
      await _loadPrescriptions();
      _setError(null);
    } catch (e) {
      _setError('Failed to delete prescription: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Map<String, dynamic>>> getAlternatives(
    List<String> medicineNames,
  ) async {
    _setLoading(true);
    try {
      final alternatives = await _geminiService.suggestAlternatives(
        medicineNames,
      );
      _setError(null);
      return alternatives;
    } catch (e) {
      _setError('Failed to get alternatives: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<String> checkInteractions(List<String> medicineNames) async {
    _setLoading(true);
    try {
      final interactions = await _geminiService.checkDrugInteractions(
        medicineNames,
      );
      _setError(null);
      return interactions;
    } catch (e) {
      _setError('Failed to check interactions: $e');
      return 'Failed to check interactions';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
}
