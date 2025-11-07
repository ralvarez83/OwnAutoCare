import 'package:own_auto_care/domain/entities/vehicle.dart';
import 'package:own_auto_care/domain/repositories/vehicle_repository.dart';

class ListVehicles {
  final VehicleRepository repository;

  ListVehicles(this.repository);

  Future<List<Vehicle>> call() {
    return repository.getVehicles();
  }
}
