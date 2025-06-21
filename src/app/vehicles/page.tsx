'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useSession } from 'next-auth/react';
import { Vehicle } from '@/types/vehicle';
import { VehicleCard } from '@/components/VehicleCard';
import { Button } from '@/components/Button';
import { GoogleLoginButton } from '@/components/GoogleLoginButton';
import { vehicleService } from '@/services/vehicleServiceInstance';

export default function VehiclesPage() {
  const { data: session, status } = useSession();
  const router = useRouter();
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (status === 'loading') return;

    if (!session) {
      router.push('/');
      return;
    }

    loadVehicles();
  }, [session, status, router]);

  const loadVehicles = async () => {
    try {
      setLoading(true);
      setError(null);
      const vehiclesData = await vehicleService.getAllVehicles();
      setVehicles(vehiclesData);
    } catch (error) {
      console.error('Error loading vehicles:', error);
      setError('Error al cargar los vehículos. Por favor, inténtalo de nuevo.');
    } finally {
      setLoading(false);
    }
  };

  const handleAddVehicle = () => {
    router.push('/vehicles/new');
  };

  const handleEditVehicle = (vehicle: Vehicle) => {
    router.push(`/vehicles/${vehicle.id}/edit`);
  };

  const handleDeleteVehicle = async (id: string) => {
    try {
      const success = await vehicleService.deleteVehicle(id);
      if (success) {
        setVehicles(vehicles.filter(v => v.id !== id));
      } else {
        setError('Error al eliminar el vehículo');
      }
    } catch (error) {
      console.error('Error deleting vehicle:', error);
      setError('Error al eliminar el vehículo. Por favor, inténtalo de nuevo.');
    }
  };

  if (status === 'loading') {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-xl">Cargando...</div>
      </div>
    );
  }

  if (!session) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center p-24">
        <h1 className="text-4xl font-bold mb-8">Gestión de Vehículos</h1>
        <p className="text-xl mb-4">Por favor, inicia sesión para continuar</p>
        <GoogleLoginButton />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 pt-16">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Mis Vehículos</h1>
            <p className="text-gray-600 mt-2">Gestiona el mantenimiento de tus vehículos</p>
          </div>
          <Button onClick={handleAddVehicle} size="lg">
            + Añadir Vehículo
          </Button>
        </div>

        {error && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-md">
            <p className="text-red-800">{error}</p>
            <Button onClick={loadVehicles} variant="secondary" size="sm" className="mt-2">
              Reintentar
            </Button>
          </div>
        )}

        {loading ? (
          <div className="flex justify-center py-12">
            <div className="text-xl text-gray-600">Cargando vehículos...</div>
          </div>
        ) : vehicles.length === 0 ? (
          <div className="text-center py-12">
            <div className="text-gray-400 text-6xl mb-4">🚗</div>
            <h3 className="text-xl font-medium text-gray-900 mb-2">
              No tienes vehículos registrados
            </h3>
            <p className="text-gray-600 mb-6">
              Comienza añadiendo tu primer vehículo para gestionar su mantenimiento
            </p>
            <Button onClick={handleAddVehicle}>Añadir mi primer vehículo</Button>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {vehicles.map(vehicle => (
              <VehicleCard
                key={vehicle.id}
                vehicle={vehicle}
                onEdit={handleEditVehicle}
                onDelete={handleDeleteVehicle}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
