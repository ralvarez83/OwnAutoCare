'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Vehicle, CreateVehicleData } from '@/types/vehicle';
import { Button } from './Button';

// Esquema de validación declarativo con Zod
const vehicleFormSchema = z.object({
  marca: z
    .string()
    .min(1, 'La marca es obligatoria')
    .min(2, 'La marca debe tener al menos 2 caracteres')
    .max(50, 'La marca no puede exceder 50 caracteres')
    .trim(),

  modelo: z
    .string()
    .min(1, 'El modelo es obligatorio')
    .min(2, 'El modelo debe tener al menos 2 caracteres')
    .max(50, 'El modelo no puede exceder 50 caracteres')
    .trim(),

  kms: z
    .preprocess((v) => v === '' ? undefined : v, z
      .number({ invalid_type_error: 'El kilometraje debe ser un número' })
      .min(0, 'Los kilómetros no pueden ser negativos')
      .max(999999, 'El kilometraje no puede exceder 999,999 km')
    ).optional(),

  kmsCambioAceite: z
    .preprocess((v) => v === '' ? undefined : v, z
      .number({ invalid_type_error: 'Los kilómetros para cambio de aceite deben ser un número' })
      .min(1, 'Los kilómetros para cambio de aceite deben ser mayores a 0')
      .max(50000, 'Los kilómetros para cambio de aceite no pueden exceder 50,000 km')
    ).optional(),

  tipoAceite: z
    .string()
    .trim()
    .optional()
    .refine(
      (val) => !val || /^[0-9]+W-[0-9]+$/.test(val),
      { message: 'Formato inválido. Use formato como: 5W-30, 10W-40' }
    ),

  tipoDistribucion: z.enum(['cadena', 'correa']).optional(),

  kmsCambioCorrea: z
    .preprocess((v) => v === '' ? undefined : v, z
      .number({ invalid_type_error: 'Los kilómetros para cambio de correa deben ser un número' })
      .min(1, 'Los kilómetros para cambio de correa deben ser mayores a 0')
      .max(200000, 'Los kilómetros para cambio de correa no pueden exceder 200,000 km')
    ).optional(),
}).refine((data) => {
  // Si tipoDistribucion es correa, kmsCambioCorrea debe estar presente y ser válido
  if (data.tipoDistribucion === 'correa') {
    return data.kmsCambioCorrea !== undefined && data.kmsCambioCorrea > 0;
  }
  return true;
}, {
  message: 'Los kilómetros para cambio de correa son obligatorios cuando el tipo de distribución es correa',
  path: ['kmsCambioCorrea']
}).refine((data) => {
  // Si ambos están presentes, kmsCambioAceite debe ser menor que kmsCambioCorrea
  if (
    data.tipoDistribucion === 'correa' &&
    data.kmsCambioCorrea !== undefined &&
    data.kmsCambioAceite !== undefined
  ) {
    return data.kmsCambioAceite < data.kmsCambioCorrea;
  }
  return true;
}, {
  message: 'Los kilómetros para cambio de aceite deben ser menores que los kilómetros para cambio de correa',
  path: ['kmsCambioAceite']
});

type VehicleFormData = z.infer<typeof vehicleFormSchema>;

interface VehicleFormProps {
  vehicle?: Vehicle;
  onSubmit: (data: CreateVehicleData) => void;
  onCancel: () => void;
  loading?: boolean;
}

export function VehicleForm({ vehicle, onSubmit, onCancel, loading = false }: VehicleFormProps) {
  const {
    register,
    handleSubmit,
    watch,
    formState: { errors, isSubmitting },
    reset
  } = useForm<VehicleFormData>({
    resolver: zodResolver(vehicleFormSchema),
    defaultValues: {
      marca: vehicle?.marca || '',
      modelo: vehicle?.modelo || '',
      kms: vehicle?.kms || 0,
      kmsCambioAceite: vehicle?.kmsCambioAceite || 5000,
      tipoAceite: vehicle?.tipoAceite || '',
      tipoDistribucion: vehicle?.tipoDistribucion || 'cadena',
      kmsCambioCorrea: vehicle?.kmsCambioCorrea || undefined,
    },
    mode: 'onChange' // Validación en tiempo real
  });

  const tipoDistribucion = watch('tipoDistribucion');

  const onSubmitForm = (data: VehicleFormData) => {
    const submitData: CreateVehicleData = {
      ...data,
      // Solo incluir kmsCambioCorrea si es correa
      kmsCambioCorrea: data.tipoDistribucion === 'correa' ? data.kmsCambioCorrea : undefined
    };
    onSubmit(submitData);
  };

  return (
    <form onSubmit={handleSubmit(onSubmitForm)} className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Marca */}
        <div>
          <label htmlFor="marca" className="block text-sm font-medium text-gray-700 mb-2">
            Marca *
          </label>
          <input
            type="text"
            id="marca"
            {...register('marca')}
            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
              errors.marca ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="Ej: Toyota, Ford, BMW..."
          />
          {errors.marca && (
            <p className="mt-1 text-sm text-red-600">{errors.marca.message}</p>
          )}
        </div>

        {/* Modelo */}
        <div>
          <label htmlFor="modelo" className="block text-sm font-medium text-gray-700 mb-2">
            Modelo *
          </label>
          <input
            type="text"
            id="modelo"
            {...register('modelo')}
            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
              errors.modelo ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="Ej: Corolla, Focus, X3..."
          />
          {errors.modelo && (
            <p className="mt-1 text-sm text-red-600">{errors.modelo.message}</p>
          )}
        </div>

        {/* Kilometraje */}
        <div>
          <label htmlFor="kms" className="block text-sm font-medium text-gray-700 mb-2">
            Kilometraje actual *
          </label>
          <input
            type="number"
            id="kms"
            {...register('kms', { valueAsNumber: true })}
            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
              errors.kms ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="0"
            min="0"
          />
          {errors.kms && (
            <p className="mt-1 text-sm text-red-600">{errors.kms.message}</p>
          )}
        </div>

        {/* Kilómetros para cambio de aceite */}
        <div>
          <label htmlFor="kmsCambioAceite" className="block text-sm font-medium text-gray-700 mb-2">
            Kms para cambio de aceite *
          </label>
          <input
            type="number"
            id="kmsCambioAceite"
            {...register('kmsCambioAceite', { valueAsNumber: true })}
            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
              errors.kmsCambioAceite ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="5000"
            min="1"
          />
          {errors.kmsCambioAceite && (
            <p className="mt-1 text-sm text-red-600">{errors.kmsCambioAceite.message}</p>
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
            {...register('tipoAceite')}
            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
              errors.tipoAceite ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="Ej: 5W-30, 10W-40..."
          />
          {errors.tipoAceite && (
            <p className="mt-1 text-sm text-red-600">{errors.tipoAceite.message}</p>
          )}
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
            {...register('tipoDistribucion')}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="cadena">Cadena</option>
            <option value="correa">Correa</option>
          </select>
          {errors.tipoDistribucion && (
            <p className="mt-1 text-sm text-red-600">{errors.tipoDistribucion.message}</p>
          )}
        </div>
      </div>

      {/* Kilómetros para cambio de correa (solo si es correa) */}
      {tipoDistribucion === 'correa' && (
        <div>
          <label htmlFor="kmsCambioCorrea" className="block text-sm font-medium text-gray-700 mb-2">
            Kms para cambio de correa *
          </label>
          <input
            type="number"
            id="kmsCambioCorrea"
            {...register('kmsCambioCorrea', { valueAsNumber: true })}
            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
              errors.kmsCambioCorrea ? 'border-red-500' : 'border-gray-300'
            }`}
            placeholder="60000"
            min="1"
          />
          {errors.kmsCambioCorrea && (
            <p className="mt-1 text-sm text-red-600">{errors.kmsCambioCorrea.message}</p>
          )}
        </div>
      )}

      {/* Botones */}
      <div className="flex justify-end space-x-4 pt-6">
        <Button
          type="button"
          variant="secondary"
          onClick={onCancel}
          disabled={loading || isSubmitting}
        >
          Cancelar
        </Button>
        <Button
          type="submit"
          disabled={loading || isSubmitting}
        >
          {loading || isSubmitting
            ? 'Guardando...'
            : vehicle
              ? 'Actualizar Vehículo'
              : 'Crear Vehículo'
          }
        </Button>
      </div>
    </form>
  );
}
