import 'package:own_auto_care/domain/entities/reminder.dart';
import 'package:own_auto_care/domain/repositories/reminder_repository.dart';

class CreateReminder {
  final ReminderRepository repository;

  CreateReminder(this.repository);

  Future<void> call(Reminder reminder) {
    return repository.saveReminder(reminder);
  }
}
