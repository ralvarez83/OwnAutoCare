import 'package:own_auto_care/domain/entities/service_record.dart';
import 'package:own_auto_care/domain/repositories/service_record_repository.dart';

class GetServiceRecord {
  final ServiceRecordRepository repository;

  GetServiceRecord(this.repository);

  Future<ServiceRecord?> call(String id) {
    return repository.getServiceRecordById(id);
  }
}
