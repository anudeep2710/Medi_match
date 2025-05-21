import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 4)
class AppSettings {
  @HiveField(0)
  final String language;

  @HiveField(1)
  final bool darkMode;

  @HiveField(2)
  final bool notificationsEnabled;

  @HiveField(3)
  final bool textToSpeechEnabled;

  AppSettings({
    required this.language,
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.textToSpeechEnabled = false,
  });

  factory AppSettings.defaultSettings() {
    return AppSettings(
      language: 'English',
      darkMode: false,
      notificationsEnabled: true,
      textToSpeechEnabled: false,
    );
  }

  AppSettings copyWith({
    String? language,
    bool? darkMode,
    bool? notificationsEnabled,
    bool? textToSpeechEnabled,
  }) {
    return AppSettings(
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      textToSpeechEnabled: textToSpeechEnabled ?? this.textToSpeechEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'darkMode': darkMode,
      'notificationsEnabled': notificationsEnabled,
      'textToSpeechEnabled': textToSpeechEnabled,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      language: json['language'] ?? 'English',
      darkMode: json['darkMode'] ?? false,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      textToSpeechEnabled: json['textToSpeechEnabled'] ?? false,
    );
  }
}
