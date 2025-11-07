import 'package:own_auto_care/domain/repositories/vehicle_repository.dart';
import 'package:own_auto_care/domain/value_objects/vehicle_id.dart';

class DeleteVehicle {
  final VehicleRepository repository;

  DeleteVehicle(this.repository);

  Future<void> call(VehicleId id) {
    return repository.deleteVehicle(id);
  }
}
