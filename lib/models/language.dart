class Language {
  final String name;
  final String code;
  final String nativeName;

  Language({
    required this.name,
    required this.code,
    required this.nativeName,
  });

  static List<Language> supportedLanguages = [
    Language(
      name: 'English',
      code: 'en',
      nativeName: 'English',
    ),
    Language(
      name: 'Telugu',
      code: 'te',
      nativeName: 'తెలుగు',
    ),
    Language(
      name: 'Malayalam',
      code: 'ml',
      nativeName: 'മലയാളം',
    ),
    Language(
      name: 'Hindi',
      code: 'hi',
      nativeName: 'हिन्दी',
    ),
    Language(
      name: 'Tamil',
      code: 'ta',
      nativeName: 'தமிழ்',
    ),
  ];

  static Language getLanguageByName(String name) {
    return supportedLanguages.firstWhere(
      (language) => language.name == name,
      orElse: () => supportedLanguages.first,
    );
  }

  static Language getLanguageByCode(String code) {
    return supportedLanguages.firstWhere(
      (language) => language.code == code,
      orElse: () => supportedLanguages.first,
    );
  }
}
