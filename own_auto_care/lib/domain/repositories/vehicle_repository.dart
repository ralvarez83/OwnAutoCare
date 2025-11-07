
import '../entities/vehicle.dart';
import '../value_objects/vehicle_id.dart';

abstract class VehicleRepository {
  Future<void> createVehicle(Vehicle vehicle);
  Future<List<Vehicle>> getVehicles();
  Future<void> updateVehicle(Vehicle vehicle);
  Future<void> deleteVehicle(VehicleId id);
}
