import { Vehicle, CreateVehicleData, UpdateVehicleData } from '@/types/vehicle';
import { IVehicleRepository } from '@/repositories/IVehicleRepository';

export class VehicleService {
  private repository: IVehicleRepository;

  constructor(repository: IVehicleRepository) {
    this.repository = repository;
  }

  async getAllVehicles(): Promise<Vehicle[]> {
    return this.repository.getAll();
  }

  async getVehicleById(id: string): Promise<Vehicle | null> {
    if (!id || id.trim() === '') {
      throw new Error('Vehicle ID is required');
    }
    return this.repository.getById(id);
  }

  async createVehicle(data: CreateVehicleData): Promise<Vehicle> {
    // Validaciones de negocio
    this.validateVehicleData(data);

    return this.repository.create(data);
  }

  async updateVehicle(id: string, data: UpdateVehicleData): Promise<Vehicle | null> {
    if (!id || id.trim() === '') {
      throw new Error('Vehicle ID is required');
    }

    // Validaciones de negocio
    if (data.marca !== undefined) this.validateMarca(data.marca);
    if (data.modelo !== undefined) this.validateModelo(data.modelo);
    if (data.kms !== undefined) this.validateKms(data.kms);
    if (data.kmsCambioAceite !== undefined) this.validateKmsCambioAceite(data.kmsCambioAceite);
    if (data.tipoAceite !== undefined) this.validateTipoAceite(data.tipoAceite);
    if (data.kmsCambioCorrea !== undefined) this.validateKmsCambioCorrea(data.kmsCambioCorrea);

    return this.repository.update(id, data);
  }

  async deleteVehicle(id: string): Promise<boolean> {
    if (!id || id.trim() === '') {
      throw new Error('Vehicle ID is required');
    }
    return this.repository.delete(id);
  }

  // Validaciones de negocio
  private validateVehicleData(data: CreateVehicleData): void {
    this.validateMarca(data.marca);
    this.validateModelo(data.modelo);
    this.validateKms(data.kms);
    this.validateKmsCambioAceite(data.kmsCambioAceite);
    this.validateTipoAceite(data.tipoAceite);

    if (
      data.tipoDistribucion === 'correa' &&
      (!data.kmsCambioCorrea || data.kmsCambioCorrea <= 0)
    ) {
      throw new Error(
        'Los kilómetros para cambio de correa son obligatorios cuando el tipo de distribución es correa'
      );
    }
  }

  private validateMarca(marca: string): void {
    if (!marca || marca.trim() === '') {
      throw new Error('La marca es obligatoria');
    }
    if (marca.length > 50) {
      throw new Error('La marca no puede tener más de 50 caracteres');
    }
  }

  private validateModelo(modelo: string): void {
    if (!modelo || modelo.trim() === '') {
      throw new Error('El modelo es obligatorio');
    }
    if (modelo.length > 50) {
      throw new Error('El modelo no puede tener más de 50 caracteres');
    }
  }

  private validateKms(kms: number): void {
    if (kms < 0) {
      throw new Error('Los kilómetros no pueden ser negativos');
    }
    if (kms > 9999999) {
      throw new Error('Los kilómetros no pueden ser mayores a 9,999,999');
    }
  }

  private validateKmsCambioAceite(kms: number): void {
    if (kms <= 0) {
      throw new Error('Los kilómetros para cambio de aceite deben ser mayores a 0');
    }
    if (kms > 100000) {
      throw new Error('Los kilómetros para cambio de aceite no pueden ser mayores a 100,000');
    }
  }

  private validateTipoAceite(tipoAceite: string): void {
    if (!tipoAceite || tipoAceite.trim() === '') {
      throw new Error('El tipo de aceite es obligatorio');
    }
    if (tipoAceite.length > 20) {
      throw new Error('El tipo de aceite no puede tener más de 20 caracteres');
    }
  }

  private validateKmsCambioCorrea(kms: number): void {
    if (kms <= 0) {
      throw new Error('Los kilómetros para cambio de correa deben ser mayores a 0');
    }
    if (kms > 200000) {
      throw new Error('Los kilómetros para cambio de correa no pueden ser mayores a 200,000');
    }
  }
}
