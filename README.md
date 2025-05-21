# MediMatch

MediMatch is an AI-powered medicine assistant app built with Flutter. It helps users understand their prescriptions, find generic alternatives, check for drug interactions, and manage their medication schedule.

## Features

- **OCR Prescription Scanning**: Extract medicine information from prescription images
- **Generic Alternative Suggestions**: Find cheaper generic alternatives to brand-name medicines
- **Drug Interaction Checking**: Check for potential interactions between medications
- **Prescription Reminders**: Generate and manage medication schedules
- **Multi-language Support**: Translate medicine information into local languages (English, Telugu, Malayalam, Hindi, Tamil)
- **Emergency Pharmacy Finder**: Locate nearby pharmacies in case of emergency
- **Offline Support**: Store prescription data locally using Hive

## Technical Details

- **Flutter**: Cross-platform UI framework
- **Gemini 1.5 Flash**: AI model for medicine intelligence
- **Hive**: Local NoSQL database for offline storage
- **Google ML Kit**: OCR text recognition
- **Provider**: State management
- **No Backend**: All processing happens on-device with API calls to Gemini

## Getting Started

1. Clone the repository
2. Add your Gemini API key in `lib/services/gemini_service.dart`
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Privacy

MediMatch respects user privacy:
- All prescription data is stored locally on the device
- No personal health information is shared with third parties
- Gemini API calls are made directly from the app without a backend server
