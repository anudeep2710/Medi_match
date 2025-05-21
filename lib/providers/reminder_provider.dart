import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:medimatch/models/medicine.dart';
import 'package:medimatch/models/reminder.dart';
import 'package:medimatch/services/gemini_service.dart';
import 'package:medimatch/services/hive_service.dart';
import 'package:medimatch/utils/notification_helper.dart';
import 'package:uuid/uuid.dart';

class ReminderProvider extends ChangeNotifier {
  final HiveService _hiveService;
  final GeminiService _geminiService;

  List<Reminder> _reminders = [];
  bool _isLoading = false;
  String? _error;

  ReminderProvider(this._hiveService, this._geminiService) {
    _loadReminders();
  }

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadReminders() async {
    _setLoading(true);
    try {
      _reminders = _hiveService.getAllReminders();
      _setError(null);
    } catch (e) {
      _setError('Failed to load reminders: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshReminders() async {
    await _loadReminders();
  }

  Future<void> generateReminders(List<Medicine> medicines) async {
    _setLoading(true);
    try {
      final generatedReminders = await _geminiService.generateReminders(
        medicines,
      );

      if (generatedReminders.isNotEmpty) {
        await _hiveService.saveReminders(generatedReminders);
        await _loadReminders();
      }

      _setError(null);
    } catch (e) {
      _setError('Failed to generate reminders: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addReminder(
    String medicineName,
    String time,
    String note,
    List<int> daysOfWeek,
  ) async {
    _setLoading(true);
    try {
      final reminder = Reminder(
        id: const Uuid().v4(),
        medicineName: medicineName,
        time: time,
        note: note,
        daysOfWeek: daysOfWeek,
      );

      await _hiveService.saveReminder(reminder);

      // Schedule notification
      try {
        await NotificationHelper.scheduleReminder(reminder);
      } catch (e) {
        debugPrint('Error scheduling notification: $e');
        // Continue without notification
      }

      await _loadReminders();

      _setError(null);
    } catch (e) {
      _setError('Failed to add reminder: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    _setLoading(true);
    try {
      // Cancel existing notification
      try {
        await NotificationHelper.cancelReminder(reminder.id);
      } catch (e) {
        debugPrint('Error canceling notification: $e');
      }

      // Save updated reminder
      await _hiveService.saveReminder(reminder);

      // Schedule new notification if active
      if (reminder.isActive) {
        try {
          await NotificationHelper.scheduleReminder(reminder);
        } catch (e) {
          debugPrint('Error scheduling notification: $e');
        }
      }

      await _loadReminders();

      _setError(null);
    } catch (e) {
      _setError('Failed to update reminder: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteReminder(String id) async {
    _setLoading(true);
    try {
      // Cancel notification
      try {
        await NotificationHelper.cancelReminder(id);
      } catch (e) {
        debugPrint('Error canceling notification: $e');
      }

      // Delete from storage
      await _hiveService.deleteReminder(id);
      await _loadReminders();

      _setError(null);
    } catch (e) {
      _setError('Failed to delete reminder: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleReminderActive(String id, bool isActive) async {
    _setLoading(true);
    try {
      final reminder = _hiveService.getReminder(id);

      if (reminder != null) {
        final updatedReminder = Reminder(
          id: reminder.id,
          medicineName: reminder.medicineName,
          time: reminder.time,
          note: reminder.note,
          isActive: isActive,
          daysOfWeek: reminder.daysOfWeek,
        );

        // Cancel existing notification
        try {
          await NotificationHelper.cancelReminder(id);
        } catch (e) {
          debugPrint('Error canceling notification: $e');
        }

        // Save updated reminder
        await _hiveService.saveReminder(updatedReminder);

        // Schedule new notification if active
        if (isActive) {
          try {
            await NotificationHelper.scheduleReminder(updatedReminder);
          } catch (e) {
            debugPrint('Error scheduling notification: $e');
          }
        }

        await _loadReminders();
      }

      _setError(null);
    } catch (e) {
      _setError('Failed to toggle reminder: $e');
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
