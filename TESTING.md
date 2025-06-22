# Testing Guide - OwnAutoCare

Esta guía describe la estructura de tests implementada en el proyecto OwnAutoCare.

## 📁 Estructura de Tests

```
src/
├── __tests__/
│   ├── components/           # Tests unitarios de componentes React
│   │   ├── Button.unit.test.tsx
│   │   └── VehicleForm.unit.test.tsx
│   ├── services/            # Tests unitarios de servicios
│   │   └── VehicleService.unit.test.ts
│   ├── repositories/        # Tests de integración
│   │   └── GoogleDriveVehicleRepository.integration.test.ts
│   └── app/
│       └── api/
│           └── __tests__/   # Tests end-to-end de API
│               └── vehicles.e2e.test.ts
```

## 🧪 Tipos de Tests

### 1. Tests Unitarios (`unit`)

- **Propósito**: Probar lógica individual sin dependencias externas
- **Ubicación**: `src/**/__tests__/*.unit.test.*`
- **Ejecución**: `npm run test:unit`

**Ejemplos**:

- `VehicleService.unit.test.ts` - Lógica de negocio del servicio
- `Button.unit.test.tsx` - Componente UI sin dependencias
- `VehicleForm.unit.test.tsx` - Formulario con mocks

### 2. Tests de Integración (`integration`)

- **Propósito**: Probar integración con servicios externos reales
- **Ubicación**: `src/**/__tests__/*.integration.test.*`
- **Ejecución**: `npm run test:integration`

**Ejemplos**:

- `GoogleDriveVehicleRepository.integration.test.ts` - Integración real con Google Drive

### 3. Tests End-to-End (`e2e`)

- **Propósito**: Probar flujos completos de la aplicación
- **Ubicación**: `src/**/__tests__/*.e2e.test.*`
- **Ejecución**: `npm run test:e2e`

**Ejemplos**:

- `vehicles.e2e.test.ts` - API completa con Supertest

## 🚀 Comandos de Ejecución

```bash
# Ejecutar todos los tests
npm test

# Ejecutar tests en modo watch
npm run test:watch

# Ejecutar tests con coverage
npm run test:coverage

# Ejecutar tests específicos
npm run test:unit          # Solo tests unitarios
npm run test:integration   # Solo tests de integración
npm run test:e2e          # Solo tests end-to-end
npm run test:api          # Solo tests de API
```

## 🔧 Configuración

### Jest Configuration

- **Archivo**: `jest.config.js`
- **Setup**: `jest.setup.js`
- **Environment**: `jsdom` para React, `node` para API

### Mocks Globales

- **NextAuth**: Sesión autenticada mock
- **Next.js Router**: Navegación mock
- **Google APIs**: Respuestas mock para tests unitarios
- **Fetch**: Mock global para requests HTTP

## 📊 Coverage

Los tests cubren:

- ✅ **Servicios**: Lógica de negocio y validaciones
- ✅ **Componentes**: Renderizado, interacciones, accesibilidad
- ✅ **Repositorios**: Integración con Google Drive
- ✅ **API**: Endpoints completos con autenticación
- ✅ **Formularios**: Validaciones y envío de datos

## 🧪 Ejemplos de Tests

### Test Unitario - Servicio

```typescript
describe('VehicleService', () => {
  it('should create vehicle with valid data', async () => {
    const vehicleData = { marca: 'Toyota', modelo: 'Corolla' };
    const result = await vehicleService.createVehicle(vehicleData);
    expect(result.marca).toBe('Toyota');
  });
});
```

### Test Unitario - Componente

```typescript
describe('VehicleForm', () => {
  it('should submit form with valid data', async () => {
    const user = userEvent.setup();
    await user.type(screen.getByLabelText(/marca/i), 'Toyota');
    await user.click(screen.getByRole('button', { name: /guardar/i }));
    expect(mockOnSubmit).toHaveBeenCalledWith(
      expect.objectContaining({
        marca: 'Toyota',
      })
    );
  });
});
```

### Test de Integración

```typescript
describe('GoogleDriveVehicleRepository Integration', () => {
  it('should create a vehicle in Google Drive', async () => {
    const vehicle = await repository.create(testVehicleData);
    expect(vehicle).toBeDefined();
    expect(vehicle.marca).toBe(testVehicleData.marca);
  }, 30000); // Timeout para API calls
});
```

### Test E2E - API

```typescript
describe('Vehicles API E2E', () => {
  it('should create a new vehicle', async () => {
    const response = await request(server).post('/api/vehicles').send(vehicleData).expect(200);

    expect(response.body.success).toBe(true);
    expect(response.body.vehicle.marca).toBe(vehicleData.marca);
  });
});
```

## 🔍 Debugging Tests

### Verbose Output

```bash
npm test -- --verbose
```

### Debug Tests Específicos

```bash
npm test -- --testNamePattern="should create vehicle"
```

### Coverage Report

```bash
npm run test:coverage
# Abre coverage/lcov-report/index.html en el navegador
```

## 📝 Buenas Prácticas

1. **Naming**: Usar `.unit.test.ts`, `.integration.test.ts`, `.e2e.test.ts`
2. **Isolation**: Cada test debe ser independiente
3. **Mocks**: Usar mocks para dependencias externas en tests unitarios
4. **Cleanup**: Limpiar datos de test después de tests de integración
5. **Timeouts**: Usar timeouts apropiados para tests de API
6. **Assertions**: Usar assertions específicas y descriptivas

## 🚨 Troubleshooting

### Tests Failing

1. Verificar que las variables de entorno estén configuradas
2. Comprobar que Google Drive API esté habilitada
3. Verificar que las credenciales de OAuth sean válidas

### Performance

- Los tests de integración pueden ser lentos (30s timeout)
- Usar `npm run test:unit` para desarrollo rápido
- Ejecutar tests de integración solo cuando sea necesario

### Coverage

- Mantener coverage > 80% para código crítico
- Focar en lógica de negocio y validaciones
- Tests de UI pueden tener coverage menor
