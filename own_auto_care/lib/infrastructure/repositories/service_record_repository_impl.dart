import 'package:own_auto_care/domain/entities/service_record.dart';
import 'package:own_auto_care/domain/repositories/service_record_repository.dart';
import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';

class ServiceRecordRepositoryImpl implements ServiceRecordRepository {
  final GoogleDriveProvider googleDriveProvider;

  ServiceRecordRepositoryImpl(this.googleDriveProvider);

  static const String _serviceRecordsKey = 'serviceRecords';

  @override
  Future<List<ServiceRecord>> getServiceRecordsByVehicleId(String vehicleId) async {
    try {
      final data = await _readData();
      if (!data.containsKey(_serviceRecordsKey)) {
        return [];
      }
      final serviceRecords = (data[_serviceRecordsKey] as List)
          .cast<Map<String, dynamic>>();
      return serviceRecords
          .map((json) => ServiceRecord.fromJson(json))
          .where((record) => record.vehicleId == vehicleId)
          .toList();
    } catch (e) {
      throw 'Failed to get service records: ${e.toString()}';
    }
  }

  @override
  Future<ServiceRecord?> getServiceRecordById(String id) async {
    try {
      final data = await _readData();
      if (!data.containsKey(_serviceRecordsKey)) {
        return null;
      }
      final serviceRecords = (data[_serviceRecordsKey] as List)
          .cast<Map<String, dynamic>>();
      final json = serviceRecords.firstWhere(
        (recordJson) => recordJson['id'] == id,
        orElse: () => {},
      );
      return json.isNotEmpty ? ServiceRecord.fromJson(json) : null;
    } catch (e) {
      throw 'Failed to get service record: ${e.toString()}';
    }
  }

  @override
  Future<void> saveServiceRecord(ServiceRecord serviceRecord) async {
    try {
      final data = await _readData();
      if (!data.containsKey(_serviceRecordsKey)) {
        data[_serviceRecordsKey] = [];
      }

      final serviceRecords = (data[_serviceRecordsKey] as List)
          .cast<Map<String, dynamic>>();
      final index = serviceRecords.indexWhere(
          (recordJson) => recordJson['id'] == serviceRecord.id);

      if (index == -1) {
        serviceRecords.add(serviceRecord.toJson());
      } else {
        serviceRecords[index] = serviceRecord.toJson();
      }
      data[_serviceRecordsKey] = serviceRecords;
      await _writeData(data);
    } catch (e) {
      throw 'Failed to save service record: ${e.toString()}';
    }
  }

  @override
  Future<void> deleteServiceRecord(String id) async {
    try {
      final data = await _readData();
      if (!data.containsKey(_serviceRecordsKey)) {
        return;
      }

      final serviceRecords = (data[_serviceRecordsKey] as List)
          .cast<Map<String, dynamic>>();
      serviceRecords.removeWhere((recordJson) => recordJson['id'] == id);
      data[_serviceRecordsKey] = serviceRecords;
      await _writeData(data);
    } catch (e) {
      throw 'Failed to delete service record: ${e.toString()}';
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
      throw 'Failed to read data: ${e.toString()}';
    }
  }

  Future<void> _writeData(Map<String, dynamic> data) async {
    try {
      await googleDriveProvider.writeRootMetadata(data);
    } catch (e) {
      throw 'Failed to write data: ${e.toString()}';
    }
  }
}