import 'package:own_auto_care/domain/entities/reminder.dart';
import 'package:own_auto_care/domain/repositories/reminder_repository.dart';

class ListReminders {
  final ReminderRepository repository;

  ListReminders(this.repository);

  Future<List<Reminder>> call(String vehicleId) {
    return repository.getRemindersByVehicleId(vehicleId);
  }
}
