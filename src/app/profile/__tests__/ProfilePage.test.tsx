import React from 'react';
import { render, screen } from '@testing-library/react';
import ProfilePage from '../page'; // Adjust path to your ProfilePage component
import { useSession } from 'next-auth/react';

// Mock next-auth useSession
jest.mock('next-auth/react');

describe('ProfilePage', () => {
  it('renders sign-in button when not authenticated', () => {
    (useSession as jest.Mock).mockReturnValue({ data: null, status: 'unauthenticated' });
    render(<ProfilePage />);
    expect(screen.getByText('Sign in with Google')).toBeInTheDocument();
  });

  it('renders user information when authenticated', () => {
    const mockSession = {
      user: { name: 'Test User', email: 'test@example.com', image: 'test-image.jpg' },
    };
    (useSession as jest.Mock).mockReturnValue({ data: mockSession, status: 'authenticated' });
    render(<ProfilePage />);
    expect(screen.getByText(`Signed in as: Test User (test@example.com)`)).toBeInTheDocument();
    expect(screen.getByAltText('User avatar')).toHaveAttribute('src', 'test-image.jpg');
    expect(screen.getByText('Sign out')).toBeInTheDocument();
  });
});
