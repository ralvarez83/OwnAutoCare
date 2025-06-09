import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import VehicleDetailsPage from '../page'; // Path to VehicleDetailsPage
import { useData } from '@/context/DataContext';
import { useSession } from 'next-auth/react'; // VehicleDetailsPage might use it indirectly via useData

// Mock Next.js router/navigation and params
jest.mock('next/navigation', () => ({
  useRouter: () => ({ push: jest.fn() }),
  useParams: () => ({ id: 'test-vehicle-id' }),
  useSearchParams: () => ({ get: jest.fn() }),
}));

jest.mock('@/context/DataContext');
jest.mock('next-auth/react'); // If useData or components it renders use session

const mockVehicle = {
  id: 'test-vehicle-id',
  make: 'Honda',
  model: 'Civic',
  year: 2020,
  currentMileage: 50000,
  oilChangeMileageInterval: 5000,
};

describe('VehicleDetailsPage - Maintenance Alerts', () => {
  beforeEach(() => {
    (useSession as jest.Mock).mockReturnValue({ data: { accessToken: 'fake-token' }, status: 'authenticated' });
  });

  it('shows "Oil Change Overdue" alert', async () => {
    (useData as jest.Mock).mockReturnValue({
      getVehicleById: () => mockVehicle,
      getMaintenanceRecordsByVehicleId: () => [
        { id: 'rec1', vehicleId: 'test-vehicle-id', date: '2023-01-01', kilometers: 40000, description: 'Oil change', serviceType: 'Oil Change' }
      ],
      deleteVehicle: jest.fn(),
      loading: false,
      error: null,
    });

    render(<VehicleDetailsPage />);
    // Using waitFor because chart rendering might involve async operations or state updates
    await waitFor(() => {
        expect(screen.getByText(/Oil Change Overdue/i)).toBeInTheDocument();
    });
  });

  it('shows "Oil Change Upcoming" alert', async () => {
    (useData as jest.Mock).mockReturnValue({
      getVehicleById: () => ({ ...mockVehicle, currentMileage: 44500 }),
      getMaintenanceRecordsByVehicleId: () => [
        { id: 'rec1', vehicleId: 'test-vehicle-id', date: '2023-01-01', kilometers: 40000, description: 'Oil change', serviceType: 'Oil Change' }
      ],
      deleteVehicle: jest.fn(),
      loading: false,
      error: null,
    });

    render(<VehicleDetailsPage />);
     await waitFor(() => {
        expect(screen.getByText(/Oil Change Upcoming/i)).toBeInTheDocument();
    });
  });
});
