import { Vehicle, CreateVehicleData, UpdateVehicleData } from '@/types/vehicle';

export interface IVehicleRepository {
  getAll(): Promise<Vehicle[]>;
  getById(id: string): Promise<Vehicle | null>;
  create(data: CreateVehicleData): Promise<Vehicle>;
  update(id: string, data: UpdateVehicleData): Promise<Vehicle | null>;
  delete(id: string): Promise<boolean>;
}
