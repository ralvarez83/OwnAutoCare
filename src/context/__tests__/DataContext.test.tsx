import React, { ReactNode } from 'react';
import { render, act, screen, waitFor } from '@testing-library/react';
import { DataProvider, useData } from '../DataContext';
import { SessionProvider } from 'next-auth/react'; // DataProvider uses useSession
import { Vehicle } from '@/types';

// Mock next-auth
jest.mock('next-auth/react', () => ({
  ...jest.requireActual('next-auth/react'), // import and retain default behavior
  useSession: jest.fn(),
}));

// Mock fetch
global.fetch = jest.fn();

const mockVehicle: Omit<Vehicle, 'id'> = { make: 'TestMake', model: 'TestModel', year: 2023 };

const TestConsumerComponent = () => {
  const { appData, addVehicle, loading } = useData();
  return (
    <div>
      <button onClick={() => addVehicle(mockVehicle)}>Add Vehicle</button>
      <span data-testid='vehicle-count'>{appData.vehicles.length}</span>
      {loading && <p>Loading data...</p>}
    </div>
  );
};

const AllTheProviders = ({ children }: {children: ReactNode}) => {
  return (
    <SessionProvider session={null}> {/* Provide a mock session object if needed by useSession */}
      <DataProvider>{children}</DataProvider>
    </SessionProvider>
  )
}


describe('DataContext', () => {
  beforeEach(() => {
    (global.fetch as jest.Mock).mockClear();
    (useSession as jest.Mock).mockReturnValue({ data: { accessToken: 'fake-token' }, status: 'authenticated' });
  });

  it('loads initial data from Drive (mocked as empty)', async () => {
    (global.fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      status: 404, // Simulate file not found initially
      json: async () => ({}),
    });
    render(<TestConsumerComponent />, { wrapper: AllTheProviders });
    await waitFor(() => expect(screen.queryByText('Loading data...')).not.toBeInTheDocument());
    expect(screen.getByTestId('vehicle-count').textContent).toBe('0');
  });

  it('adds a vehicle and triggers a save (debounced)', async () => {
    (global.fetch as jest.Mock)
      .mockResolvedValueOnce({ ok: true, status: 404, json: async () => ({ vehicles: [], maintenanceRecords: [] }) }) // Initial load
      .mockResolvedValueOnce({ ok: true, json: async () => ({ message: 'Data saved' }) }); // Save call

    render(<TestConsumerComponent />, { wrapper: AllTheProviders });
    await waitFor(() => expect(screen.queryByText('Loading data...')).not.toBeInTheDocument());

    act(() => {
      screen.getByText('Add Vehicle').click();
    });

    expect(screen.getByTestId('vehicle-count').textContent).toBe('1');

    // Wait for debounce and fetch call
    await waitFor(() => expect(global.fetch).toHaveBeenCalledTimes(2), { timeout: 2000 }); // 1 load, 1 save
    expect(JSON.parse((global.fetch as jest.Mock).mock.calls[1][1].body).vehicles[0].make).toBe('TestMake');
  });
});
