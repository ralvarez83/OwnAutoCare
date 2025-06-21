'use client';

import { Vehicle } from '@/types/vehicle';
import { Button } from './Button';

interface VehicleCardProps {
  vehicle: Vehicle;
  onEdit?: (vehicle: Vehicle) => void;
  onDelete?: (id: string) => void;
}

export function VehicleCard({ vehicle, onEdit, onDelete }: VehicleCardProps) {
  const handleEdit = () => {
    onEdit?.(vehicle);
  };

  const handleDelete = () => {
    if (confirm('¿Estás seguro de que quieres eliminar este vehículo?')) {
      onDelete?.(vehicle.id);
    }
  };

  return (
    <div className="bg-white rounded-lg shadow-md p-6 border border-gray-200 hover:shadow-lg transition-shadow">
      <div className="flex justify-between items-start mb-4">
        <div>
          <h3 className="text-xl font-semibold text-gray-900">
            {vehicle.marca} {vehicle.modelo}
          </h3>
          <p className="text-sm text-gray-500">ID: {vehicle.id.slice(0, 8)}...</p>
        </div>
        <div className="flex gap-2">
          {onEdit && (
            <Button onClick={handleEdit} variant="secondary" size="sm">
              Editar
            </Button>
          )}
          {onDelete && (
            <Button onClick={handleDelete} variant="danger" size="sm">
              Eliminar
            </Button>
          )}
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4 text-sm">
        <div>
          <span className="font-medium text-gray-700">Kilometraje:</span>
          <p className="text-gray-900">{vehicle.kms.toLocaleString()} km</p>
        </div>

        <div>
          <span className="font-medium text-gray-700">Tipo de distribución:</span>
          <p className="text-gray-900 capitalize">{vehicle.tipoDistribucion}</p>
        </div>

        <div>
          <span className="font-medium text-gray-700">Cambio de aceite:</span>
          <p className="text-gray-900">{vehicle.kmsCambioAceite.toLocaleString()} km</p>
        </div>

        <div>
          <span className="font-medium text-gray-700">Tipo de aceite:</span>
          <p className="text-gray-900">{vehicle.tipoAceite}</p>
        </div>

        {vehicle.tipoDistribucion === 'correa' && vehicle.kmsCambioCorrea && (
          <div className="col-span-2">
            <span className="font-medium text-gray-700">Cambio de correa:</span>
            <p className="text-gray-900">{vehicle.kmsCambioCorrea.toLocaleString()} km</p>
          </div>
        )}
      </div>

      <div className="mt-4 pt-4 border-t border-gray-200">
        <p className="text-xs text-gray-500">Creado: {vehicle.createdAt.toLocaleDateString()}</p>
        <p className="text-xs text-gray-500">
          Actualizado: {vehicle.updatedAt.toLocaleDateString()}
        </p>
      </div>
    </div>
  );
}
