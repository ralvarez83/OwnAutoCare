import 'package:own_auto_care/domain/entities/service_record.dart';
import 'package:own_auto_care/domain/repositories/service_record_repository.dart';

class UpdateServiceRecord {
  final ServiceRecordRepository repository;

  UpdateServiceRecord(this.repository);

  Future<void> call(ServiceRecord serviceRecord) {
    return repository.saveServiceRecord(serviceRecord);
  }
}
