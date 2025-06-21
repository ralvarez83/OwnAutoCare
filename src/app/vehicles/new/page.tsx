'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useSession } from 'next-auth/react';
import { CreateVehicleData } from '@/types/vehicle';
import { VehicleForm } from '@/components/VehicleForm';
import { GoogleLoginButton } from '@/components/GoogleLoginButton';
import { vehicleService } from '@/services/vehicleServiceInstance';

export default function NewVehiclePage() {
  const { data: session, status } = useSession();
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (data: CreateVehicleData) => {
    try {
      setLoading(true);
      setError(null);
      await vehicleService.createVehicle(data);
      router.push('/vehicles');
    } catch (error) {
      console.error('Error creating vehicle:', error);
      setError(
        error instanceof Error
          ? error.message
          : 'Error al crear el vehículo. Por favor, inténtalo de nuevo.'
      );
    } finally {
      setLoading(false);
    }
  };

  const handleCancel = () => {
    router.push('/vehicles');
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
        <h1 className="text-4xl font-bold mb-8">Añadir Vehículo</h1>
        <p className="text-xl mb-4">Por favor, inicia sesión para continuar</p>
        <GoogleLoginButton />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 pt-16">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Añadir Nuevo Vehículo</h1>
          <p className="text-gray-600 mt-2">
            Completa la información de tu vehículo para gestionar su mantenimiento
          </p>
        </div>

        {error && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-md">
            <p className="text-red-800">{error}</p>
          </div>
        )}

        <div className="bg-white rounded-lg shadow-md p-6">
          <VehicleForm onSubmit={handleSubmit} onCancel={handleCancel} loading={loading} />
        </div>
      </div>
    </div>
  );
}
