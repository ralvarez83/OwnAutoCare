import 'dart:convert';

import '../../domain/entities/reminder.dart';
import '../../domain/entities/service_record.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/repositories/service_record_repository.dart';
import '../../domain/repositories/vehicle_repository.dart';

class ImportData {
  final VehicleRepository vehicleRepository;
  final ServiceRecordRepository serviceRecordRepository;
  final ReminderRepository reminderRepository;

  ImportData({
    required this.vehicleRepository,
    required this.serviceRecordRepository,
    required this.reminderRepository,
  });

  Future<void> call(String jsonString) async {
    final Map<String, dynamic> data = jsonDecode(jsonString);

    // Import Vehicles
    if (data.containsKey('vehicles')) {
      final List<dynamic> vehiclesJson = data['vehicles'];
      final existingVehicles = await vehicleRepository.getVehicles();
      final existingIds = existingVehicles.map((v) => v.id.value).toSet();

      for (final vJson in vehiclesJson) {
        final vehicle = Vehicle.fromJson(vJson);
        if (existingIds.contains(vehicle.id.value)) {
          await vehicleRepository.updateVehicle(vehicle);
        } else {
          await vehicleRepository.createVehicle(vehicle);
        }
      }
    }

    // Import Service Records
    if (data.containsKey('serviceRecords')) {
      final List<dynamic> recordsJson = data['serviceRecords'];
      for (final rJson in recordsJson) {
        final record = ServiceRecord.fromJson(rJson);
        // ServiceRecordRepository has saveServiceRecord which should handle create/update
        await serviceRecordRepository.saveServiceRecord(record);
      }
    }

    // Import Reminders
    if (data.containsKey('reminders')) {
      final List<dynamic> remindersJson = data['reminders'];
      for (final rJson in remindersJson) {
        final reminder = Reminder.fromJson(rJson);
        // ReminderRepository has saveReminder which should handle create/update
        await reminderRepository.saveReminder(reminder);
      }
    }
  }
}
