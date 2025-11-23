import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:own_auto_care/domain/entities/service_record.dart';
import 'package:own_auto_care/domain/repositories/service_record_repository.dart';
import 'package:own_auto_care/application/use_cases/create_service_record.dart';
import 'package:own_auto_care/application/use_cases/list_service_records.dart';
import 'package:own_auto_care/application/use_cases/get_service_record.dart';
import 'package:own_auto_care/application/use_cases/update_service_record.dart';
import 'package:own_auto_care/application/use_cases/delete_service_record.dart';

import 'package:mockito/annotations.dart';
import 'service_record_use_cases_test.mocks.dart'; // Import the generated mock file

@GenerateMocks([ServiceRecordRepository])
void main() {
  late MockServiceRecordRepository mockServiceRecordRepository;
  late CreateServiceRecord createServiceRecord;
  late ListServiceRecords listServiceRecords;
  late GetServiceRecord getServiceRecord;
  late UpdateServiceRecord updateServiceRecord;
  late DeleteServiceRecord deleteServiceRecord;

  setUp(() {
    mockServiceRecordRepository = MockServiceRecordRepository();
    createServiceRecord = CreateServiceRecord(mockServiceRecordRepository);
    listServiceRecords = ListServiceRecords(mockServiceRecordRepository);
    getServiceRecord = GetServiceRecord(mockServiceRecordRepository);
    updateServiceRecord = UpdateServiceRecord(mockServiceRecordRepository);
    deleteServiceRecord = DeleteServiceRecord(mockServiceRecordRepository);
  });

  final tServiceRecord = ServiceRecord(
    id: '1',
    vehicleId: 'vehicle1',
    date: DateTime(2023, 1, 1),
    mileageKm: 10000,
    type: 'Oil Change',
    parts: [],
    cost: 50.0,
    currency: 'USD',
    attachments: [],
  );

  group('CreateServiceRecord', () {
    test('should call saveServiceRecord on the repository', () async {
      when(mockServiceRecordRepository.saveServiceRecord(any))
          .thenAnswer((_) async => Future.value());

      await createServiceRecord(tServiceRecord);

      verify(mockServiceRecordRepository.saveServiceRecord(tServiceRecord));
      verifyNoMoreInteractions(mockServiceRecordRepository);
    });
  });

  group('ListServiceRecords', () {
    test('should return a list of service records from the repository', () async {
      final tServiceRecordList = [tServiceRecord];
      when(mockServiceRecordRepository.getServiceRecordsByVehicleId(any))
          .thenAnswer((_) async => tServiceRecordList);

      final result = await listServiceRecords('vehicle1');

      expect(result, tServiceRecordList);
      verify(mockServiceRecordRepository.getServiceRecordsByVehicleId('vehicle1'));
      verifyNoMoreInteractions(mockServiceRecordRepository);
    });
  });

  group('GetServiceRecord', () {
    test('should return a service record from the repository', () async {
      when(mockServiceRecordRepository.getServiceRecordById(any))
          .thenAnswer((_) async => tServiceRecord);

      final result = await getServiceRecord('1');

      expect(result, tServiceRecord);
      verify(mockServiceRecordRepository.getServiceRecordById('1'));
      verifyNoMoreInteractions(mockServiceRecordRepository);
    });
  });

  group('UpdateServiceRecord', () {
    test('should call saveServiceRecord on the repository', () async {
      when(mockServiceRecordRepository.saveServiceRecord(any))
          .thenAnswer((_) async => Future.value());

      await updateServiceRecord(tServiceRecord);

      verify(mockServiceRecordRepository.saveServiceRecord(tServiceRecord));
      verifyNoMoreInteractions(mockServiceRecordRepository);
    });
  });

  group('DeleteServiceRecord', () {
    test('should call deleteServiceRecord on the repository', () async {
      when(mockServiceRecordRepository.deleteServiceRecord(any))
          .thenAnswer((_) async => Future.value());

      await deleteServiceRecord('1');

      verify(mockServiceRecordRepository.deleteServiceRecord('1'));
      verifyNoMoreInteractions(mockServiceRecordRepository);
    });
  });
}
