# Domain Layer

Esta capa contiene la lógica de negocio central del sistema y es completamente independiente de frameworks externos.

## Contenido:

- **Entities**: `Vehicle`, `ServiceRecord`, `Reminder`, `Attachment`
- **Value Objects**: `VehicleId`, `Currency`, etc.
- **Repository Interfaces**: Contratos para persistencia
- **Domain Services**: Lógica de negocio compleja

## Reglas:
- NO puede depender de ninguna otra capa
- Define interfaces que implementarán otras capas
- Contiene la lógica de negocio pura
