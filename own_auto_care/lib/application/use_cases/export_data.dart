import 'dart:convert';

import '../../domain/repositories/reminder_repository.dart';
import '../../domain/repositories/service_record_repository.dart';
import '../../domain/repositories/vehicle_repository.dart';

class ExportData {
  final VehicleRepository vehicleRepository;
  final ServiceRecordRepository serviceRecordRepository;
  final ReminderRepository reminderRepository;

  ExportData({
    required this.vehicleRepository,
    required this.serviceRecordRepository,
    required this.reminderRepository,
  });

  Future<String> call() async {
    final vehicles = await vehicleRepository.getVehicles();
    final Map<String, dynamic> data = {
      'version': 1,
      'timestamp': DateTime.now().toIso8601String(),
      'vehicles': [],
      'serviceRecords': [],
      'reminders': [],
    };

    for (final vehicle in vehicles) {
      (data['vehicles'] as List).add(vehicle.toJson());

      final serviceRecords = await serviceRecordRepository
          .getServiceRecordsByVehicleId(vehicle.id.value);
      (data['serviceRecords'] as List)
          .addAll(serviceRecords.map((e) => e.toJson()));

      final reminders =
          await reminderRepository.getRemindersByVehicleId(vehicle.id.value);
      (data['reminders'] as List).addAll(reminders.map((e) => e.toJson()));
    }

    return jsonEncode(data);
  }
}
