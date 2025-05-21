import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medimatch/models/language.dart';
import 'package:medimatch/providers/settings_provider.dart';
import 'package:medimatch/providers/translation_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final translationProvider = Provider.of<TranslationProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Language',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: settingsProvider.language,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    items: Language.supportedLanguages.map((language) {
                      return DropdownMenuItem<String>(
                        value: language.name,
                        child: Text('${language.name} (${language.nativeName})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        settingsProvider.setLanguage(value);
                        translationProvider.clearCache();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Appearance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Use dark theme'),
                    value: settingsProvider.darkMode,
                    onChanged: (value) {
                      settingsProvider.setDarkMode(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Receive medicine reminders'),
                    value: settingsProvider.notificationsEnabled,
                    onChanged: (value) {
                      settingsProvider.setNotificationsEnabled(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Accessibility',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text('Text-to-Speech'),
                    subtitle: const Text('Read medicine instructions aloud'),
                    value: settingsProvider.textToSpeechEnabled,
                    onChanged: (value) {
                      settingsProvider.setTextToSpeechEnabled(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const ListTile(
                    title: Text('MediMatch'),
                    subtitle: Text('Version 1.0.0'),
                    leading: Icon(Icons.info),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Privacy Policy'),
                    leading: const Icon(Icons.privacy_tip),
                    onTap: () {
                      // Open privacy policy
                    },
                  ),
                  ListTile(
                    title: const Text('Terms of Service'),
                    leading: const Icon(Icons.description),
                    onTap: () {
                      // Open terms of service
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
