import 'package:flutter/material.dart';
import 'package:medimatch/models/language.dart';
import 'package:medimatch/services/gemini_service.dart';

class TranslationProvider extends ChangeNotifier {
  final GeminiService _geminiService;

  bool _isLoading = false;
  String? _error;
  final Map<String, String> _translationCache = {};

  TranslationProvider(this._geminiService);

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String> translateText(String text, Language targetLanguage) async {
    // Skip translation if target language is English
    if (targetLanguage.code == 'en') {
      return text;
    }

    // Check cache first
    final cacheKey = '${text}_${targetLanguage.code}';
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }

    _setLoading(true);
    try {
      final translatedText = await _geminiService.translateText(
        text,
        targetLanguage.name,
      );

      // Cache the result
      _translationCache[cacheKey] = translatedText;

      _setError(null);
      return translatedText;
    } catch (e) {
      _setError('Failed to translate text: $e');
      return text; // Return original text on error
    } finally {
      _setLoading(false);
    }
  }

  Future<String> explainAndTranslate(
    String medicineInstruction,
    Language targetLanguage,
  ) async {
    _setLoading(true);
    try {
      // First explain in English
      final explanation = await _geminiService.explainInstructions(
        medicineInstruction,
      );

      // Then translate if needed
      if (targetLanguage.code == 'en') {
        return explanation;
      }

      final translatedExplanation = await _geminiService.translateText(
        explanation,
        targetLanguage.name,
      );

      _setError(null);
      return translatedExplanation;
    } catch (e) {
      _setError('Failed to explain and translate: $e');
      return medicineInstruction; // Return original text on error
    } finally {
      _setLoading(false);
    }
  }

  void clearCache() {
    _translationCache.clear();
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
