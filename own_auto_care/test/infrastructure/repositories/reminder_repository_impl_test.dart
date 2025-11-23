import 'package:flutter_test/flutter_test.dart';
import 'package:own_auto_care/domain/entities/reminder.dart';
import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';
import 'package:own_auto_care/infrastructure/repositories/reminder_repository_impl.dart';
import 'package:own_auto_care/domain/repositories/cloud_storage_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MockGoogleDriveProvider implements GoogleDriveProvider {
  JsonMap _mockData = {};

  void setMockData(JsonMap data) {
    _mockData = data;
  }

  @override
  String get clientId => 'test-client';

  @override
  List<String> get scopes => const [];

  @override
  Future<void> authenticate() async {}

  @override
  Future<void> authenticateWithToken(String token) async {}

  @override
  Future<void> ensureSetup() async {}

  @override
  Future<Uri> getAttachmentLink(String path) async => Uri.parse('about:blank');

  @override
  Future<List<CloudItem>> listRecords(String vehicleId) async => [];

  @override
  Future<JsonMap> readRecord(String path) async => {};

  @override
  Future<JsonMap> readRootMetadata() async => _mockData;

  @override
  Future<void> writeRecord(String path, JsonMap data) async {}

  @override
  Future<void> writeRootMetadata(JsonMap data) async {
    _mockData = data;
  }

  @override
  Future<void> deleteRecord(String path) async {}

  @override
  Future<GoogleSignInAccount?> getCurrentUser() async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<String?> uploadFile(dynamic file, String folderName) async => 'https://fake.url/image.jpg';
}

void main() {
  group('ReminderRepositoryImpl', () {
    late MockGoogleDriveProvider mockGoogleDriveProvider;
    late ReminderRepositoryImpl reminderRepository;

    setUp(() {
      mockGoogleDriveProvider = MockGoogleDriveProvider();
      reminderRepository = ReminderRepositoryImpl(mockGoogleDriveProvider);
    });

    final tReminder1 = Reminder(
      id: '1',
      vehicleId: 'vehicle1',
      title: 'Oil Change',
      dueDate: DateTime(2024, 1, 1),
    );

    final tReminder2 = Reminder(
      id: '2',
      vehicleId: 'vehicle1',
      title: 'Tire Rotation',
      dueMileageKm: 15000,
    );

    final tReminder3 = Reminder(
      id: '3',
      vehicleId: 'vehicle2',
      title: 'Brake Check',
      dueDate: DateTime(2024, 6, 1),
    );

    test('should return empty list if no reminders exist', () async {
      mockGoogleDriveProvider.setMockData({});
      final result = await reminderRepository.getRemindersByVehicleId('vehicle1');
      expect(result, isEmpty);
    });

    test('should return reminders for a given vehicle ID', () async {
      mockGoogleDriveProvider.setMockData({
        'reminders': [
          tReminder1.toJson(),
          tReminder2.toJson(),
          tReminder3.toJson(),
        ],
      });
      final result = await reminderRepository.getRemindersByVehicleId('vehicle1');
      expect(result, [tReminder1, tReminder2]);
    });

    test('should return a reminder by ID', () async {
      mockGoogleDriveProvider.setMockData({
        'reminders': [
          tReminder1.toJson(),
          tReminder2.toJson(),
        ],
      });
      final result = await reminderRepository.getReminderById('1');
      expect(result, tReminder1);
    });

    test('should return null if reminder not found by ID', () async {
      mockGoogleDriveProvider.setMockData({
        'reminders': [
          tReminder1.toJson(),
        ],
      });
      final result = await reminderRepository.getReminderById('99');
      expect(result, isNull);
    });

    test('should save a new reminder', () async {
      mockGoogleDriveProvider.setMockData({'reminders': []});
      await reminderRepository.saveReminder(tReminder1);
      final data = await mockGoogleDriveProvider.readRootMetadata();
      expect(data['reminders'], [tReminder1.toJson()]);
    });

    test('should update an existing reminder', () async {
      final updatedReminder = Reminder(
        id: '1',
        vehicleId: 'vehicle1',
        title: 'Oil Change Due',
        dueDate: DateTime(2024, 1, 15),
      );
      mockGoogleDriveProvider.setMockData({'reminders': [tReminder1.toJson()]});
      await reminderRepository.saveReminder(updatedReminder);
      final data = await mockGoogleDriveProvider.readRootMetadata();
      expect(data['reminders'], [updatedReminder.toJson()]);
    });

    test('should delete a reminder', () async {
      mockGoogleDriveProvider.setMockData({
        'reminders': [
          tReminder1.toJson(),
          tReminder2.toJson(),
        ],
      });
      await reminderRepository.deleteReminder('1');
      final data = await mockGoogleDriveProvider.readRootMetadata();
      expect(data['reminders'], [tReminder2.toJson()]);
    });

    test('should do nothing if deleting a non-existent reminder', () async {
      mockGoogleDriveProvider.setMockData({'reminders': [tReminder1.toJson()]});
      await reminderRepository.deleteReminder('99');
      final data = await mockGoogleDriveProvider.readRootMetadata();
      expect(data['reminders'], [tReminder1.toJson()]);
    });
  });
}
