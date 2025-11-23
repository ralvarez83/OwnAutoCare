import 'package:own_auto_care/domain/entities/service_record.dart';
import 'package:own_auto_care/domain/repositories/service_record_repository.dart';

class CreateServiceRecord {
  final ServiceRecordRepository repository;

  CreateServiceRecord(this.repository);

  Future<void> call(ServiceRecord serviceRecord) {
    return repository.saveServiceRecord(serviceRecord);
  }
}
