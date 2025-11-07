import 'package:own_auto_care/domain/entities/service_record.dart';
import 'package:own_auto_care/domain/repositories/service_record_repository.dart';

class ListServiceRecords {
  final ServiceRecordRepository repository;

  ListServiceRecords(this.repository);

  Future<List<ServiceRecord>> call(String vehicleId) {
    return repository.getServiceRecordsByVehicleId(vehicleId);
  }
}
