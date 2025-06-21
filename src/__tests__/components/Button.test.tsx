import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from '@/components/Button';

describe('Button', () => {
  it('renders children correctly', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('handles click events', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    fireEvent.click(screen.getByText('Click me'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('applies primary variant styles by default', () => {
    render(<Button>Click me</Button>);
    const button = screen.getByText('Click me');
    expect(button).toHaveClass('btn-primary');
  });

  it('applies secondary variant styles when specified', () => {
    render(<Button variant="secondary">Click me</Button>);
    const button = screen.getByText('Click me');
    expect(button).toHaveClass('btn-secondary');
  });

  it('applies disabled styles when disabled', () => {
    render(<Button disabled>Click me</Button>);
    const button = screen.getByText('Click me');
    expect(button).toBeDisabled();
  });
});
