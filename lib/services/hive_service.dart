import 'package:hive_flutter/hive_flutter.dart';
import 'package:medimatch/models/medicine.dart';
import 'package:medimatch/models/prescription.dart';
import 'package:medimatch/models/reminder.dart';
import 'package:medimatch/models/pharmacy.dart';
import 'package:medimatch/models/app_settings.dart';

class HiveService {
  static const String medicinesBox = 'medicines';
  static const String prescriptionsBox = 'prescriptions';
  static const String remindersBox = 'reminders';
  static const String pharmaciesBox = 'pharmacies';
  static const String settingsBox = 'settings';

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(MedicineAdapter());
    Hive.registerAdapter(PrescriptionAdapter());
    Hive.registerAdapter(ReminderAdapter());
    Hive.registerAdapter(PharmacyAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    
    // Open boxes
    await Hive.openBox<Medicine>(medicinesBox);
    await Hive.openBox<Prescription>(prescriptionsBox);
    await Hive.openBox<Reminder>(remindersBox);
    await Hive.openBox<Pharmacy>(pharmaciesBox);
    await Hive.openBox<AppSettings>(settingsBox);
    
    // Initialize default settings if not exists
    final settingsBoxInstance = Hive.box<AppSettings>(settingsBox);
    if (settingsBoxInstance.isEmpty) {
      await settingsBoxInstance.put('settings', AppSettings.defaultSettings());
    }
  }

  // Medicine methods
  Future<void> saveMedicine(Medicine medicine) async {
    final box = Hive.box<Medicine>(medicinesBox);
    await box.put(medicine.name, medicine);
  }

  Future<void> saveMedicines(List<Medicine> medicines) async {
    final box = Hive.box<Medicine>(medicinesBox);
    for (var medicine in medicines) {
      await box.put(medicine.name, medicine);
    }
  }

  Medicine? getMedicine(String name) {
    final box = Hive.box<Medicine>(medicinesBox);
    return box.get(name);
  }

  List<Medicine> getAllMedicines() {
    final box = Hive.box<Medicine>(medicinesBox);
    return box.values.toList();
  }

  Future<void> deleteMedicine(String name) async {
    final box = Hive.box<Medicine>(medicinesBox);
    await box.delete(name);
  }

  // Prescription methods
  Future<void> savePrescription(Prescription prescription) async {
    final box = Hive.box<Prescription>(prescriptionsBox);
    await box.put(prescription.id, prescription);
  }

  Prescription? getPrescription(String id) {
    final box = Hive.box<Prescription>(prescriptionsBox);
    return box.get(id);
  }

  List<Prescription> getAllPrescriptions() {
    final box = Hive.box<Prescription>(prescriptionsBox);
    return box.values.toList();
  }

  Future<void> deletePrescription(String id) async {
    final box = Hive.box<Prescription>(prescriptionsBox);
    await box.delete(id);
  }

  // Reminder methods
  Future<void> saveReminder(Reminder reminder) async {
    final box = Hive.box<Reminder>(remindersBox);
    await box.put(reminder.id, reminder);
  }

  Future<void> saveReminders(List<Reminder> reminders) async {
    final box = Hive.box<Reminder>(remindersBox);
    for (var reminder in reminders) {
      await box.put(reminder.id, reminder);
    }
  }

  Reminder? getReminder(String id) {
    final box = Hive.box<Reminder>(remindersBox);
    return box.get(id);
  }

  List<Reminder> getAllReminders() {
    final box = Hive.box<Reminder>(remindersBox);
    return box.values.toList();
  }

  Future<void> deleteReminder(String id) async {
    final box = Hive.box<Reminder>(remindersBox);
    await box.delete(id);
  }

  // Pharmacy methods
  Future<void> savePharmacy(Pharmacy pharmacy) async {
    final box = Hive.box<Pharmacy>(pharmaciesBox);
    await box.put(pharmacy.name, pharmacy);
  }

  Future<void> savePharmacies(List<Pharmacy> pharmacies) async {
    final box = Hive.box<Pharmacy>(pharmaciesBox);
    for (var pharmacy in pharmacies) {
      await box.put(pharmacy.name, pharmacy);
    }
  }

  List<Pharmacy> getAllPharmacies() {
    final box = Hive.box<Pharmacy>(pharmaciesBox);
    return box.values.toList();
  }

  // Settings methods
  Future<void> saveSettings(AppSettings settings) async {
    final box = Hive.box<AppSettings>(settingsBox);
    await box.put('settings', settings);
  }

  AppSettings getSettings() {
    final box = Hive.box<AppSettings>(settingsBox);
    return box.get('settings') ?? AppSettings.defaultSettings();
  }

  // Close Hive
  static Future<void> close() async {
    await Hive.close();
  }
}
