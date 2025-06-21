import { VehicleService } from './VehicleService';
import { GoogleDriveVehicleRepository } from '@/repositories/GoogleDriveVehicleRepository';

// Crear una instancia del repositorio de Google Drive
const vehicleRepository = new GoogleDriveVehicleRepository();

// Crear una instancia del servicio usando el repositorio
export const vehicleService = new VehicleService(vehicleRepository);
