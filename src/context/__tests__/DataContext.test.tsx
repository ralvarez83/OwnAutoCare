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
  const { appData, addVehicle, updateVehicle, deleteVehicle, loading, error } = useData();
  return (
    <div>
      <button onClick={async () => await addVehicle(mockVehicleData)}>Add Vehicle</button>
      {appData.vehicles.map(v => (
        <div key={v.id}>
          <span data-testid={`vehicle-make-${v.id}`}>{v.make}</span>
          <button onClick={async () => await updateVehicle({ ...v, make: 'UpdatedMake' })}>Update {v.id}</button>
          <button onClick={async () => await deleteVehicle(v.id)}>Delete {v.id}</button>
        </div>
      ))}
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

  it('loads existing data from Drive successfully', async () => {
    const mockAppData: AppData = {
      vehicles: [{ id: '1', make: 'Honda', model: 'Civic', year: 2020, currentMileage: 15000 }],
      maintenanceRecords: [],
    };
    mockFetch.mockResolvedValueOnce({
      ok: true,
      json: async () => mockAppData,
    });
    render(<TestConsumerComponent />, { wrapper: AllTheProviders });

    await waitFor(() => expect(screen.queryByText('Loading data...')).not.toBeInTheDocument());
    expect(screen.getByTestId('vehicle-count').textContent).toBe('1');
    // You could also add more specific checks here, e.g., that the vehicle's make is 'Honda'
    // by extending TestConsumerComponent to display vehicle details.
  });

  it('adds a vehicle and triggers a debounced save to Drive', async () => {
    const user = userEvent.setup();
    mockFetch
      .mockResolvedValueOnce({ ok: false, status: 404, json: async () => ({ vehicles: [], maintenanceRecords: [] }) }) // Simulate no existing file
      .mockResolvedValueOnce({ ok: true, json: async () => ({ message: 'Data saved' }) }); // Save call

    render(<TestConsumerComponent />, { wrapper: AllTheProviders });
    await waitFor(() => expect(screen.queryByText('Loading data...')).not.toBeInTheDocument());

    await act(async () => {
      await user.click(screen.getByText('Add Vehicle'));
    });

    expect(screen.getByTestId('vehicle-count').textContent).toBe('1');

    // Wait for the debounced save operation
    await waitFor(() => {
      expect(mockFetch).toHaveBeenCalledTimes(2); // Initial load + save
      expect(mockFetch.mock.calls[1][0]).toBe('/api/drive/file-ops'); // Check save URL
      expect(mockFetch.mock.calls[1][1].method).toBe('POST'); // Check save method
    }, { timeout: 2000 });


    const savedData = JSON.parse(mockFetch.mock.calls[1][1].body as string) as AppData;
    expect(savedData.vehicles[0].make).toBe('TestMake');
  });

  it('handles error when loading data from Drive', async () => {
    mockFetch.mockResolvedValueOnce({
      ok: false,
      status: 500,
      json: async () => ({ message: 'Failed to load data from Drive' }), // Ensure message matches error handling in context
    });
    render(<TestConsumerComponent />, { wrapper: AllTheProviders });

    await waitFor(() => expect(screen.queryByText('Loading data...')).not.toBeInTheDocument());
    expect(await screen.findByText('Error: Failed to load data from Drive')).toBeInTheDocument();
    expect(screen.getByTestId('vehicle-count').textContent).toBe('0');
  });

  it('updates a vehicle and saves to Drive', async () => {
    const user = userEvent.setup();
    const initialVehicle: Vehicle = { id: 'v1', make: 'InitialMake', model: 'ModelX', year: 2021, currentMileage: 5000 };
    mockFetch
      .mockResolvedValueOnce({ ok: true, json: async () => ({ vehicles: [initialVehicle], maintenanceRecords: [] }) }) // Initial load
      .mockResolvedValueOnce({ ok: true, json: async () => ({ message: 'Data saved' }) }); // Save call

    render(<TestConsumerComponent />, { wrapper: AllTheProviders });
    await waitFor(() => expect(screen.queryByText('Loading data...')).not.toBeInTheDocument());
    expect(screen.getByTestId('vehicle-count').textContent).toBe('1');
    expect(screen.getByTestId('vehicle-make-v1').textContent).toBe('InitialMake');

    await act(async () => {
      await user.click(screen.getByText('Update v1'));
    });

    expect(screen.getByTestId('vehicle-make-v1').textContent).toBe('UpdatedMake');
    await waitFor(() => expect(mockFetch).toHaveBeenCalledTimes(2), { timeout: 2000 }); // 1 load, 1 save
    const savedData = JSON.parse(mockFetch.mock.calls[1][1].body as string) as AppData;
    expect(savedData.vehicles[0].make).toBe('UpdatedMake');
  });

  it('deletes a vehicle and saves to Drive', async () => {
    const user = userEvent.setup();
    const initialVehicle1: Vehicle = { id: 'v1', make: 'Make1', model: 'ModelX', year: 2021, currentMileage: 5000 };
    const initialVehicle2: Vehicle = { id: 'v2', make: 'Make2', model: 'ModelY', year: 2022, currentMileage: 3000 };
    mockFetch
      .mockResolvedValueOnce({ ok: true, json: async () => ({ vehicles: [initialVehicle1, initialVehicle2], maintenanceRecords: [] }) }) // Initial load
      .mockResolvedValueOnce({ ok: true, json: async () => ({ message: 'Data saved' }) }); // Save call

    render(<TestConsumerComponent />, { wrapper: AllTheProviders });
    await waitFor(() => expect(screen.queryByText('Loading data...')).not.toBeInTheDocument());
    expect(screen.getByTestId('vehicle-count').textContent).toBe('2');

    await act(async () => {
      await user.click(screen.getByText('Delete v1'));
    });

    expect(screen.getByTestId('vehicle-count').textContent).toBe('1');
    expect(screen.queryByTestId('vehicle-make-v1')).not.toBeInTheDocument();
    await waitFor(() => expect(mockFetch).toHaveBeenCalledTimes(2), { timeout: 2000 }); // 1 load, 1 save
    const savedData = JSON.parse(mockFetch.mock.calls[1][1].body as string) as AppData;
    expect(savedData.vehicles.length).toBe(1);
    expect(savedData.vehicles[0].id).toBe('v2');
  });

  it('handles error when saving data to Drive', async () => {
    const user = userEvent.setup();
    mockFetch
      .mockResolvedValueOnce({ ok: false, status: 404, json: async () => ({ vehicles: [], maintenanceRecords: [] }) }) // Initial load (empty)
      .mockResolvedValueOnce({ // Save call fails
        ok: false,
        status: 500,
        json: async () => ({ message: 'Failed to save data to Drive' }),
      });

    render(<TestConsumerComponent />, { wrapper: AllTheProviders });
    await waitFor(() => expect(screen.queryByText('Loading data...')).not.toBeInTheDocument());

    await act(async () => {
      await user.click(screen.getByText('Add Vehicle'));
    });

    // Wait for the save attempt and subsequent error
    await waitFor(async () => {
      expect(await screen.findByText('Error: Failed to save data to Drive')).toBeInTheDocument();
    }, { timeout: 2000 }); // Debounce time + network time

    // The vehicle might have been added optimistically, then removed or error handled.
    // Depending on implementation, count might be 0 or 1.
    // For now, let's assume it's rolled back or not added if save fails.
    // This assertion might need adjustment based on actual error handling logic for addVehicle.
    // If addVehicle is purely optimistic and doesn't roll back, this might be '1'.
    // However, a robust solution would likely roll back or prevent addition on save failure.
    expect(screen.getByTestId('vehicle-count').textContent).toBe('1'); // Assuming optimistic update, but error is shown
    // Check that fetch was called for load and save attempt
    expect(mockFetch).toHaveBeenCalledTimes(2);
  });
});
