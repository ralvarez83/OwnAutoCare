# Infrastructure Layer

Esta capa implementa los detalles técnicos y se comunica con sistemas externos.

## Contenido:

- **Repositories**: Implementaciones concretas de interfaces del dominio
- **External Services**: Google Drive API, OneDrive API
- **Data Sources**: Almacenamiento local, cache
- **Mappers**: Conversión entre entidades de dominio y DTOs externos

## Reglas:
- Puede depender de Domain y Application
- Implementa puertos definidos en otras capas
- Contiene todos los detalles de frameworks externos
