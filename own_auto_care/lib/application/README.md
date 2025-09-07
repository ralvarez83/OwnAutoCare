# Application Layer

Esta capa orquesta la lógica de negocio y coordina el flujo de datos entre la UI y el dominio.

## Contenido:

- **Use Cases**: `CreateVehicle`, `ListVehicles`, `UpdateVehicle`, etc.
- **Application Services**: Coordinación de casos de uso
- **DTOs**: Objetos de transferencia de datos
- **Ports**: Interfaces para comunicación con infraestructura

## Reglas:
- Solo puede depender del Domain
- Define puertos (interfaces) que implementa Infrastructure
- Implementa casos de uso específicos de la aplicación
