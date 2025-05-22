import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:medimatch/services/medical_assistant_api_service.dart';

class MedicalAssistantProvider extends ChangeNotifier {
  final MedicalAssistantApiService _apiService;
  
  bool _isLoading = false;
  String? _error;
  MedicalAssistantResponse? _lastResponse;
  List<MedicationAnalysis> _medications = [];
  String _possibleIllness = '';
  
  MedicalAssistantProvider(this._apiService);
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  MedicalAssistantResponse? get lastResponse => _lastResponse;
  List<MedicationAnalysis> get medications => _medications;
  String get possibleIllness => _possibleIllness;
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  Future<bool> analyzePrescription(File imageFile) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.analyzePrescription(imageFile);
      
      _lastResponse = response;
      _medications = response.parseMedications();
      _possibleIllness = response.extractPossibleIllness();
      
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Error analyzing prescription: $e');
      _setError('Failed to analyze prescription: $e');
      _setLoading(false);
      return false;
    }
  }
  
  void clearResults() {
    _lastResponse = null;
    _medications = [];
    _possibleIllness = '';
    _error = null;
    notifyListeners();
  }
}
