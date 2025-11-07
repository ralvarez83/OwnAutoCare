import 'package:own_auto_care/domain/entities/vehicle.dart';
import 'package:own_auto_care/domain/repositories/vehicle_repository.dart';

class CreateVehicle {
  final VehicleRepository repository;

  CreateVehicle(this.repository);

  Future<void> call(Vehicle vehicle) {
    return repository.createVehicle(vehicle);
  }
}
