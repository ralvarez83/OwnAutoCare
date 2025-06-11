import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import AddVehiclePage from '../page'; // Adjust path to your AddVehiclePage component (now page.tsx)
import { useData } from '@/context/DataContext';
import { useRouter } from 'next/navigation'; // For App Router
import { SessionProvider, useSession as actualUseSession } from 'next-auth/react'; // DataContext uses useSession

// Mock next/navigation
jest.mock('next/navigation', () => ({
  useRouter: jest.fn(),
  // useParams: jest.fn(), // Not used directly by AddVehiclePage
  // useSearchParams: jest.fn(), // Not used directly by AddVehiclePage
}));
const mockUseRouter = useRouter as jest.Mock;

// Mock DataContext
jest.mock('@/context/DataContext');
const mockUseData = useData as jest.Mock;

// Mock next-auth useSession (because DataContext uses it)
jest.mock('next-auth/react', () => ({
  ...jest.requireActual('next-auth/react'),
  useSession: jest.fn(),
}));
const mockUseSession = actualUseSession as jest.MockedFunction<typeof actualUseSession>;


describe('AddVehiclePage', () => {
  let mockPush: jest.Mock;
  let mockAddVehicle: jest.Mock;

  beforeEach(() => {
    mockPush = jest.fn();
    mockUseRouter.mockReturnValue({ push: mockPush });

    mockAddVehicle = jest.fn().mockResolvedValue(undefined); // Mock addVehicle to resolve successfully
    mockUseData.mockReturnValue({
      addVehicle: mockAddVehicle,
      // Provide other context values if AddVehiclePage uses them, otherwise defaults are fine
      appData: { vehicles: [], maintenanceRecords: [] },
      loading: false,
      error: null,
    });

    // Provide a default mock for useSession for DataContext
    mockUseSession.mockReturnValue({ data: { accessToken: 'fake-token' } as any, status: 'authenticated' });

    // Mock window.alert
    global.alert = jest.fn();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  const renderPage = () => {
    // DataProvider needs SessionProvider if it uses useSession
    // AddVehiclePage itself does not directly use SessionProvider, but DataContext does.
    // So we need to wrap with SessionProvider for DataContext to behave as expected.
    return render(
      <SessionProvider session={null}> {/* Minimal session for SessionProvider */}
        <AddVehiclePage />
      </SessionProvider>
    );
  };

  it('renders the form with all fields', () => {
    renderPage();
    expect(screen.getByLabelText(/Make/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/Model/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/Year/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/Current Mileage \(km\)/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/VIN/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/Photo URL/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/Oil Change Interval \(km, optional\)/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /Save Vehicle/i })).toBeInTheDocument();
  });

  it('allows typing into form fields', async () => {
    const user = userEvent.setup();
    renderPage();

    await user.type(screen.getByLabelText(/Make/i), 'Honda');
    expect(screen.getByLabelText(/Make/i)).toHaveValue('Honda');

    await user.type(screen.getByLabelText(/Model/i), 'Civic');
    expect(screen.getByLabelText(/Model/i)).toHaveValue('Civic');

    await user.type(screen.getByLabelText(/Year/i), '2023');
    expect(screen.getByLabelText(/Year/i)).toHaveValue(2023);

    await user.type(screen.getByLabelText(/Current Mileage \(km\)/i), '15000');
    expect(screen.getByLabelText(/Current Mileage \(km\)/i)).toHaveValue(15000);

    await user.type(screen.getByLabelText(/Oil Change Interval \(km, optional\)/i), '5000');
    expect(screen.getByLabelText(/Oil Change Interval \(km, optional\)/i)).toHaveValue(5000);
  });

  it('submits the form with correct data and navigates on success', async () => {
    const user = userEvent.setup();
    renderPage();

    await user.type(screen.getByLabelText(/Make/i), 'Toyota');
    await user.type(screen.getByLabelText(/Model/i), 'Corolla');
    await user.type(screen.getByLabelText(/Year/i), '2022');
    await user.type(screen.getByLabelText(/Current Mileage \(km\)/i), '12000');
    await user.type(screen.getByLabelText(/VIN/i), '12345ABC');
    await user.type(screen.getByLabelText(/Photo URL/i), 'http://example.com/photo.jpg');
    await user.type(screen.getByLabelText(/Oil Change Interval \(km, optional\)/i), '7000');

    await user.click(screen.getByRole('button', { name: /Save Vehicle/i }));

    await waitFor(() => {
      expect(mockAddVehicle).toHaveBeenCalledTimes(1);
      expect(mockAddVehicle).toHaveBeenCalledWith({
        make: 'Toyota',
        model: 'Corolla',
        year: 2022,
        vin: '12345ABC',
        photoUrl: 'http://example.com/photo.jpg',
        currentMileage: 12000,
        oilChangeMileageInterval: 7000,
      });
    });

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith('/');
    });
  });

  it('submits with only required fields and undefined for optional if empty', async () => {
    const user = userEvent.setup();
    renderPage();

    await user.type(screen.getByLabelText(/Make/i), 'Ford');
    await user.type(screen.getByLabelText(/Model/i), 'Focus');
    await user.type(screen.getByLabelText(/Year/i), '2021');
    // Optional fields (Current Mileage, VIN, Photo URL, Oil Change Interval) are left empty

    await user.click(screen.getByRole('button', { name: /Save Vehicle/i }));

    await waitFor(() => {
      expect(mockAddVehicle).toHaveBeenCalledWith({
        make: 'Ford',
        model: 'Focus',
        year: 2021,
        vin: '', // Current implementation sends empty string if not touched
        photoUrl: '', // Current implementation sends empty string if not touched
        currentMileage: undefined, // Number('') becomes 0, then undefined if handled
        oilChangeMileageInterval: undefined, // Number('') becomes 0, then undefined if handled
      });
    });
  });

  it('shows alert and does not submit if required fields are missing', async () => {
    const user = userEvent.setup();
    renderPage(); // Render with empty form

    // Attempt to submit without filling required fields
    await user.click(screen.getByRole('button', { name: /Save Vehicle/i }));

    expect(global.alert).toHaveBeenCalledWith('Please fill in at least Make, Model, and Year.');
    expect(mockAddVehicle).not.toHaveBeenCalled();
    expect(mockPush).not.toHaveBeenCalled();
  });
});
