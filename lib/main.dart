import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Services
import 'package:medimatch/services/hive_service.dart';
import 'package:medimatch/services/gemini_service.dart';
import 'package:medimatch/services/ocr_service.dart';
import 'package:medimatch/services/location_service.dart';
import 'package:medimatch/services/map_service.dart';
import 'package:medimatch/services/medical_assistant_api_service.dart';
import 'package:medimatch/services/chat_service.dart';
import 'package:medimatch/services/firebase_service.dart';

// Providers
import 'package:medimatch/providers/settings_provider.dart';
import 'package:medimatch/providers/prescription_provider.dart';
import 'package:medimatch/providers/reminder_provider.dart';
import 'package:medimatch/providers/pharmacy_provider.dart';
import 'package:medimatch/providers/translation_provider.dart';
import 'package:medimatch/providers/medical_assistant_provider.dart';
import 'package:medimatch/providers/auth_provider.dart';

// Screens
import 'package:medimatch/screens/home_screen.dart';
import 'package:medimatch/screens/login_screen.dart';

// Utils
import 'package:medimatch/utils/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
    // Continue without Firebase
  }

  // Initialize Hive
  await HiveService.init();

  // Initialize notifications
  try {
    await NotificationHelper.initialize();
    await NotificationHelper.requestPermissions();
  } catch (e) {
    debugPrint('Error initializing notifications: $e');
    // Continue without notifications
  }

  // Initialize Chat Service
  try {
    await ChatService().init();
  } catch (e) {
    debugPrint('Error initializing Chat Service: $e');
    // Continue without Chat Service
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final hiveService = HiveService();
    final geminiService = GeminiService();
    final ocrService = OCRService();
    final locationService = LocationService();
    final mapService = MapService();
    final medicalAssistantApiService = MedicalAssistantApiService();
    final firebaseService = FirebaseService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(hiveService)),
        ChangeNotifierProvider(
          create:
              (_) =>
                  PrescriptionProvider(hiveService, geminiService, ocrService),
        ),
        ChangeNotifierProvider(
          create: (_) => ReminderProvider(hiveService, geminiService),
        ),
        ChangeNotifierProvider(
          create:
              (_) => PharmacyProvider(hiveService, locationService, mapService),
        ),
        ChangeNotifierProvider(
          create: (_) => TranslationProvider(geminiService),
        ),
        ChangeNotifierProvider(
          create: (_) => MedicalAssistantProvider(medicalAssistantApiService),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider(firebaseService)),
      ],
      child: Consumer2<SettingsProvider, AuthProvider>(
        builder: (context, settingsProvider, authProvider, _) {
          return MaterialApp(
            title: 'MediMatch',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness:
                    settingsProvider.darkMode
                        ? Brightness.dark
                        : Brightness.light,
                primary: Colors.teal,
                secondary: Colors.tealAccent,
                tertiary: Colors.amber,
              ),
              useMaterial3: true,
              cardTheme: const CardThemeData(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              appBarTheme: AppBarTheme(
                backgroundColor:
                    settingsProvider.darkMode
                        ? Colors.teal.shade800
                        : Colors.teal,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              textTheme: const TextTheme(
                headlineMedium: TextStyle(fontWeight: FontWeight.bold),
                titleLarge: TextStyle(fontWeight: FontWeight.bold),
                titleMedium: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('te'), // Telugu
              Locale('ml'), // Malayalam
              Locale('hi'), // Hindi
              Locale('ta'), // Tamil
            ],
            home:
                authProvider.isAuthenticated
                    ? const HomeScreen()
                    : const LoginScreen(),
          );
        },
      ),
    );
  }
}
