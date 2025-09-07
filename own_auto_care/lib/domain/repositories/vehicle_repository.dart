
import '../entities/vehicle.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> getAllVehicles();
  Future<Vehicle?> getVehicleById(String id);
  Future<void> saveVehicle(Vehicle vehicle);
  Future<void> deleteVehicle(String id);
}
