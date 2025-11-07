import 'dart:convert';

import 'package:own_auto_care/domain/entities/vehicle.dart';
import 'package:own_auto_care/domain/repositories/vehicle_repository.dart';
import 'package:own_auto_care/domain/value_objects/vehicle_id.dart';
import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final GoogleDriveProvider googleDriveProvider;

  VehicleRepositoryImpl(this.googleDriveProvider);

  static const String _fileName = 'carcare.json';

  @override
  Future<void> createVehicle(Vehicle vehicle) async {
    try {
      final data = await _readData();
      data['vehicles'] = [...data['vehicles'] ?? [], vehicle.toJson()];
      await _writeData(data);
    } catch (e) {
      throw 'Failed to create vehicle: \${e.toString()}';
    }
  }

  @override
  Future<void> deleteVehicle(VehicleId id) async {
    try {
      final data = await _readData();
      if (!data.containsKey('vehicles')) {
        throw 'Invalid data structure: missing vehicles array';
      }

      final vehicles = (data['vehicles'] as List).cast<Map<String, dynamic>>();
      vehicles.removeWhere((v) => v['id'] == id.value);
      data['vehicles'] = vehicles;
      await _writeData(data);
    } catch (e) {
      throw 'Failed to delete vehicle: \${e.toString()}';
    }
  }

  @override
  Future<List<Vehicle>> getVehicles() async {
    try {
      final data = await _readData();
      if (!data.containsKey('vehicles')) {
        return [];
      }
      final vehicles = (data['vehicles'] as List).cast<Map<String, dynamic>>();
      return vehicles.map((json) => Vehicle.fromJson(json)).toList();
    } catch (e) {
      throw 'Failed to get vehicles: \${e.toString()}';
    }
  }

  @override
  Future<void> updateVehicle(Vehicle vehicle) async {
    try {
      final data = await _readData();
      if (!data.containsKey('vehicles')) {
        throw 'Invalid data structure: missing vehicles array';
      }

      final vehicles = (data['vehicles'] as List).cast<Map<String, dynamic>>();
      final index = vehicles.indexWhere((v) => v['id'] == vehicle.id.value);
      
      if (index == -1) {
        throw 'Vehicle not found';
      }

      vehicles[index] = vehicle.toJson();
      data['vehicles'] = vehicles;
      await _writeData(data);
    } catch (e) {
      throw 'Failed to update vehicle: \${e.toString()}';
    }
  }

  Future<Map<String, dynamic>> _readData() async {
    try {
      final content = await googleDriveProvider.readRootMetadata();
      if (content is! Map<String, dynamic>) {
        throw 'Invalid data format';
      }
      return content;
    } catch (e) {
      throw 'Failed to read data: \${e.toString()}';
    }
  }

  Future<void> _writeData(Map<String, dynamic> data) async {
    try {
      await googleDriveProvider.writeRootMetadata(data);
    } catch (e) {
      throw 'Failed to write data: \${e.toString()}';
    }
  }
}
