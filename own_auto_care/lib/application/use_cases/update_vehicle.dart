import 'package:own_auto_care/domain/entities/vehicle.dart';
import 'package:own_auto_care/domain/repositories/vehicle_repository.dart';

class UpdateVehicle {
  final VehicleRepository repository;

  UpdateVehicle(this.repository);

  Future<void> call(Vehicle vehicle) {
    return repository.updateVehicle(vehicle);
  }
}
