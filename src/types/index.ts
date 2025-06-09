export interface ItemizedCost {
  id: string;
  name: string;
  cost: number;
}

export interface MaintenanceRecord {
  id: string;
  vehicleId: string;
  date: string;
  kilometers: number; // Mileage at the time of this service
  description: string;
  serviceType?: string; // e.g., 'Oil Change', 'Tire Rotation' - for more specific tracking
  totalCost?: number;
  itemizedCosts?: ItemizedCost[];
}

export interface Vehicle {
  id: string;
  make: string;
  model: string;
  year: number;
  licensePlate?: string;
  vin?: string;
  photoUrl?: string;

  currentMileage?: number; // Current odometer reading for the vehicle

  // Service interval preferences
  oilChangeMileageInterval?: number; // e.g., every 5000 km
  // To track last service for interval calculations, we'd ideally store the mileage
  // of the last specific service type. For now, we'll infer from maintenance records.
  // A more robust approach would be:
  // lastOilChangeServiceMileage?: number;
  // lastTimingBeltServiceMileage?: number;

  timingBeltMileageInterval?: number;
  tireRotationInterval?: number; // Could be km or months
  // Add more specific fields as needed

  notes?: string;
}

export interface AppData {
  vehicles: Vehicle[];
  maintenanceRecords: MaintenanceRecord[];
}
