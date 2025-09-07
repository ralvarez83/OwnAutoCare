
import '../entities/service_record.dart';

abstract class ServiceRecordRepository {
  Future<List<ServiceRecord>> getServiceRecordsByVehicleId(String vehicleId);
  Future<ServiceRecord?> getServiceRecordById(String id);
  Future<void> saveServiceRecord(ServiceRecord serviceRecord);
  Future<void> deleteServiceRecord(String id);
}
