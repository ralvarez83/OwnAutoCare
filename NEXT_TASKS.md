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

## 🥈 PRIORIDAD MEDIA (Siguientes sesiones)

### 4. **Interfaz básica (MVP)** ✅ **COMPLETADA**
**CONTEXTO**: UI mínima pero funcional
**PASOS ESPECÍFICOS**:
- Pantalla de bienvenida/login
- Lista de vehículos (vacía inicialmente)
- Formulario "Añadir vehículo"
- Navegación básica
**RESULTADO ESPERADO**: UI mínima pero funcional
**DEMO**: Navegación completa entre pantallas

### 5. **Migrar a `renderButton` de Google Sign-In**
**CONTEXTO**: El método `signIn()` está obsoleto en la web.
**PASOS ESPECÍFICOS**:
- Investigar el error de compilación `Method not found: 'renderButton'`.
- Refactorizar la UI para usar el widget `renderButton` de `google_sign_in_web`.
- Asegurar que el flujo de autenticación siga funcionando correctamente.
**RESULTADO ESPERADO**: Eliminada la advertencia de obsolescencia y la autenticación funciona con el nuevo método.
**DEMO**: Login funcional en la web sin advertencias.

### 6. **CRUD de vehículos**
**CONTEXTO**: Gestión completa de vehículos del usuario
**PASOS ESPECÍFICOS**:
- Implementar casos de uso: CreateVehicle, ListVehicles, UpdateVehicle
- Conectar UI con lógica de negocio
- Persistencia en Google Drive (`carcare.json`)
**RESULTADO ESPERADO**: Gestión completa de vehículos
**DEMO**: Crear, ver, editar y eliminar vehículos funcionando

## 🥉 PRIORIDAD BAJA (Futuro)

### 7. **Registros de mantenimiento**
### 8. **Recordatorios**
### 9. **Exportación/importación**

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