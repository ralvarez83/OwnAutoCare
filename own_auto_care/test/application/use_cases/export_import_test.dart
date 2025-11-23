import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:own_auto_care/application/use_cases/export_data.dart';
import 'package:own_auto_care/application/use_cases/import_data.dart';
import 'package:own_auto_care/domain/entities/reminder.dart';
import 'package:own_auto_care/domain/entities/service_record.dart';
import 'package:own_auto_care/domain/entities/vehicle.dart';
import 'package:own_auto_care/domain/repositories/reminder_repository.dart';
import 'package:own_auto_care/domain/repositories/service_record_repository.dart';
import 'package:own_auto_care/domain/repositories/vehicle_repository.dart';
import 'package:own_auto_care/domain/value_objects/vehicle_id.dart';

class FakeVehicleRepository implements VehicleRepository {
  final List<Vehicle> vehicles = [];

  @override
  Future<void> createVehicle(Vehicle vehicle) async {
    vehicles.add(vehicle);
  }

  @override
  Future<void> deleteVehicle(VehicleId id) async {
    vehicles.removeWhere((v) => v.id == id);
  }

  @override
  Future<List<Vehicle>> getVehicles() async {
    return List.from(vehicles);
  }

  @override
  Future<void> updateVehicle(Vehicle vehicle) async {
    final index = vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      vehicles[index] = vehicle;
    }
  }
}

class FakeServiceRecordRepository implements ServiceRecordRepository {
  final List<ServiceRecord> records = [];

  @override
  Future<void> deleteServiceRecord(String id) async {
    records.removeWhere((r) => r.id == id);
  }

  @override
  Future<ServiceRecord?> getServiceRecordById(String id) async {
    try {
      return records.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ServiceRecord>> getServiceRecordsByVehicleId(String vehicleId) async {
    return records.where((r) => r.vehicleId == vehicleId).toList();
  }

  @override
  Future<void> saveServiceRecord(ServiceRecord serviceRecord) async {
    final index = records.indexWhere((r) => r.id == serviceRecord.id);
    if (index != -1) {
      records[index] = serviceRecord;
    } else {
      records.add(serviceRecord);
    }
  }
}

class FakeReminderRepository implements ReminderRepository {
  final List<Reminder> reminders = [];

  @override
  Future<void> deleteReminder(String id) async {
    reminders.removeWhere((r) => r.id == id);
  }

  @override
  Future<Reminder?> getReminderById(String id) async {
    try {
      return reminders.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Reminder>> getRemindersByVehicleId(String vehicleId) async {
    return reminders.where((r) => r.vehicleId == vehicleId).toList();
  }

  @override
  Future<void> saveReminder(Reminder reminder) async {
    final index = reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      reminders[index] = reminder;
    } else {
      reminders.add(reminder);
    }
  }
}

void main() {
  late FakeVehicleRepository vehicleRepo;
  late FakeServiceRecordRepository serviceRepo;
  late FakeReminderRepository reminderRepo;
  late ExportData exportData;
  late ImportData importData;

  setUp(() {
    vehicleRepo = FakeVehicleRepository();
    serviceRepo = FakeServiceRecordRepository();
    reminderRepo = FakeReminderRepository();
    exportData = ExportData(
      vehicleRepository: vehicleRepo,
      serviceRecordRepository: serviceRepo,
      reminderRepository: reminderRepo,
    );
    importData = ImportData(
      vehicleRepository: vehicleRepo,
      serviceRecordRepository: serviceRepo,
      reminderRepository: reminderRepo,
    );
  });

  final testVehicle = Vehicle(
    id: VehicleId('v1'),
    name: 'Test Car',
    make: 'Toyota',
    model: 'Corolla',
    year: 2020,
  );

  final testRecord = ServiceRecord(
    id: 's1',
    vehicleId: 'v1',
    date: DateTime(2023, 1, 1),
    mileageKm: 10000,
    type: 'Oil Change',
    parts: [],
    cost: 50.0,
    currency: 'USD',
    attachments: [],
  );

  final testReminder = Reminder(
    id: 'r1',
    vehicleId: 'v1',
    title: 'Check Tires',
    dueDate: DateTime(2023, 6, 1),
  );

  test('ExportData should return correct JSON structure', () async {
    // Arrange
    await vehicleRepo.createVehicle(testVehicle);
    await serviceRepo.saveServiceRecord(testRecord);
    await reminderRepo.saveReminder(testReminder);

    // Act
    final jsonString = await exportData();
    final Map<String, dynamic> data = jsonDecode(jsonString);

    // Assert
    expect(data['version'], 1);
    expect((data['vehicles'] as List).length, 1);
    expect((data['serviceRecords'] as List).length, 1);
    expect((data['reminders'] as List).length, 1);

    expect(data['vehicles'][0]['id'], 'v1');
    expect(data['serviceRecords'][0]['id'], 's1');
    expect(data['reminders'][0]['id'], 'r1');
  });

  test('ImportData should restore data correctly', () async {
    // Arrange
    final jsonString = jsonEncode({
      'version': 1,
      'vehicles': [testVehicle.toJson()],
      'serviceRecords': [testRecord.toJson()],
      'reminders': [testReminder.toJson()],
    });

    // Act
    await importData(jsonString);

    // Assert
    final vehicles = await vehicleRepo.getVehicles();
    final records = await serviceRepo.getServiceRecordsByVehicleId('v1');
    final reminders = await reminderRepo.getRemindersByVehicleId('v1');

    expect(vehicles.length, 1);
    expect(vehicles.first.id.value, 'v1');
    expect(vehicles.first.name, 'Test Car');

    expect(records.length, 1);
    expect(records.first.id, 's1');
    expect(records.first.type, 'Oil Change');

    expect(reminders.length, 1);
    expect(reminders.first.id, 'r1');
    expect(reminders.first.title, 'Check Tires');
  });

  test('ImportData should update existing data (Merge strategy)', () async {
    // Arrange
    await vehicleRepo.createVehicle(testVehicle);
    
    final updatedVehicle = testVehicle.copyWith(name: 'Updated Car');
    final jsonString = jsonEncode({
      'version': 1,
      'vehicles': [updatedVehicle.toJson()],
      'serviceRecords': [],
      'reminders': [],
    });

    // Act
    await importData(jsonString);

    // Assert
    final vehicles = await vehicleRepo.getVehicles();
    expect(vehicles.length, 1);
    expect(vehicles.first.name, 'Updated Car');
  });
}
