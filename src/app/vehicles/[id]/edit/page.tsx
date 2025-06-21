'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { useSession } from 'next-auth/react';
import { Vehicle, CreateVehicleData } from '@/types/vehicle';
import { VehicleForm } from '@/components/VehicleForm';
import { GoogleLoginButton } from '@/components/GoogleLoginButton';
import { vehicleService } from '@/services/vehicleServiceInstance';

export default function EditVehiclePage() {
  const { data: session, status } = useSession();
  const router = useRouter();
  const params = useParams();
  const id = params.id as string;

  const [vehicle, setVehicle] = useState<Vehicle | null>(null);
  const [loading, setLoading] = useState(false);
  const [initialLoading, setInitialLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (status === 'loading') return;

    if (!session) {
      router.push('/');
      return;
    }

    loadVehicle();
  }, [session, status, router, id]);

  const loadVehicle = async () => {
    try {
      setInitialLoading(true);
      setError(null);
      const vehicleData = await vehicleService.getVehicleById(id);
      if (!vehicleData) {
        setError('Vehículo no encontrado');
        setTimeout(() => router.push('/vehicles'), 2000);
        return;
      }
      setVehicle(vehicleData);
    } catch (error) {
      console.error('Error loading vehicle:', error);
      setError(error instanceof Error ? error.message : 'Error al cargar el vehículo');
      setTimeout(() => router.push('/vehicles'), 2000);
    } finally {
      setInitialLoading(false);
    }
  };

  const handleSubmit = async (data: CreateVehicleData) => {
    try {
      setLoading(true);
      setError(null);
      const success = await vehicleService.updateVehicle(id, data);

      if (success) {
        router.push('/vehicles');
      } else {
        setError('Error al actualizar el vehículo');
      }
    } catch (error) {
      console.error('Error updating vehicle:', error);
      setError(
        error instanceof Error
          ? error.message
          : 'Error al actualizar el vehículo. Por favor, inténtalo de nuevo.'
      );
    } finally {
      setLoading(false);
    }
  };

  const handleCancel = () => {
    router.push('/vehicles');
  };

  if (status === 'loading' || initialLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-xl">Cargando vehículo...</div>
      </div>
    );
  }

  if (!session) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center p-24">
        <h1 className="text-4xl font-bold mb-8">Editar Vehículo</h1>
        <p className="text-xl mb-4">Por favor, inicia sesión para continuar</p>
        <GoogleLoginButton />
      </div>
    );
  }

  if (!vehicle) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-xl">{error || 'Vehículo no encontrado'}</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 pt-16">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Editar Vehículo</h1>
          <p className="text-gray-600 mt-2">Modifica la información de tu vehículo</p>
        </div>

        {error && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-md">
            <p className="text-red-800">{error}</p>
          </div>
        )}

        <div className="bg-white rounded-lg shadow-md p-6">
          <VehicleForm
            vehicle={vehicle}
            onSubmit={handleSubmit}
            onCancel={handleCancel}
            loading={loading}
          />
        </div>
      </div>
    </div>
  );
}
