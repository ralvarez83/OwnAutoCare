# Presentation Layer

Esta capa contiene toda la interfaz de usuario y manejo de estado.

## Contenido:

- **Pages**: Pantallas de la aplicación
- **Widgets**: Componentes reutilizables de UI
- **State Management**: BLoCs, Controllers, ViewModels
- **Navigation**: Rutas y navegación entre pantallas

## Reglas:
- Puede depender de Application y Domain (vía Application)
- NO debe contener lógica de negocio
- Responsable solo de mostrar datos y capturar eventos de usuario
