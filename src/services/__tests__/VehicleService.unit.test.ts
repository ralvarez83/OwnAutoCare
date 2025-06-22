import { VehicleService } from '../VehicleService';
import { CreateVehicleData, UpdateVehicleData, Vehicle } from '@/types/vehicle';
import { IVehicleRepository } from '@/repositories/IVehicleRepository';

// Mock repository
const mockRepository: jest.Mocked<IVehicleRepository> = {
  getAll: jest.fn(),
  getById: jest.fn(),
  create: jest.fn(),
  update: jest.fn(),
  delete: jest.fn(),
};

describe('VehicleService', () => {
  let vehicleService: VehicleService;

  beforeEach(() => {
    vehicleService = new VehicleService(mockRepository);
    jest.clearAllMocks();
  });

  describe('getAllVehicles', () => {
    it('should return all vehicles from repository', async () => {
      const mockVehicles: Vehicle[] = [
        {
          id: '1',
          marca: 'Toyota',
          modelo: 'Corolla',
          kms: 50000,
          kmsCambioAceite: 5000,
          tipoAceite: '5W-30',
          tipoDistribucion: 'cadena',
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ];

      mockRepository.getAll.mockResolvedValue(mockVehicles);

      const result = await vehicleService.getAllVehicles();

      expect(mockRepository.getAll).toHaveBeenCalledTimes(1);
      expect(result).toEqual(mockVehicles);
    });

    it('should handle repository errors', async () => {
      const error = new Error('Repository error');
      mockRepository.getAll.mockRejectedValue(error);

      await expect(vehicleService.getAllVehicles()).rejects.toThrow('Repository error');
    });
  });

  describe('getVehicleById', () => {
    it('should return vehicle by id', async () => {
      const mockVehicle: Vehicle = {
        id: '1',
        marca: 'Toyota',
        modelo: 'Corolla',
        kms: 50000,
        kmsCambioAceite: 5000,
        tipoAceite: '5W-30',
        tipoDistribucion: 'cadena',
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockRepository.getById.mockResolvedValue(mockVehicle);

      const result = await vehicleService.getVehicleById('1');

      expect(mockRepository.getById).toHaveBeenCalledWith('1');
      expect(result).toEqual(mockVehicle);
    });

    it('should return null when vehicle not found', async () => {
      mockRepository.getById.mockResolvedValue(null);

      const result = await vehicleService.getVehicleById('999');

      expect(result).toBeNull();
    });
  });

  describe('createVehicle', () => {
    it('should create vehicle with valid data', async () => {
      const vehicleData: CreateVehicleData = {
        marca: 'Toyota',
        modelo: 'Corolla',
        kms: 50000,
        kmsCambioAceite: 5000,
        tipoAceite: '5W-30',
        tipoDistribucion: 'cadena',
      };

      const mockCreatedVehicle: Vehicle = {
        id: 'test-uuid-123',
        ...vehicleData,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockRepository.create.mockResolvedValue(mockCreatedVehicle);

      const result = await vehicleService.createVehicle(vehicleData);

      expect(mockRepository.create).toHaveBeenCalledWith(vehicleData);
      expect(result).toEqual(mockCreatedVehicle);
    });

    it('should validate required fields', async () => {
      const invalidData = {
        marca: '',
        modelo: '',
        kms: -1,
        kmsCambioAceite: 0,
        tipoAceite: '',
        tipoDistribucion: 'cadena' as const,
      };

      await expect(vehicleService.createVehicle(invalidData)).rejects.toThrow();
    });

    it('should validate correa distribution requires kmsCambioCorrea', async () => {
      const invalidData: CreateVehicleData = {
        marca: 'Toyota',
        modelo: 'Corolla',
        kms: 50000,
        kmsCambioAceite: 5000,
        tipoAceite: '5W-30',
        tipoDistribucion: 'correa',
        // Missing kmsCambioCorrea
      };

      await expect(vehicleService.createVehicle(invalidData)).rejects.toThrow();
    });
  });

  describe('updateVehicle', () => {
    it('should update vehicle with valid data', async () => {
      const updateData: UpdateVehicleData = {
        marca: 'Toyota Updated',
        kms: 60000,
      };

      const mockUpdatedVehicle: Vehicle = {
        id: '1',
        marca: 'Toyota Updated',
        modelo: 'Corolla',
        kms: 60000,
        kmsCambioAceite: 5000,
        tipoAceite: '5W-30',
        tipoDistribucion: 'cadena',
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockRepository.update.mockResolvedValue(mockUpdatedVehicle);

      const result = await vehicleService.updateVehicle('1', updateData);

      expect(mockRepository.update).toHaveBeenCalledWith('1', updateData);
      expect(result).toEqual(mockUpdatedVehicle);
    });

    it('should validate kms cannot be negative', async () => {
      const invalidData: UpdateVehicleData = {
        kms: -1,
      };

      await expect(vehicleService.updateVehicle('1', invalidData)).rejects.toThrow();
    });
  });

  describe('deleteVehicle', () => {
    it('should delete vehicle successfully', async () => {
      mockRepository.delete.mockResolvedValue(true);

      const result = await vehicleService.deleteVehicle('1');

      expect(mockRepository.delete).toHaveBeenCalledWith('1');
      expect(result).toBe(true);
    });

    it('should return false when deletion fails', async () => {
      mockRepository.delete.mockResolvedValue(false);

      const result = await vehicleService.deleteVehicle('1');

      expect(result).toBe(false);
    });
  });
});
