import { Injectable } from '@angular/core';
import { VehicleTypes } from '../models/VehicleTypes';
import { Vehicle } from '../models/Vehicle';

@Injectable({
  providedIn: 'root',
})
export class VehicleService {
  // private vehicles: Vehicle[] = [
  //   { id: 1, name: 'Coche 1', type: VehicleTypes.Car },
  //   { id: 2, name: 'Moto 1', type: VehicleTypes.Motorcycle },
  //   // Agrega más vehículos según sea necesario
  // ];

  private vehicles: Vehicle[] = [];
  constructor() {}

  getVehicles(): Vehicle[] {
    return this.vehicles;
  }
}
