import { Vehicle, CreateVehicleData, UpdateVehicleData } from '@/types/vehicle';
import { IVehicleRepository } from './IVehicleRepository';

export class GoogleDriveVehicleRepository implements IVehicleRepository {
  async getAll(): Promise<Vehicle[]> {
    try {
      const response = await fetch('/api/vehicles');
      if (!response.ok) {
        throw new Error('Failed to fetch vehicles');
      }
      const data = await response.json();
      return data.vehicles || [];
    } catch (error) {
      console.error('Error fetching vehicles:', error);
      return [];
    }
  }

  async getById(id: string): Promise<Vehicle | null> {
    try {
      const vehicles = await this.getAll();
      return vehicles.find(v => v.id === id) || null;
    } catch (error) {
      console.error('Error fetching vehicle by id:', error);
      return null;
    }
  }

  async create(data: CreateVehicleData): Promise<Vehicle> {
    try {
      const response = await fetch('/api/vehicles', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
      });

      if (!response.ok) {
        throw new Error('Failed to create vehicle');
      }

      const result = await response.json();
      return result.vehicle;
    } catch (error) {
      console.error('Error creating vehicle:', error);
      throw error;
    }
  }

  async update(id: string, data: UpdateVehicleData): Promise<Vehicle | null> {
    try {
      const response = await fetch(`/api/vehicles/${id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
      });

      if (!response.ok) {
        throw new Error('Failed to update vehicle');
      }

      const result = await response.json();
      return result.vehicle;
    } catch (error) {
      console.error('Error updating vehicle:', error);
      throw error;
    }
  }

  async delete(id: string): Promise<boolean> {
    try {
      const response = await fetch(`/api/vehicles/${id}`, {
        method: 'DELETE',
      });

      if (!response.ok) {
        throw new Error('Failed to delete vehicle');
      }

      return true;
    } catch (error) {
      console.error('Error deleting vehicle:', error);
      return false;
    }
  }
}
