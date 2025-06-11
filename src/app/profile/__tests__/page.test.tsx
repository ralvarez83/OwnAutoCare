import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event'; // For potential future interactions
import ProfilePage from '../page'; // Now page.tsx
import { useSession, signIn, signOut } from 'next-auth/react'; // signIn/signOut for potential mocking
import { Session } from 'next-auth'; // Import Session type

// Mock next-auth useSession and functions
jest.mock('next-auth/react', () => ({
  ...jest.requireActual('next-auth/react'), // Retain other exports
  useSession: jest.fn(),
  signIn: jest.fn(),
  signOut: jest.fn(),
}));

const mockUseSession = useSession as jest.MockedFunction<typeof useSession>;
// const mockSignIn = signIn as jest.MockedFunction<typeof signIn>;
// const mockSignOut = signOut as jest.MockedFunction<typeof signOut>;


describe('ProfilePage', () => {
  it('renders sign-in button when not authenticated', () => {
    mockUseSession.mockReturnValue({ data: null, status: 'unauthenticated' });
    render(<ProfilePage />);
    expect(screen.getByText('Sign in with Google')).toBeInTheDocument();
  });

  it('renders user information and sign-out button when authenticated', () => {
    const mockSessionData: Session = { // Use Session type
      user: { name: 'Test User', email: 'test@example.com', image: 'test-image.jpg' },
      expires: '1', // expires is a required property
    };
    mockUseSession.mockReturnValue({ data: mockSessionData, status: 'authenticated' });

    render(<ProfilePage />);

    expect(screen.getByText((content, element) => content.startsWith('Signed in as: Test User'))).toBeInTheDocument();
    // More specific check for email if needed:
    // expect(screen.getByText('(test@example.com)')).toBeInTheDocument();

    const userAvatar = screen.getByAltText('User avatar');
    expect(userAvatar).toBeInTheDocument();
    expect(userAvatar).toHaveAttribute('src', 'test-image.jpg');

    expect(screen.getByText('Sign out')).toBeInTheDocument();
  });

  it('calls signOut when sign-out button is clicked', async () => {
    const user = userEvent.setup();
    const mockSessionData: Session = {
      user: { name: 'Test User', email: 'test@example.com' },
      expires: '1',
    };
    mockUseSession.mockReturnValue({ data: mockSessionData, status: 'authenticated' });

    render(<ProfilePage />);

    const signOutButton = screen.getByText('Sign out');
    await user.click(signOutButton);

    expect(signOut).toHaveBeenCalled();
  });
});
