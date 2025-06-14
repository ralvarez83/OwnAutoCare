import React, { ReactNode } from 'react';
import { render, act, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { DataProvider, useData } from '../DataContext';
import { SessionProvider, useSession as actualUseSession } from 'next-auth/react';
import { Vehicle, AppData } from '@/types'; // Assuming types are in src/types
import { Session } from 'next-auth';


// Mock next-auth useSession
jest.mock('next-auth/react', () => ({
  ...jest.requireActual('next-auth/react'),
  useSession: jest.fn(),
}));
const mockUseSession = actualUseSession as jest.MockedFunction<typeof actualUseSession>;


// Mock fetch
global.fetch = jest.fn();
const mockFetch = global.fetch as jest.Mock;

const mockVehicleData: Omit<Vehicle, 'id'> = { make: 'TestMake', model: 'TestModel', year: 2023, currentMileage: 1000 };

const TestConsumerComponent = () => {
  const { appData, addVehicle, loading, error } = useData();
  return (
    <div>
      <button onClick={async () => await addVehicle(mockVehicleData)}>Add Vehicle</button>
      <span data-testid='vehicle-count'>{appData.vehicles.length}</span>
      {loading && <p>Loading data...</p>}
      {error && <p role="alert">Error: {error}</p>}
    </div>
  );
};

// Wrapper component to provide necessary context providers
const AllTheProviders = ({ children }: { children: ReactNode }) => {
  // Provide a mock session for SessionProvider if useData relies on it for auth status
  const mockSession: Session | null = { user: { name: 'Test' }, expires: '1', accessToken: 'mock-token' } as any;
  return (
    <SessionProvider session={mockSession}>
      <DataProvider>{children}</DataProvider>
    </SessionProvider>
  );
};

describe('DataContext', () => {
  beforeEach(() => {
    mockFetch.mockClear();
    // Default mock for useSession, can be overridden in specific tests
    mockUseSession.mockReturnValue({ data: { accessToken: 'fake-token' } as any, status: 'authenticated' });
  });

  it('loads initial data from Drive (file not found, starts empty)', async () => {
    mockFetch.mockResolvedValueOnce({
      ok: false, // Correct for a 404 response
      status: 404,
      json: async () => ({ message: 'Not Found' }) // Or an empty object if that's what your API might return as JSON for a 404
    });
    render(<TestConsumerComponent />, { wrapper: AllTheProviders });

    await waitFor(() => expect(screen.queryByText('Loading data...')).not.toBeInTheDocument());
    expect(screen.getByTestId('vehicle-count').textContent).toBe('0');
  });

  it('adds a vehicle and triggers a debounced save to Drive', async () => {
    const user = userEvent.setup();
    mockFetch
      .mockResolvedValueOnce({ ok: true, status: 404, json: async () => ({ vehicles: [], maintenanceRecords: [] }) as Promise<AppData> }) // Initial load
      .mockResolvedValueOnce({ ok: true, json: async () => ({ message: 'Data saved' }) }); // Save call

    render(<TestConsumerComponent />, { wrapper: AllTheProviders });
    await waitFor(() => expect(screen.queryByText('Loading data...')).not.toBeInTheDocument());

    await act(async () => {
      await user.click(screen.getByText('Add Vehicle'));
    });

    expect(screen.getByTestId('vehicle-count').textContent).toBe('1');

    await waitFor(() => expect(mockFetch).toHaveBeenCalledTimes(2), { timeout: 2000 }); // 1 load, 1 save

    const savedData = JSON.parse(mockFetch.mock.calls[1][1].body as string) as AppData;
    expect(savedData.vehicles[0].make).toBe('TestMake');
  });

  it('handles error when loading data from Drive', async () => {
    mockFetch.mockResolvedValueOnce({
      ok: false,
      status: 500,
      json: async () => ({ error: 'Drive load failed' }),
    });
    render(<TestConsumerComponent />, { wrapper: AllTheProviders });

    await waitFor(() => expect(screen.queryByText('Loading data...')).not.toBeInTheDocument());
    expect(await screen.findByText('Error: Drive load failed')).toBeInTheDocument();
    expect(screen.getByTestId('vehicle-count').textContent).toBe('0'); // Should fallback to initial empty state
  });
});
