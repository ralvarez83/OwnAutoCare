import 'package:own_auto_care/domain/repositories/reminder_repository.dart';

class DeleteReminder {
  final ReminderRepository repository;

  DeleteReminder(this.repository);

  Future<void> call(String reminderId) {
    return repository.deleteReminder(reminderId);
  }
}
