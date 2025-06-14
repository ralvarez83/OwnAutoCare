import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import ProfilePage from '../page'; // page.tsx
import { useSession, signIn, signOut } from 'next-auth/react';
import { Session } from 'next-auth'; // Import Session type

// Mock next-auth useSession and functions
jest.mock('next-auth/react', () => ({
  ...jest.requireActual('next-auth/react'), // Retain other exports
  useSession: jest.fn(),
  signIn: jest.fn(),
  signOut: jest.fn(),
}));

const mockUseSessionHook = useSession as jest.MockedFunction<typeof useSession>;
const mockSignIn = signIn as jest.MockedFunction<typeof signIn>;
const mockSignOut = signOut as jest.MockedFunction<typeof signOut>;


describe('ProfilePage', () => {
  beforeEach(() => {
    // Reset mocks before each test
    mockUseSessionHook.mockReset();
    mockSignIn.mockReset();
    mockSignOut.mockReset();
  });

  it('muestra el botón de inicio de sesión cuando el usuario no está autenticado', () => {
    mockUseSessionHook.mockReturnValue({ data: null, status: 'unauthenticated' });
    render(<ProfilePage />);
    expect(screen.getByRole('button', { name: /Sign in with Google/i })).toBeInTheDocument();
  });

  it('muestra la información del usuario y el botón de cierre de sesión cuando está autenticado', () => {
    const mockSessionData: Session = {
      user: { name: 'Test User', email: 'test@example.com', image: 'test-image.jpg' },
      expires: '2099-01-01T00:00:00.000Z', // Provide a valid future date string
      accessToken: 'mock-access-token' // Added accessToken as it's in our session type from previous steps
    };
    mockUseSessionHook.mockReturnValue({ data: mockSessionData, status: 'authenticated' });

    render(<ProfilePage />);

    // Verifica el nombre y el email. El uso de una función para `getByText` puede ser útil si el formato es complejo.
    const userInfoElement = screen.getByText((content, node) => {
      const nodeText = node?.textContent || '';
      const hasName = nodeText.includes('Test User');
      const hasEmail = nodeText.includes('test@example.com');
      const hasPrefix = nodeText.includes('Signed in as:');
      // Asegurarse de que el nodo sea un elemento P y contenga el texto
      if (node && node.tagName === 'P') {
        return hasName && hasEmail && hasPrefix;
      }
      return false;
    });
    expect(userInfoElement).toBeInTheDocument();

    const userAvatar = screen.getByAltText('User avatar');
    expect(userAvatar).toBeInTheDocument();
    expect(userAvatar).toHaveAttribute('src', 'test-image.jpg');

    expect(screen.getByRole('button', { name: /Sign out/i })).toBeInTheDocument();
  });

  it('llama a signIn("google") cuando se hace clic en el botón de inicio de sesión', async () => {
    const user = userEvent.setup();
    mockUseSessionHook.mockReturnValue({ data: null, status: 'unauthenticated' });

    render(<ProfilePage />);

    const signInButton = screen.getByRole('button', { name: /Sign in with Google/i });
    await user.click(signInButton);

    expect(mockSignIn).toHaveBeenCalledTimes(1);
    expect(mockSignIn).toHaveBeenCalledWith('google');
  });

  it('llama a signOut cuando se hace clic en el botón de cierre de sesión', async () => {
    const user = userEvent.setup();
    const mockSessionData: Session = {
      user: { name: 'Test User', email: 'test@example.com' },
      expires: '2099-01-01T00:00:00.000Z',
      accessToken: 'mock-access-token'
    };
    mockUseSessionHook.mockReturnValue({ data: mockSessionData, status: 'authenticated' });

    render(<ProfilePage />);

    const signOutButton = screen.getByRole('button', { name: /Sign out/i });
    await user.click(signOutButton);

    expect(mockSignOut).toHaveBeenCalledTimes(1);
  });

  it('muestra "Loading..." cuando el estado de la sesión es "loading"', () => {
    mockUseSessionHook.mockReturnValue({ data: null, status: 'loading' });
    render(<ProfilePage />);
    expect(screen.getByText('Loading session...')).toBeInTheDocument();
  });
});
