# 🎯 PRÓXIMAS TAREAS (Priorizadas)

> **PARA AGENTES**: Este es el roadmap del proyecto OwnAutoCare (app Flutter para mantenimiento de coches)  
> **INSTRUCCIÓN**: Elige la tarea #1 pendiente y ejecútala COMPLETAMENTE  
> **CONTEXTO**: Lee primero Agents.md (specs) y CURRENT_STATUS.md (estado actual)  
> **REGLA**: Una sola tarea por sesión, no más

## 🥇 PRIORIDAD ALTA (Hacer YA)

### 1. **Inicializar proyecto Flutter** ✅ **COMPLETADA**
**CONTEXTO**: Crear la base del proyecto desde cero
**PASOS ESPECÍFICOS**:
- Ejecutar `flutter create own_auto_care` con configuración multiplataforma
- Configurar `pubspec.yaml` con dependencias iniciales (testing, oauth, http)
- Crear estructura de carpetas según Clean Architecture (`/lib/domain`, `/lib/application`, etc.)
- Configurar análisis estático (`analysis_options.yaml`)
**RESULTADO ESPERADO**: Proyecto Flutter funcional que compila sin errores
**DEMO**: `flutter run` debe mostrar la app de ejemplo funcionando

### 2. **Implementar estructura Domain** ✅ **COMPLETADA**
**CONTEXTO**: Core de la lógica de negocio según Clean Architecture
**PASOS ESPECÍFICOS**:
- Crear entidades: `Vehicle`, `ServiceRecord`, `Reminder`, `Attachment`
- Implementar Value Objects básicos (VehicleId, Currency, etc.)
- Definir interfaces de repositorios
- Crear tests unitarios para entidades
**RESULTADO ESPERADO**: Core del dominio funcionando con tests verdes
**DEMO**: `flutter test` debe pasar todos los tests del dominio

### 3. **Autenticación Google Drive OAuth** ✅ **COMPLETADA**
**CONTEXTO**: Conectar con Google Drive para almacenamiento
**PASOS ESPECÍFICOS**:
- Configurar OAuth PKCE en Google Cloud Console
- Implementar flujo de autenticación en Flutter
- Crear abstracción `CloudStorageProvider`
- Testing básico de conexión
**RESULTADO ESPERADO**: App conecta con Google Drive
**DEMO**: Login funcional que accede a carpeta `/Apps/OwnAutoCare/`

### 5. **Mejora de la capacidad de respuesta de la interfaz de usuario** ✅ **COMPLETADA**
**CONTEXTO**: Mejorar la capacidad de respuesta de la aplicación a las interacciones del usuario.
**PASOS ESPECÍFICOS**:
- Añadido un `LoadingOverlay` para proporcionar feedback visual durante operaciones asíncronas.
- Deshabilitados los botones durante las operaciones asíncronas para evitar múltiples clics.
- Solucionados los problemas que impedían que la aplicación web se cargara correctamente.
- Corregido el error `unregistered_view_type` en la versión web relacionado con el botón de Google Sign-In.
**RESULTADO ESPERADO**: La aplicación se siente más rápida y receptiva.
**DEMO**: La aplicación web se carga correctamente y muestra indicadores de carga durante las operaciones asíncronas.

### 6. **Implementar logout** ✅ **COMPLETADA**
**CONTEXTO**: Permitir al usuario cerrar sesión.
**PASOS ESPECÍFICOS**:
- Añadir botón de logout en la pantalla de listado de vehículos.
- Implementar el método de logout en `GoogleDriveProvider`.
- Navegar a la pantalla de bienvenida después del logout.
**RESULTADO ESPERADO**: El usuario puede cerrar sesión y volver a la pantalla de bienvenida.
**DEMO**: Logout funcional.

### 7. **CRUD de vehículos** ✅ **COMPLETADA**
**CONTEXTO**: Gestión completa de vehículos del usuario
**PASOS ESPECÍFICOS**:
- Implementar casos de uso: CreateVehicle, ListVehicles, UpdateVehicle
- Conectar UI con lógica de negocio
- Persistencia en Google Drive (`carcare.json`)
**RESULTADO ESPERADO**: Gestión completa de vehículos
**DEMO**: Crear, ver, editar y eliminar vehículos funcionando

### 8. **Registros de mantenimiento** ✅ **COMPLETADA**
**CONTEXTO**: Gestión completa de los registros de mantenimiento de un vehículo.
**PASOS ESPECÍFICOS**:
- Implementar casos de uso: `CreateServiceRecord`, `ListServiceRecords`, `GetServiceRecord`, `UpdateServiceRecord`, `DeleteServiceRecord`.
- Conectar la UI con la lógica de negocio.
- Persistencia en Google Drive (dentro del archivo `carcare.json`).
- Crear tests unitarios para los casos de uso y el repositorio.
**RESULTADO ESPERADO**: El usuario puede crear, ver, editar y eliminar registros de mantenimiento asociados a un vehículo.
**DEMO**: Funcionalidad completa de CRUD para registros de mantenimiento.

## 🥈 PRIORIDAD MEDIA (Siguientes sesiones)

### 9. **Recordatorios** ✅ **COMPLETADA**
**CONTEXTO**: Permitir al usuario establecer recordatorios para el mantenimiento del vehículo.
**PASOS ESPECÍFICOS**:
- Crear entidad `Reminder`.
- Implementar `ReminderRepository` y su implementación.
- Implementar casos de uso: `CreateReminder`, `ListReminders`, `UpdateReminder`, `DeleteReminder`.
- Conectar la UI con la lógica de negocio.
- Persistencia en Google Drive.
**RESULTADO ESPERADO**: El usuario puede crear, ver, editar y eliminar recordatorios.
**DEMO**: Funcionalidad completa de CRUD para recordatorios.

## 🥈 PRIORIDAD MEDIA (Siguientes sesiones)

### 10. **Exportación/importación** ✅ **COMPLETADA**
**CONTEXTO**: Permitir al usuario exportar e importar sus datos.
**PASOS ESPECÍFICOS**:
- Implementar casos de uso para exportar datos (e.g., a JSON o CSV).
- Implementar casos de uso para importar datos (e.g., desde JSON o CSV).
- Conectar la UI con la lógica de negocio.
- Considerar la gestión de conflictos durante la importación.
**RESULTADO ESPERADO**: El usuario puede exportar e importar sus datos de vehículos, registros de mantenimiento y recordatorios.
**DEMO**: Funcionalidad de exportación/importación funcionando.

### 11. **Registros de mantenimiento**

---

## 📋 TEMPLATE para confirmar con Product Owner

```
👋 Hola, soy [NOMBRE_AGENTE]

✅ He leído toda la documentación:
- README_FOR_AGENTS.md (protocolo)
- Agents.md (especificaciones completas)
- CURRENT_STATUS.md (estado actual)  
- NEXT_TASKS.md (este roadmap)
- SESSION_LOG.md (historial de sesiones)

🎯 Voy a ejecutar: TAREA #[NÚMERO]: [NOMBRE_TAREA]

¿Es correcto? ¿Algún cambio de prioridades?
```

---
**INSTRUCCIÓN PARA AGENTES**: Completar SÓLO una tarea por sesión. Prioridad descendente.