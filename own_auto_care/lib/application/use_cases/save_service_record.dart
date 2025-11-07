import 'package:own_auto_care/domain/entities/service_record.dart';
import 'package:own_auto_care/domain/repositories/service_record_repository.dart';

class SaveServiceRecord {
  final ServiceRecordRepository repository;

  SaveServiceRecord(this.repository);

  Future<void> call(ServiceRecord record) {
    return repository.saveServiceRecord(record);
  }
}
