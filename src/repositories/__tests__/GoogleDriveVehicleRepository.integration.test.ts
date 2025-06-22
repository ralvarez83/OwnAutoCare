import { GoogleDriveVehicleRepository } from '../GoogleDriveVehicleRepository';
import { CreateVehicleData, UpdateVehicleData, Vehicle } from '@/types/vehicle';

// These tests require a real Google Drive connection
// They should be run with proper authentication
describe('GoogleDriveVehicleRepository Integration', () => {
  let repository: GoogleDriveVehicleRepository;

  beforeAll(() => {
    repository = new GoogleDriveVehicleRepository();
  });

  describe('CRUD Operations', () => {
    let createdVehicleId: string;

    const testVehicleData: CreateVehicleData = {
      marca: 'Test Toyota',
      modelo: 'Test Corolla',
      kms: 75000,
      kmsCambioAceite: 7500,
      tipoAceite: '5W-30',
      tipoDistribucion: 'cadena',
    };

    it('should create a vehicle in Google Drive', async () => {
      const vehicle = await repository.create(testVehicleData);

      expect(vehicle).toBeDefined();
      expect(vehicle.id).toBeDefined();
      expect(vehicle.marca).toBe(testVehicleData.marca);
      expect(vehicle.modelo).toBe(testVehicleData.modelo);
      expect(vehicle.kms).toBe(testVehicleData.kms);
      expect(vehicle.createdAt).toBeInstanceOf(Date);
      expect(vehicle.updatedAt).toBeInstanceOf(Date);

      createdVehicleId = vehicle.id;
    }, 30000); // 30 second timeout for API calls

    it('should retrieve all vehicles from Google Drive', async () => {
      const vehicles = await repository.getAll();

      expect(Array.isArray(vehicles)).toBe(true);
      expect(vehicles.length).toBeGreaterThan(0);

      // Should find our created vehicle
      const foundVehicle = vehicles.find(v => v.id === createdVehicleId);
      expect(foundVehicle).toBeDefined();
      expect(foundVehicle?.marca).toBe(testVehicleData.marca);
    }, 30000);

    it('should retrieve a specific vehicle by ID', async () => {
      const vehicle = await repository.getById(createdVehicleId);

      expect(vehicle).toBeDefined();
      expect(vehicle?.id).toBe(createdVehicleId);
      expect(vehicle?.marca).toBe(testVehicleData.marca);
      expect(vehicle?.modelo).toBe(testVehicleData.modelo);
    }, 30000);

    it('should update a vehicle in Google Drive', async () => {
      const updateData: UpdateVehicleData = {
        marca: 'Updated Toyota',
        kms: 80000,
      };

      const updatedVehicle = await repository.update(createdVehicleId, updateData);

      expect(updatedVehicle).toBeDefined();
      expect(updatedVehicle.id).toBe(createdVehicleId);
      expect(updatedVehicle.marca).toBe('Updated Toyota');
      expect(updatedVehicle.kms).toBe(80000);
      expect(updatedVehicle.modelo).toBe(testVehicleData.modelo); // Should remain unchanged
      expect(updatedVehicle.updatedAt.getTime()).toBeGreaterThan(
        updatedVehicle.createdAt.getTime()
      );
    }, 30000);

    it('should delete a vehicle from Google Drive', async () => {
      const result = await repository.delete(createdVehicleId);

      expect(result).toBe(true);

      // Verify it's actually deleted
      const deletedVehicle = await repository.getById(createdVehicleId);
      expect(deletedVehicle).toBeNull();
    }, 30000);
  });

  describe('Error Handling', () => {
    it('should handle non-existent vehicle ID', async () => {
      const vehicle = await repository.getById('non-existent-id');
      expect(vehicle).toBeNull();
    }, 30000);

    it('should handle update of non-existent vehicle', async () => {
      const updateData: UpdateVehicleData = {
        marca: 'Non-existent',
      };

      await expect(repository.update('non-existent-id', updateData)).rejects.toThrow();
    }, 30000);

    it('should handle delete of non-existent vehicle', async () => {
      const result = await repository.delete('non-existent-id');
      expect(result).toBe(false);
    }, 30000);
  });

  describe('Data Validation', () => {
    it('should handle vehicle with correa distribution', async () => {
      const correaVehicleData: CreateVehicleData = {
        marca: 'Test Honda',
        modelo: 'Test Civic',
        kms: 60000,
        kmsCambioAceite: 6000,
        tipoAceite: '10W-40',
        tipoDistribucion: 'correa',
        kmsCambioCorrea: 120000,
      };

      const vehicle = await repository.create(correaVehicleData);

      expect(vehicle).toBeDefined();
      expect(vehicle.tipoDistribucion).toBe('correa');
      expect(vehicle.kmsCambioCorrea).toBe(120000);

      // Clean up
      await repository.delete(vehicle.id);
    }, 30000);
  });
});
