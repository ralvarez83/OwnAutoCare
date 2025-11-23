import 'package:own_auto_care/domain/entities/reminder.dart';
import 'package:own_auto_care/domain/repositories/reminder_repository.dart';
import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final GoogleDriveProvider googleDriveProvider;

  ReminderRepositoryImpl(this.googleDriveProvider);

  static const String _remindersKey = 'reminders';

  @override
  Future<List<Reminder>> getRemindersByVehicleId(String vehicleId) async {
    try {
      final data = await _readData();
      if (!data.containsKey(_remindersKey)) {
        return [];
      }
      final reminders = (data[_remindersKey] as List)
          .cast<Map<String, dynamic>>();
      return reminders
          .map((json) => Reminder.fromJson(json))
          .where((reminder) => reminder.vehicleId == vehicleId)
          .toList();
    } catch (e) {
      throw 'Failed to get reminders: ${e.toString()}';
    }
  }

  @override
  Future<Reminder?> getReminderById(String id) async {
    try {
      final data = await _readData();
      if (!data.containsKey(_remindersKey)) {
        return null;
      }
      final reminders = (data[_remindersKey] as List)
          .cast<Map<String, dynamic>>();
      final json = reminders.firstWhere(
        (reminderJson) => reminderJson['id'] == id,
        orElse: () => {},
      );
      return json.isNotEmpty ? Reminder.fromJson(json) : null;
    } catch (e) {
      throw 'Failed to get reminder: ${e.toString()}';
    }
  }

  @override
  Future<void> saveReminder(Reminder reminder) async {
    try {
      final data = await _readData();
      if (!data.containsKey(_remindersKey)) {
        data[_remindersKey] = [];
      }

      final reminders = (data[_remindersKey] as List)
          .cast<Map<String, dynamic>>();
      final index = reminders.indexWhere(
          (reminderJson) => reminderJson['id'] == reminder.id);

      if (index == -1) {
        reminders.add(reminder.toJson());
      } else {
        reminders[index] = reminder.toJson();
      }
      data[_remindersKey] = reminders;
      await _writeData(data);
    } catch (e) {
      throw 'Failed to save reminder: ${e.toString()}';
    }
  }

  @override
  Future<void> deleteReminder(String id) async {
    try {
      final data = await _readData();
      if (!data.containsKey(_remindersKey)) {
        return;
      }

      final reminders = (data[_remindersKey] as List)
          .cast<Map<String, dynamic>>();
      reminders.removeWhere((reminderJson) => reminderJson['id'] == id);
      data[_remindersKey] = reminders;
      await _writeData(data);
    } catch (e) {
      throw 'Failed to delete reminder: ${e.toString()}';
    }
  }

  Future<Map<String, dynamic>> _readData() async {
    try {
      final content = await googleDriveProvider.readRootMetadata();
      if (content is! Map<String, dynamic>) {
        throw 'Invalid data format';
      }
      return content;
    } catch (e) {
      throw 'Failed to read data: ${e.toString()}';
    }
  }

  Future<void> _writeData(Map<String, dynamic> data) async {
    try {
      await googleDriveProvider.writeRootMetadata(data);
    } catch (e) {
      throw 'Failed to write data: ${e.toString()}';
    }
  }
}
