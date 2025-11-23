import 'package:own_auto_care/domain/entities/reminder.dart';
import 'package:own_auto_care/domain/repositories/reminder_repository.dart';

class GetReminder {
  final ReminderRepository repository;

  GetReminder(this.repository);

  Future<Reminder?> call(String id) {
    return repository.getReminderById(id);
  }
}
