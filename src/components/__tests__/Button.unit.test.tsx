import React from 'react'
import { render, screen, fireEvent } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Button } from '../Button'

describe('Button Component', () => {
  const mockOnClick = jest.fn()

  beforeEach(() => {
    jest.clearAllMocks()
  })

  describe('Rendering', () => {
    it('should render button with children', () => {
      render(<Button onClick={mockOnClick}>Click me</Button>)

      const button = screen.getByRole('button', { name: /click me/i })
      expect(button).toBeInTheDocument()
    })

    it('should render with default variant (primary)', () => {
      render(<Button onClick={mockOnClick}>Primary Button</Button>)

      const button = screen.getByRole('button')
      expect(button).toHaveClass('bg-blue-600')
      expect(button).toHaveClass('text-white')
    })

    it('should render with secondary variant', () => {
      render(
        <Button onClick={mockOnClick} variant="secondary">
          Secondary Button
        </Button>
      )

      const button = screen.getByRole('button')
      expect(button).toHaveClass('bg-gray-600')
      expect(button).toHaveClass('text-white')
    })

    it('should render with different sizes', () => {
      const { rerender } = render(
        <Button onClick={mockOnClick} size="sm">
          Small Button
        </Button>
      )

      let button = screen.getByRole('button')
      expect(button).toHaveClass('px-2')
      expect(button).toHaveClass('py-1')
      expect(button).toHaveClass('text-sm')

      rerender(
        <Button onClick={mockOnClick} size="lg">
          Large Button
        </Button>
      )

      button = screen.getByRole('button')
      expect(button).toHaveClass('px-6')
      expect(button).toHaveClass('py-3')
      expect(button).toHaveClass('text-lg')
    })

    it('should render with custom className', () => {
      render(
        <Button onClick={mockOnClick} className="custom-class">
          Custom Button
        </Button>
      )

      const button = screen.getByRole('button')
      expect(button).toHaveClass('custom-class')
    })

    it('should render disabled button', () => {
      render(
        <Button onClick={mockOnClick} disabled>
          Disabled Button
        </Button>
      )

      const button = screen.getByRole('button')
      expect(button).toBeDisabled()
      expect(button).toHaveClass('opacity-50')
      expect(button).toHaveClass('cursor-not-allowed')
    })
  })

  describe('Interactions', () => {
    it('should call onClick when clicked', async () => {
      const user = userEvent.setup()
      render(<Button onClick={mockOnClick}>Click me</Button>)

      const button = screen.getByRole('button')
      await user.click(button)

      expect(mockOnClick).toHaveBeenCalledTimes(1)
    })

    it('should not call onClick when disabled', async () => {
      const user = userEvent.setup()
      render(
        <Button onClick={mockOnClick} disabled>
          Disabled Button
        </Button>
      )

      const button = screen.getByRole('button')
      await user.click(button)

      expect(mockOnClick).not.toHaveBeenCalled()
    })

    it('should handle keyboard interactions', async () => {
      const user = userEvent.setup()
      render(<Button onClick={mockOnClick}>Keyboard Button</Button>)

      const button = screen.getByRole('button')
      button.focus()
      await user.keyboard('{Enter}')

      expect(mockOnClick).toHaveBeenCalledTimes(1)
    })
  })

  describe('Accessibility', () => {
    it('should have proper ARIA attributes', () => {
      render(
        <Button onClick={mockOnClick} aria-label="Custom label">
          Button
        </Button>
      )

      const button = screen.getByRole('button', { name: /custom label/i })
      expect(button).toBeInTheDocument()
    })

    it('should be focusable', () => {
      render(<Button onClick={mockOnClick}>Focusable Button</Button>)

      const button = screen.getByRole('button')
      button.focus()
      expect(button).toHaveFocus()
    })

    it('should not be focusable when disabled', () => {
      render(
        <Button onClick={mockOnClick} disabled>
          Disabled Button
        </Button>
      )

      const button = screen.getByRole('button')
      expect(button).toHaveAttribute('tabindex', '-1')
    })
  })

  describe('Props handling', () => {
    it('should pass through additional props', () => {
      render(
        <Button onClick={mockOnClick} data-testid="test-button" title="Tooltip">
          Test Button
        </Button>
      )

      const button = screen.getByTestId('test-button')
      expect(button).toHaveAttribute('title', 'Tooltip')
    })

    it('should handle type prop', () => {
      render(
        <Button onClick={mockOnClick} type="submit">
          Submit Button
        </Button>
      )

      const button = screen.getByRole('button')
      expect(button).toHaveAttribute('type', 'submit')
    })

    it('should handle form prop', () => {
      render(
        <Button onClick={mockOnClick} form="test-form">
          Form Button
        </Button>
      )

      const button = screen.getByRole('button')
      expect(button).toHaveAttribute('form', 'test-form')
    })
  })

  describe('Edge cases', () => {
    it('should handle empty children', () => {
      render(<Button onClick={mockOnClick}></Button>)

      const button = screen.getByRole('button')
      expect(button).toBeInTheDocument()
      expect(button).toHaveTextContent('')
    })

    it('should handle null onClick', () => {
      render(<Button>No onClick Button</Button>)

      const button = screen.getByRole('button')
      expect(button).toBeInTheDocument()
      // Should not throw when clicked
      expect(() => fireEvent.click(button)).not.toThrow()
    })

    it('should handle complex children', () => {
      render(
        <Button onClick={mockOnClick}>
          <span>Icon</span>
          <span>Text</span>
        </Button>
      )

      const button = screen.getByRole('button')
      expect(button).toHaveTextContent('IconText')
    })
  })
})