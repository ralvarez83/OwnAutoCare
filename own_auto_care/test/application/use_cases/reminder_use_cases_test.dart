import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:own_auto_care/domain/entities/reminder.dart';
import 'package:own_auto_care/domain/repositories/reminder_repository.dart';
import 'package:own_auto_care/application/use_cases/create_reminder.dart';
import 'package:own_auto_care/application/use_cases/list_reminders.dart';
import 'package:own_auto_care/application/use_cases/get_reminder.dart';
import 'package:own_auto_care/application/use_cases/update_reminder.dart';
import 'package:own_auto_care/application/use_cases/delete_reminder.dart';

import 'package:mockito/annotations.dart';
import 'reminder_use_cases_test.mocks.dart'; // Import the generated mock file

@GenerateMocks([ReminderRepository])
void main() {
  late MockReminderRepository mockReminderRepository;
  late CreateReminder createReminder;
  late ListReminders listReminders;
  late GetReminder getReminder;
  late UpdateReminder updateReminder;
  late DeleteReminder deleteReminder;

  setUp(() {
    mockReminderRepository = MockReminderRepository();
    createReminder = CreateReminder(mockReminderRepository);
    listReminders = ListReminders(mockReminderRepository);
    getReminder = GetReminder(mockReminderRepository);
    updateReminder = UpdateReminder(mockReminderRepository);
    deleteReminder = DeleteReminder(mockReminderRepository);
  });

  final tReminder = Reminder(
    id: '1',
    vehicleId: 'vehicle1',
    title: 'Oil Change',
    dueDate: DateTime(2024, 1, 1),
  );

  group('CreateReminder', () {
    test('should call saveReminder on the repository', () async {
      when(mockReminderRepository.saveReminder(any))
          .thenAnswer((_) async => Future.value());

      await createReminder(tReminder);

      verify(mockReminderRepository.saveReminder(tReminder));
      verifyNoMoreInteractions(mockReminderRepository);
    });
  });

  group('ListReminders', () {
    test('should return a list of reminders from the repository', () async {
      final tReminderList = [tReminder];
      when(mockReminderRepository.getRemindersByVehicleId(any))
          .thenAnswer((_) async => tReminderList);

      final result = await listReminders('vehicle1');

      expect(result, tReminderList);
      verify(mockReminderRepository.getRemindersByVehicleId('vehicle1'));
      verifyNoMoreInteractions(mockReminderRepository);
    });
  });

  group('GetReminder', () {
    test('should return a reminder from the repository', () async {
      when(mockReminderRepository.getReminderById(any))
          .thenAnswer((_) async => tReminder);

      final result = await getReminder('1');

      expect(result, tReminder);
      verify(mockReminderRepository.getReminderById('1'));
      verifyNoMoreInteractions(mockReminderRepository);
    });
  });

  group('UpdateReminder', () {
    test('should call saveReminder on the repository', () async {
      when(mockReminderRepository.saveReminder(any))
          .thenAnswer((_) async => Future.value());

      await updateReminder(tReminder);

      verify(mockReminderRepository.saveReminder(tReminder));
      verifyNoMoreInteractions(mockReminderRepository);
    });
  });

  group('DeleteReminder', () {
    test('should call deleteReminder on the repository', () async {
      when(mockReminderRepository.deleteReminder(any))
          .thenAnswer((_) async => Future.value());

      await deleteReminder('1');

      verify(mockReminderRepository.deleteReminder('1'));
      verifyNoMoreInteractions(mockReminderRepository);
    });
  });
}
