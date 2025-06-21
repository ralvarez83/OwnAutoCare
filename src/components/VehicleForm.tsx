'use client';

import { useState, useEffect } from 'react';
import { Vehicle, CreateVehicleData } from '@/types/vehicle';
import { Button } from './Button';

interface VehicleFormProps {
  vehicle?: Vehicle;
  onSubmit: (data: CreateVehicleData) => void;
  onCancel: () => void;
  loading?: boolean;
}

export function VehicleForm({ vehicle, onSubmit, onCancel, loading = false }: VehicleFormProps) {
  const [formData, setFormData] = useState<CreateVehicleData>({
    marca: '',
    modelo: '',
    kms: 0,
    kmsCambioAceite: 0,
    tipoAceite: '',
    tipoDistribucion: 'cadena',
    kmsCambioCorrea: undefined,
  });

  const [errors, setErrors] = useState<Partial<Record<keyof CreateVehicleData, string>>>({});

  useEffect(() => {
    if (vehicle) {
      setFormData({
        marca: vehicle.marca,
        modelo: vehicle.modelo,
        kms: vehicle.kms,
        kmsCambioAceite: vehicle.kmsCambioAceite,
        tipoAceite: vehicle.tipoAceite,
        tipoDistribucion: vehicle.tipoDistribucion,
        kmsCambioCorrea: vehicle.kmsCambioCorrea,
      });
    }
  }, [vehicle]);

  const validateForm = (): boolean => {
    const newErrors: Partial<Record<keyof CreateVehicleData, string>> = {};

    if (!formData.marca.trim()) {
      newErrors.marca = 'La marca es obligatoria';
    }

    if (!formData.modelo.trim()) {
      newErrors.modelo = 'El modelo es obligatorio';
    }

    if (formData.kms < 0) {
      newErrors.kms = 'Los kilómetros no pueden ser negativos';
    }

    if (formData.kmsCambioAceite <= 0) {
      newErrors.kmsCambioAceite = 'Los kilómetros para cambio de aceite deben ser mayores a 0';
    }

    if (!formData.tipoAceite.trim()) {
      newErrors.tipoAceite = 'El tipo de aceite es obligatorio';
    }

    if (
      formData.tipoDistribucion === 'correa' &&
      (!formData.kmsCambioCorrea || formData.kmsCambioCorrea <= 0)
    ) {
      newErrors.kmsCambioCorrea = 'Los kilómetros para cambio de correa son obligatorios';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (validateForm()) {
      const submitData = { ...formData };
      if (submitData.tipoDistribucion === 'cadena') {
        delete submitData.kmsCambioCorrea;
      }
      onSubmit(submitData);
    }
  };

  const handleInputChange = (field: keyof CreateVehicleData, value: string | number) => {
    setFormData(prev => ({
      ...prev,
      [field]: value,
    }));

    // Clear error when user starts typing
    if (errors[field]) {
      setErrors(prev => ({
        ...prev,
        [field]: undefined,
      }));
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Marca */}
        <div>
          <label htmlFor="marca" className="block text-sm font-medium text-gray-700 mb-2">
            Marca *
          </label>
          <input
            type="text"
            id="marca"
            value={formData.marca}
            onChange={e => handleInputChange('marca', e.target.value)}
            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
              errors.marca ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="Ej: Toyota, Ford, BMW..."
          />
          {errors.marca && <p className="mt-1 text-sm text-red-600">{errors.marca}</p>}
        </div>

        {/* Modelo */}
        <div>
          <label htmlFor="modelo" className="block text-sm font-medium text-gray-700 mb-2">
            Modelo *
          </label>
          <input
            type="text"
            id="modelo"
            value={formData.modelo}
            onChange={e => handleInputChange('modelo', e.target.value)}
            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
              errors.modelo ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="Ej: Corolla, Focus, X3..."
          />
          {errors.modelo && <p className="mt-1 text-sm text-red-600">{errors.modelo}</p>}
        </div>

        {/* Kilometraje */}
        <div>
          <label htmlFor="kms" className="block text-sm font-medium text-gray-700 mb-2">
            Kilometraje actual *
          </label>
          <input
            type="number"
            id="kms"
            value={formData.kms}
            onChange={e => handleInputChange('kms', parseInt(e.target.value) || 0)}
            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
              errors.kms ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="0"
            min="0"
          />
          {errors.kms && <p className="mt-1 text-sm text-red-600">{errors.kms}</p>}
        </div>

        {/* Kilómetros para cambio de aceite */}
        <div>
          <label htmlFor="kmsCambioAceite" className="block text-sm font-medium text-gray-700 mb-2">
            Kms para cambio de aceite *
          </label>
          <input
            type="number"
            id="kmsCambioAceite"
            value={formData.kmsCambioAceite}
            onChange={e => handleInputChange('kmsCambioAceite', parseInt(e.target.value) || 0)}
            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
              errors.kmsCambioAceite ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="5000"
            min="1"
          />
          {errors.kmsCambioAceite && (
            <p className="mt-1 text-sm text-red-600">{errors.kmsCambioAceite}</p>
          )}
        </div>

        {/* Tipo de aceite */}
        <div>
          <label htmlFor="tipoAceite" className="block text-sm font-medium text-gray-700 mb-2">
            Tipo de aceite *
          </label>
          <input
            type="text"
            id="tipoAceite"
            value={formData.tipoAceite}
            onChange={e => handleInputChange('tipoAceite', e.target.value)}
            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
              errors.tipoAceite ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="Ej: 5W-30, 10W-40..."
          />
          {errors.tipoAceite && <p className="mt-1 text-sm text-red-600">{errors.tipoAceite}</p>}
        </div>

        {/* Tipo de distribución */}
        <div>
          <label
            htmlFor="tipoDistribucion"
            className="block text-sm font-medium text-gray-700 mb-2"
          >
            Tipo de distribución *
          </label>
          <select
            id="tipoDistribucion"
            value={formData.tipoDistribucion}
            onChange={e =>
              handleInputChange('tipoDistribucion', e.target.value as 'correa' | 'cadena')
            }
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="cadena">Cadena</option>
            <option value="correa">Correa</option>
          </select>
        </div>
      </div>

      {/* Kilómetros para cambio de correa (solo si es correa) */}
      {formData.tipoDistribucion === 'correa' && (
        <div>
          <label htmlFor="kmsCambioCorrea" className="block text-sm font-medium text-gray-700 mb-2">
            Kms para cambio de correa *
          </label>
          <input
            type="number"
            id="kmsCambioCorrea"
            value={formData.kmsCambioCorrea || ''}
            onChange={e => handleInputChange('kmsCambioCorrea', parseInt(e.target.value) || 0)}
            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
              errors.kmsCambioCorrea ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="60000"
            min="1"
          />
          {errors.kmsCambioCorrea && (
            <p className="mt-1 text-sm text-red-600">{errors.kmsCambioCorrea}</p>
          )}
        </div>
      )}

      {/* Botones */}
      <div className="flex justify-end space-x-4 pt-6">
        <Button type="button" variant="secondary" onClick={onCancel} disabled={loading}>
          Cancelar
        </Button>
        <Button type="submit" disabled={loading}>
          {loading ? 'Guardando...' : vehicle ? 'Actualizar Vehículo' : 'Crear Vehículo'}
        </Button>
      </div>
    </form>
  );
}
