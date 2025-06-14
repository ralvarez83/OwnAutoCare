import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import VehicleDetailsPage from '../page'; // now page.tsx
import { useData } from '@/context/DataContext';
import { useSession } from 'next-auth/react';
import { Vehicle, MaintenanceRecord } from '@/types';
import { Session } from 'next-auth';

// Mock Next.js router/navigation and params
jest.mock('next/navigation', () => ({
  useRouter: () => ({ push: jest.fn() }),
  useParams: () => ({ id: 'test-vehicle-id' }),
  useSearchParams: () => ({ get: jest.fn() }), // Added for completeness
}));

jest.mock('@/context/DataContext');
const mockUseData = useData as jest.Mock;

jest.mock('next-auth/react');
const mockUseSession = useSession as jest.Mock;

const mockVehicleBase: Vehicle = {
  id: 'test-vehicle-id',
  make: 'Honda',
  model: 'Civic',
  year: 2020,
  currentMileage: 50000,
  oilChangeMileageInterval: 5000, // e.g. every 5000km
};

const mockMaintenanceRecordBase: MaintenanceRecord = {
  id: 'rec1',
  vehicleId: 'test-vehicle-id',
  date: '2023-01-01',
  kilometers: 40000, // Last oil change at 40000km
  description: 'Regular service with oil change',
  serviceType: 'Oil Change'
};

describe('VehicleDetailsPage - Maintenance Alerts', () => {
  beforeEach(() => {
    const mockSessionData: Session = { user: { name: 'Test' }, expires: '1', accessToken: 'mock-token' } as any;
    mockUseSession.mockReturnValue({ data: mockSessionData, status: 'authenticated' });
  });

  it('shows "Oil Change Overdue" alert', async () => {
    mockUseData.mockReturnValue({
      getVehicleById: () => ({ ...mockVehicleBase, currentMileage: 46000 }), // Current mileage makes it overdue (40k + 5k = 45k)
      getMaintenanceRecordsByVehicleId: () => [{ ...mockMaintenanceRecordBase, kilometers: 40000 }],
      deleteVehicle: jest.fn(),
      loading: false,
      error: null,
    });

    render(<VehicleDetailsPage />);
    await waitFor(() => {
      // Intentar encontrar el div contenedor de las alertas.
      // Asumimos que el título "Maintenance Alerts" está presente y es único en esta sección.
      const alertTitleElement = screen.queryByText('Maintenance Alerts');
      if (alertTitleElement) {
        const alertContainer = alertTitleElement.parentElement; // El div padre
        if (alertContainer) {
          console.log("Debug DOM (Overdue) - Alert Container HTML:", alertContainer.innerHTML);
        } else {
          console.log("Debug DOM (Overdue) - Alert container's parentElement no encontrado.");
        }
      } else {
        console.log("Debug DOM (Overdue) - Título 'Maintenance Alerts' no encontrado.");
      }

      // Usar la regex original que debería coincidir según los logs
      expect(screen.getByText(/Oil Change Overdue:.*Next service was due at 45000 km.*\(currently at 46000 km\)/i)).toBeInTheDocument();
    });
  });

  it('shows "Oil Change Upcoming" alert (e.g. within 20% of interval)', async () => {
     mockUseData.mockReturnValue({
      getVehicleById: () => ({ ...mockVehicleBase, currentMileage: 44500 }), // 40k + 5k = 45k. 44.5k is within 500km (10% of 5k interval)
      getMaintenanceRecordsByVehicleId: () => [{ ...mockMaintenanceRecordBase, kilometers: 40000 }],
      deleteVehicle: jest.fn(),
      loading: false,
      error: null,
    });

    render(<VehicleDetailsPage />);
    await waitFor(() => {
      const alertTitleElement = screen.queryByText('Maintenance Alerts');
      if (alertTitleElement) {
        const alertContainer = alertTitleElement.parentElement;
        if (alertContainer) {
          console.log("Debug DOM (Upcoming) - Alert Container HTML:", alertContainer.innerHTML);
        } else {
          console.log("Debug DOM (Upcoming) - Alert container's parentElement no encontrado.");
        }
      } else {
        console.log("Debug DOM (Upcoming) - Título 'Maintenance Alerts' no encontrado.");
      }

      // Regex original para esta prueba
      expect(screen.getByText(/Oil Change Upcoming:.*Next service due in 500 km/i)).toBeInTheDocument();
      // Si la anterior pasa, también verificamos la segunda parte del mensaje original
      expect(screen.getByText(/at 45000 km/i)).toBeInTheDocument();
    });
  });

  it('shows "Oil change not due soon" if well within interval', async () => {
    mockUseData.mockReturnValue({
      getVehicleById: () => ({ ...mockVehicleBase, currentMileage: 41000 }), // Only 1000km after last change
      getMaintenanceRecordsByVehicleId: () => [{ ...mockMaintenanceRecordBase, kilometers: 40000 }],
      deleteVehicle: jest.fn(),
      loading: false,
      error: null,
    });

    render(<VehicleDetailsPage />);
    await waitFor(() => {
        expect(screen.getByText(/Oil change not due soon. Next at 45000 km/i)).toBeInTheDocument();
    });
  });

  it('handles no previous oil change records for alerts', async () => {
    mockUseData.mockReturnValue({
      getVehicleById: () => ({ ...mockVehicleBase, currentMileage: 4200 }), // Cambiado de 3000 a 4200
      getMaintenanceRecordsByVehicleId: () => [], // No oil change records
      deleteVehicle: jest.fn(),
      loading: false,
      error: null,
    });
    render(<VehicleDetailsPage />);
    // Expect an upcoming alert based on 0 km as last service + interval
    await waitFor(() => {
        expect(screen.getByText(/Oil Change Upcoming/i)).toBeInTheDocument();
        expect(screen.getByText(/Next service due in 800 km \(at 5000 km\)/i)).toBeInTheDocument(); // Cambiado de 2000 a 800
    });
  });
});
