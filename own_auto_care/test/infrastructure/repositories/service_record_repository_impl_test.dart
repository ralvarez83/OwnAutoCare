import 'package:flutter_test/flutter_test.dart';
import 'package:own_auto_care/domain/entities/service_record.dart';
import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';
import 'package:own_auto_care/infrastructure/repositories/service_record_repository_impl.dart';
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
  group('ServiceRecordRepositoryImpl', () {
    late MockGoogleDriveProvider mockGoogleDriveProvider;
    late ServiceRecordRepositoryImpl serviceRecordRepository;

    setUp(() {
      mockGoogleDriveProvider = MockGoogleDriveProvider();
      serviceRecordRepository = ServiceRecordRepositoryImpl(mockGoogleDriveProvider);
    });

    final tServiceRecord1 = ServiceRecord(
      id: '1',
      vehicleId: 'vehicle1',
      date: DateTime(2023, 1, 1),
      mileageKm: 10000,
      items: [
        ServiceItem(type: 'Oil Change', cost: 50.0),
      ],
      cost: 50.0,
      currency: 'USD',
      attachments: [],
    );

    final tServiceRecord2 = ServiceRecord(
      id: '2',
      vehicleId: 'vehicle1',
      date: DateTime(2023, 2, 1),
      mileageKm: 15000,
      items: [
        ServiceItem(type: 'Tire Rotation', cost: 30.0),
      ],
      cost: 30.0,
      currency: 'USD',
      attachments: [],
    );

    final tServiceRecord3 = ServiceRecord(
      id: '3',
      vehicleId: 'vehicle2',
      date: DateTime(2023, 3, 1),
      mileageKm: 20000,
      items: [
        ServiceItem(type: 'Brake Pad Replacement', cost: 200.0),
      ],
      cost: 200.0,
      currency: 'USD',
      attachments: [],
    );

    test('should return empty list if no service records exist', () async {
      mockGoogleDriveProvider.setMockData({});
      final result = await serviceRecordRepository.getServiceRecordsByVehicleId('vehicle1');
      expect(result, isEmpty);
    });

    test('should return service records for a given vehicle ID', () async {
      mockGoogleDriveProvider.setMockData({
        'serviceRecords': [
          tServiceRecord1.toJson(),
          tServiceRecord2.toJson(),
          tServiceRecord3.toJson(),
        ],
      });
      final result = await serviceRecordRepository.getServiceRecordsByVehicleId('vehicle1');
      expect(result, [tServiceRecord1, tServiceRecord2]);
    });

    test('should return a service record by ID', () async {
      mockGoogleDriveProvider.setMockData({
        'serviceRecords': [
          tServiceRecord1.toJson(),
          tServiceRecord2.toJson(),
        ],
      });
      final result = await serviceRecordRepository.getServiceRecordById('1');
      expect(result, tServiceRecord1);
    });

    test('should return null if service record not found by ID', () async {
      mockGoogleDriveProvider.setMockData({
        'serviceRecords': [
          tServiceRecord1.toJson(),
        ],
      });
      final result = await serviceRecordRepository.getServiceRecordById('99');
      expect(result, isNull);
    });

    test('should save a new service record', () async {
      mockGoogleDriveProvider.setMockData({'serviceRecords': []});
      await serviceRecordRepository.saveServiceRecord(tServiceRecord1);
      final data = await mockGoogleDriveProvider.readRootMetadata();
      expect(data['serviceRecords'], [tServiceRecord1.toJson()]);
    });

    test('should update an existing service record', () async {
      final updatedServiceRecord = ServiceRecord(
        id: '1',
        vehicleId: 'vehicle1',
        date: DateTime(2023, 1, 1),
        mileageKm: 10500,
        visitType: VisitType.maintenance,
        items: [
          ServiceItem(type: 'Oil Change and Filter', cost: 60.0),
        ],
        cost: 60.0,
        currency: 'USD',
        attachments: [],
      );
      mockGoogleDriveProvider.setMockData({'serviceRecords': [tServiceRecord1.toJson()]});
      await serviceRecordRepository.saveServiceRecord(updatedServiceRecord);
      final data = await mockGoogleDriveProvider.readRootMetadata();
      expect(data['serviceRecords'], [updatedServiceRecord.toJson()]);
    });

    test('should delete a service record', () async {
      mockGoogleDriveProvider.setMockData({
        'serviceRecords': [
          tServiceRecord1.toJson(),
          tServiceRecord2.toJson(),
        ],
      });
      await serviceRecordRepository.deleteServiceRecord('1');
      final data = await mockGoogleDriveProvider.readRootMetadata();
      expect(data['serviceRecords'], [tServiceRecord2.toJson()]);
    });

    test('should do nothing if deleting a non-existent service record', () async {
      mockGoogleDriveProvider.setMockData({'serviceRecords': [tServiceRecord1.toJson()]});
      await serviceRecordRepository.deleteServiceRecord('99');
      final data = await mockGoogleDriveProvider.readRootMetadata();
      expect(data['serviceRecords'], [tServiceRecord1.toJson()]);
    });
  });
}
