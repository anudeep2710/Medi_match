import 'package:flutter/material.dart';
import 'package:medimatch/models/app_settings.dart';
import 'package:medimatch/models/language.dart';
import 'package:medimatch/services/hive_service.dart';

class SettingsProvider extends ChangeNotifier {
  late AppSettings _settings;
  final HiveService _hiveService;

  SettingsProvider(this._hiveService) {
    _loadSettings();
  }

  AppSettings get settings => _settings;
  
  String get language => _settings.language;
  bool get darkMode => _settings.darkMode;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  bool get textToSpeechEnabled => _settings.textToSpeechEnabled;

  Language get currentLanguage => Language.getLanguageByName(language);

  Future<void> _loadSettings() async {
    _settings = _hiveService.getSettings();
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _settings = _settings.copyWith(language: language);
    await _hiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _settings = _settings.copyWith(darkMode: value);
    await _hiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _settings = _settings.copyWith(notificationsEnabled: value);
    await _hiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setTextToSpeechEnabled(bool value) async {
    _settings = _settings.copyWith(textToSpeechEnabled: value);
    await _hiveService.saveSettings(_settings);
    notifyListeners();
  }
}
