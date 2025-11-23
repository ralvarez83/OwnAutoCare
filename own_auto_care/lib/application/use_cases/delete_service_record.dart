import 'package:own_auto_care/domain/repositories/service_record_repository.dart';

class DeleteServiceRecord {
  final ServiceRecordRepository repository;

  DeleteServiceRecord(this.repository);

  Future<void> call(String serviceRecordId) {
    return repository.deleteServiceRecord(serviceRecordId);
  }
}