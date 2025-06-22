import React from 'react'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { VehicleForm } from '../VehicleForm'
import { Vehicle } from '@/types/vehicle'

// Mock the Button component
jest.mock('../Button', () => ({
  Button: ({ children, onClick, disabled, type, variant }: any) => (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled}
      variant={variant}
    >
      {children}
    </button>
  ),
}))

describe('VehicleForm', () => {
  const mockOnSubmit = jest.fn()
  const mockOnCancel = jest.fn()

  const defaultProps = {
    onSubmit: mockOnSubmit,
    onCancel: mockOnCancel,
  }

  beforeEach(() => {
    jest.clearAllMocks()
  })

  describe('Rendering', () => {
    it('should render all form fields', () => {
      render(<VehicleForm {...defaultProps} />)

      expect(screen.getByLabelText(/marca/i)).toBeInTheDocument()
      expect(screen.getByLabelText(/modelo/i)).toBeInTheDocument()
      expect(screen.getByLabelText(/kilometraje actual/i)).toBeInTheDocument()
      expect(screen.getByLabelText(/kms para cambio de aceite/i)).toBeInTheDocument()
      expect(screen.getByLabelText(/tipo de aceite/i)).toBeInTheDocument()
      expect(screen.getByLabelText(/tipo de distribución/i)).toBeInTheDocument()
    })

    it('should render submit and cancel buttons', () => {
      render(<VehicleForm {...defaultProps} />)

      expect(screen.getByRole('button', { name: /crear vehículo/i })).toBeInTheDocument()
      expect(screen.getByRole('button', { name: /cancelar/i })).toBeInTheDocument()
    })

    it('should show loading state', () => {
      render(<VehicleForm {...defaultProps} loading={true} />)

      const submitButton = screen.getByRole('button', { name: /guardando/i })
      expect(submitButton).toBeDisabled()
    })

    it('should populate form with vehicle data when editing', () => {
      const vehicle: Vehicle = {
        id: '1',
        marca: 'Toyota',
        modelo: 'Corolla',
        kms: 50000,
        kmsCambioAceite: 5000,
        tipoAceite: '5W-30',
        tipoDistribucion: 'cadena',
        createdAt: new Date(),
        updatedAt: new Date(),
      }

      render(<VehicleForm {...defaultProps} vehicle={vehicle} />)

      expect(screen.getByDisplayValue('Toyota')).toBeInTheDocument()
      expect(screen.getByDisplayValue('Corolla')).toBeInTheDocument()
      expect(screen.getByDisplayValue('50000')).toBeInTheDocument()
      expect(screen.getByDisplayValue('5000')).toBeInTheDocument()
      expect(screen.getByDisplayValue('5W-30')).toBeInTheDocument()
    })
  })

  describe('Form Validation', () => {
    it('should show validation errors for empty required fields', async () => {
      const user = userEvent.setup()
      render(<VehicleForm {...defaultProps} />)

      const submitButton = screen.getByRole('button', { name: /crear vehículo/i })
      await user.click(submitButton)

      await waitFor(() => {
        expect(screen.getByText(/la marca es obligatoria/i)).toBeInTheDocument()
        expect(screen.getByText(/el modelo es obligatorio/i)).toBeInTheDocument()
      })
    })

    it('should show error for negative kilometers', async () => {
      const user = userEvent.setup()
      render(<VehicleForm {...defaultProps} />)

      const kmsInput = screen.getByLabelText(/kilometraje actual/i)
      await user.clear(kmsInput)
      await user.type(kmsInput, '-1000')

      const submitButton = screen.getByRole('button', { name: /crear vehículo/i })
      await user.click(submitButton)

      await waitFor(() => {
        expect(screen.getByText(/los kilómetros no pueden ser negativos/i)).toBeInTheDocument()
      })
    })

    it('should show error for invalid oil change kilometers', async () => {
      const user = userEvent.setup()
      render(<VehicleForm {...defaultProps} />)

      const oilChangeInput = screen.getByLabelText(/kms para cambio de aceite/i)
      await user.clear(oilChangeInput)
      await user.type(oilChangeInput, '0')

      const submitButton = screen.getByRole('button', { name: /crear vehículo/i })
      await user.click(submitButton)

      await waitFor(() => {
        expect(screen.getByText(/los kilómetros para cambio de aceite deben ser mayores a 0/i)).toBeInTheDocument()
      })
    })

    it('should show error for invalid oil type format', async () => {
      const user = userEvent.setup()
      render(<VehicleForm {...defaultProps} />)

      const oilTypeInput = screen.getByLabelText(/tipo de aceite/i)
      await user.type(oilTypeInput, 'invalid-oil')

      const submitButton = screen.getByRole('button', { name: /crear vehículo/i })
      await user.click(submitButton)

      await waitFor(() => {
        expect(screen.getByText(/formato inválido/i)).toBeInTheDocument()
      })
    })

    it('should show error for correa without kmsCambioCorrea', async () => {
      const user = userEvent.setup()
      render(<VehicleForm {...defaultProps} />)

      // Fill required fields
      await user.type(screen.getByLabelText(/marca/i), 'Toyota')
      await user.type(screen.getByLabelText(/modelo/i), 'Corolla')
      await user.type(screen.getByLabelText(/kilometraje actual/i), '50000')
      await user.type(screen.getByLabelText(/tipo de aceite/i), '5W-30')

      // Change to correa
      const distributionSelect = screen.getByLabelText(/tipo de distribución/i)
      await user.selectOptions(distributionSelect, 'correa')

      const submitButton = screen.getByRole('button', { name: /crear vehículo/i })
      await user.click(submitButton)

      await waitFor(() => {
        expect(screen.getByText(/los kilómetros para cambio de correa deben ser un número/i)).toBeInTheDocument()
      })
    })

    it('should show error when oil change km is greater than belt change km', async () => {
      const user = userEvent.setup()
      render(<VehicleForm {...defaultProps} />)

      // Fill required fields
      await user.type(screen.getByLabelText(/marca/i), 'Toyota')
      await user.type(screen.getByLabelText(/modelo/i), 'Corolla')
      await user.type(screen.getByLabelText(/kilometraje actual/i), '50000')
      await user.type(screen.getByLabelText(/tipo de aceite/i), '5W-30')

      // Change to correa and add kmsCambioCorrea
      const distributionSelect = screen.getByLabelText(/tipo de distribución/i)
      await user.selectOptions(distributionSelect, 'correa')

      const beltChangeInput = screen.getByLabelText(/kms para cambio de correa/i)
      await user.type(beltChangeInput, '60000')

      // Set oil change km higher than belt change km
      const oilChangeInput = screen.getByLabelText(/kms para cambio de aceite/i)
      await user.clear(oilChangeInput)
      await user.type(oilChangeInput, '70000')

      const submitButton = screen.getByRole('button', { name: /crear vehículo/i })
      await user.click(submitButton)

      await waitFor(() => {
        expect(screen.getByText(/los kilómetros para cambio de aceite no pueden exceder 50,000 km/i)).toBeInTheDocument()
      })
    })
  })

  describe('Form Submission', () => {
    it('should submit form with valid data', async () => {
      const user = userEvent.setup()
      render(<VehicleForm {...defaultProps} />)

      // Fill form
      await user.type(screen.getByLabelText(/marca/i), 'Toyota')
      await user.type(screen.getByLabelText(/modelo/i), 'Corolla')
      await user.type(screen.getByLabelText(/kilometraje actual/i), '50000')
      await user.type(screen.getByLabelText(/tipo de aceite/i), '5W-30')

      const submitButton = screen.getByRole('button', { name: /crear vehículo/i })
      await user.click(submitButton)

      await waitFor(() => {
        expect(mockOnSubmit).toHaveBeenCalledWith({
          marca: 'Toyota',
          modelo: 'Corolla',
          kms: 50000,
          kmsCambioAceite: 5000,
          tipoAceite: '5W-30',
          tipoDistribucion: 'cadena',
          kmsCambioCorrea: undefined,
        })
      })
    })

    it('should submit form with correa data', async () => {
      const user = userEvent.setup()
      render(<VehicleForm {...defaultProps} />)

      // Fill form
      await user.type(screen.getByLabelText(/marca/i), 'Toyota')
      await user.type(screen.getByLabelText(/modelo/i), 'Corolla')
      await user.type(screen.getByLabelText(/kilometraje actual/i), '50000')
      await user.type(screen.getByLabelText(/tipo de aceite/i), '5W-30')

      // Change to correa and add kmsCambioCorrea
      const distributionSelect = screen.getByLabelText(/tipo de distribución/i)
      await user.selectOptions(distributionSelect, 'correa')

      const beltChangeInput = screen.getByLabelText(/kms para cambio de correa/i)
      await user.type(beltChangeInput, '60000')

      const submitButton = screen.getByRole('button', { name: /crear vehículo/i })
      await user.click(submitButton)

      await waitFor(() => {
        expect(mockOnSubmit).toHaveBeenCalledWith({
          marca: 'Toyota',
          modelo: 'Corolla',
          kms: 50000,
          kmsCambioAceite: 5000,
          tipoAceite: '5W-30',
          tipoDistribucion: 'correa',
          kmsCambioCorrea: 60000,
        })
      })
    })
  })

  describe('Form Interactions', () => {
    it('should call onCancel when cancel button is clicked', async () => {
      const user = userEvent.setup()
      render(<VehicleForm {...defaultProps} />)

      const cancelButton = screen.getByRole('button', { name: /cancelar/i })
      await user.click(cancelButton)

      expect(mockOnCancel).toHaveBeenCalledTimes(1)
    })

    it('should clear validation errors when user starts typing', async () => {
      const user = userEvent.setup()
      render(<VehicleForm {...defaultProps} />)

      // Trigger validation error
      const submitButton = screen.getByRole('button', { name: /crear vehículo/i })
      await user.click(submitButton)

      await waitFor(() => {
        expect(screen.getByText(/la marca es obligatoria/i)).toBeInTheDocument()
      })

      // Start typing in marca field
      const marcaInput = screen.getByLabelText(/marca/i)
      await user.type(marcaInput, 'T')

      await waitFor(() => {
        expect(screen.queryByText(/la marca es obligatoria/i)).not.toBeInTheDocument()
      })
    })

    it('should show correa field when tipoDistribucion is correa', async () => {
      const user = userEvent.setup()
      render(<VehicleForm {...defaultProps} />)

      // Initially, correa field should not be visible
      expect(screen.queryByLabelText(/kms para cambio de correa/i)).not.toBeInTheDocument()

      // Change to correa
      const distributionSelect = screen.getByLabelText(/tipo de distribución/i)
      await user.selectOptions(distributionSelect, 'correa')

      // Now correa field should be visible
      expect(screen.getByLabelText(/kms para cambio de correa/i)).toBeInTheDocument()
    })
  })
})