
import '../entities/reminder.dart';

abstract class ReminderRepository {
  Future<List<Reminder>> getRemindersByVehicleId(String vehicleId);
  Future<Reminder?> getReminderById(String id);
  Future<void> saveReminder(Reminder reminder);
  Future<void> deleteReminder(String id);
}
