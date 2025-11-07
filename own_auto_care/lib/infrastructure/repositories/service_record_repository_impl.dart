import 'dart:convert';

import 'package:own_auto_care/domain/entities/service_record.dart';
import 'package:own_auto_care/domain/repositories/service_record_repository.dart';
import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';

class ServiceRecordRepositoryImpl implements ServiceRecordRepository {
  final GoogleDriveProvider googleDriveProvider;

  ServiceRecordRepositoryImpl(this.googleDriveProvider);

  static const String _recordsKey = 'records';

  @override
  Future<void> deleteServiceRecord(String id) async {
    final data = await _readData();
    final records = (data[_recordsKey] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    records.removeWhere((r) => r['id'] == id);
    data[_recordsKey] = records;
    await _writeData(data);
  }

  @override
  Future<ServiceRecord?> getServiceRecordById(String id) async {
    final data = await _readData();
    final records = (data[_recordsKey] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    try {
      final json = records.firstWhere((r) => r['id'] == id);
      return ServiceRecord.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ServiceRecord>> getServiceRecordsByVehicleId(String vehicleId) async {
    final data = await _readData();
    final records = (data[_recordsKey] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final filtered = records.where((r) => r['vehicleId'] == vehicleId).toList();
    return filtered.map((j) => ServiceRecord.fromJson(j)).toList();
  }

  @override
  Future<void> saveServiceRecord(ServiceRecord serviceRecord) async {
    final data = await _readData();
    final records = (data[_recordsKey] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final index = records.indexWhere((r) => r['id'] == serviceRecord.id);
    if (index != -1) {
      records[index] = serviceRecord.toJson();
    } else {
      records.add(serviceRecord.toJson());
    }
    data[_recordsKey] = records;
    await _writeData(data);
  }

  Future<Map<String, dynamic>> _readData() async {
    try {
      final content = await googleDriveProvider.readRootMetadata();
      return content;
    } catch (e) {
      return {};
    }
  }

  Future<void> _writeData(Map<String, dynamic> data) async {
    await googleDriveProvider.writeRootMetadata(data);
  }
}
