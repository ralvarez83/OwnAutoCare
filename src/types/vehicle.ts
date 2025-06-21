export interface Vehicle {
  id: string;
  marca: string;
  modelo: string;
  kms: number;
  kmsCambioAceite: number;
  tipoAceite: string;
  tipoDistribucion: 'correa' | 'cadena';
  kmsCambioCorrea?: number; // Solo si tiene correa
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateVehicleData {
  marca: string;
  modelo: string;
  kms: number;
  kmsCambioAceite: number;
  tipoAceite: string;
  tipoDistribucion: 'correa' | 'cadena';
  kmsCambioCorrea?: number;
}

export interface UpdateVehicleData extends Partial<CreateVehicleData> {
  // No requiere id porque se pasa por separado al método updateVehicle
}
