# AGENTS.md - Especificaciones completas del proyecto

> **PARA AGENTES**: Este documento contiene TODAS las especificaciones técnicas del proyecto  
> **PROPÓSITO**: Leer completamente antes de hacer cualquier tarea  
> **PROYECTO**: OwnAutoCare - App multiplataforma Flutter para registrar mantenimiento de coches  

> **Resumen ejecutivo**: App multiplataforma para registrar mantenimiento y reparaciones de coches (múltiples vehículos), con **sincronización en Google Drive / OneDrive** usando **sólo cliente** (sin servidores). Desarrollo por **vibecoding** con un agente de IA ejecutando ciclos cortos de diseño→implementación→test→refactor.

---

## 🎯 Objetivo y alcance
- **Qué es**: Aplicación móvil **y** ejecutable en tablet/ordenador (Android, iOS, Web, Desktop) para capturar, consultar y compartir rápidamente el historial de mantenimiento de **uno o varios vehículos**.
- **Público**: Personas que prefieren lo digital al papel y necesitan localizar al instante facturas, cambios de piezas, recordatorios y costes.
- **Modelo de costes**: Cero costes de backend. Todo se almacena en **archivos JSON** dentro de una carpeta del usuario en **Google Drive** o **OneDrive**.
- **No metas**: No habrá base de datos ni APIs propias, no habrá notificaciones push con backend, ni dependencia de servicios de pago.

---

## 🧱 Estrategia técnica (decisión opinada)
- **Stack**: **Flutter (Dart)** por productividad, cobertura de plataformas (Android/iOS/Web/Desktop), tooling robusto, testing integrado, y facilidad para el agente.
- **OAuth PKCE directo** (cliente público): Integración nativa con Google/Microsoft sin servidor intermedio.
- **Arquitectura**: **Clean Architecture + DDD + SOLID** en un **monolito cliente**.
- **Testing**: Unit, widget y golden tests desde el día 1.
- **UX/UI**: Seguir recomendaciones de **UX modernas**, con diseño **limpio, minimalista y accesible**. Uso de patrones consistentes (botones flotantes, navegación clara, tipografía legible).

> Si en algún punto este stack bloquea una capacidad, el agente debe proponer una alternativa (p.ej. React Native/Expo) con pros/contras antes de cambiar.

---

## 🗂️ Estructura lógica (Clean Architecture)
```
/lib
  /presentation       # UI (Flutter widgets, state management)
  /application        # Casos de uso (coordinación, orquestación)
  /domain             # Entidades, Value Objects, Reglas de negocio
  /infrastructure     # Integraciones (Drive/Graph), almacenamiento local, mapeadores
  /shared             # Utils, errores, result types
```
- **Reglas**:
  - `domain` no depende de ningún otro módulo.
  - `application` depende sólo de `domain` y puertos (interfaces).
  - `infrastructure` implementa adaptadores; no filtra a `domain` tipos de terceros.
  - `presentation` consume `application` vía controladores/VM.

---

## 🧩 Modelo de dominio (inicial)
**Entidades principales**
- `Vehicle { id, make, model, year, vin?, plates? }`
- `ServiceRecord { id, vehicleId, date, mileageKm, type, parts[], labor?, cost, currency, notes?, attachments[] }`
- `Reminder { id, vehicleId, dueDate|dueMileageKm, title, notes? }`
- `Attachment { id, filename, mime, driveProvider, drivePath, size? }`

👉 La aplicación debe soportar **múltiples vehículos por usuario**. Cada `ServiceRecord` y `Reminder` se asocia mediante `vehicleId`.

**Tipos de servicio sugeridos**: `oil_change`, `inspection`, `brake_pads`, `tires`, `coolant`, `battery`, `itv`, `other`.

---

## 🧾 Esquemas JSON (versión 1)
- Archivo raíz por proveedor: `carcare.json` (metadatos) y subcarpeta `records/` con 1 JSON por registro.
- Convención de nombres: `records/<vehicleId>/<yyyy-mm-dd>_<mileage>_<uuid>.json`

```jsonc
// carcare.json
{
  "schemaVersion": 1,
  "vehicles": [
    { "id": "veh_1", "make": "Seat", "model": "Ibiza", "year": 2016, "vin": null, "plates": "1234-ABC" },
    { "id": "veh_2", "make": "Volkswagen", "model": "Golf", "year": 2019, "vin": null, "plates": "5678-XYZ" }
  ],
  "settings": { "currency": "EUR", "locale": "es-ES" }
}
```

```jsonc
// records/veh_1/2025-05-03_125000_6d2e.json
{
  "id": "6d2e",
  "vehicleId": "veh_1",
  "date": "2025-05-03",
  "mileageKm": 125000,
  "type": "oil_change",
  "parts": [
    { "name": "5W30 oil", "brand": "Castrol", "qty": 1, "unit": "L", "unitPrice": 35.0 }
  ],
  "labor": { "hours": 0.5, "rate": 45.0 },
  "cost": 57.5,
  "currency": "EUR",
  "notes": "Se cambió filtro",
  "attachments": [
    { "id": "att_1", "filename": "factura_2025-05-03.pdf", "mime": "application/pdf", "driveProvider": "google", "drivePath": "attachments/veh_1/factura_2025-05-03.pdf" }
  ]
}
```

**Compatibilidad**: Si el `schemaVersion` cambia, el agente debe crear migradores puros de `domain` y tests de migración.

---

## ☁️ Proveedores de almacenamiento (Drive/OneDrive)
**Ubicación de datos**
- Google Drive → `/Apps/OwnAutoCare/`
- OneDrive     → `/Application/OwnAutoCare/`

Estructura interna:
```
/Apps/OwnAutoCare
  carcare.json
  /records
    /veh_1
    /veh_2
  /attachments
    /veh_1
    /veh_2
```

**Abstracción**
```ts
interface CloudStorageProvider {
  Future<void> ensureSetup();                      // crea carpeta app si no existe
  Future<JsonMap> readRootMetadata();              // carcare.json
  Future<void> writeRootMetadata(JsonMap data);
  Future<List<CloudItem>> listRecords(String vehicleId);
  Future<JsonMap> readRecord(String path);
  Future<void> writeRecord(String path, JsonMap);
  Future<void> deleteRecord(String path);
  Future<Uri> getAttachmentLink(String path);      // link compartible (si se pide)
}
```

**Google Drive**
- **OAuth**: PKCE con scopes mínimos: `drive.file` (o `appDataFolder`).
- Carpeta: `/Apps/OwnAutoCare/`.

**OneDrive (Microsoft Graph)**
- **OAuth**: PKCE `Files.ReadWrite.AppFolder`.
- Carpeta: `/Application/OwnAutoCare/`.

---

## 🔐 Configuración OAuth paso a paso

### Google
1. Ir a [Google Cloud Console](https://console.cloud.google.com/).
2. Crear proyecto: `OwnAutoCare`.
3. Activar **Google Drive API**.
4. Configurar pantalla de consentimiento OAuth → tipo *External*.
5. Scopes mínimos: `drive.file` o `drive.appdata`.
6. Crear credenciales → OAuth Client ID → tipo *Desktop app*.
7. Guardar `client_id`. No se requiere `client_secret` con PKCE.
8. Redirect URI: `com.ownautocare:/oauth2redirect`.

CLI alternativo:
```bash
gcloud auth application-default login \
  --scopes=https://www.googleapis.com/auth/drive.file
```

### Microsoft (OneDrive)
1. Ir a [Azure Portal](https://portal.azure.com/).
2. Azure Active Directory → App registrations → New Registration.
3. Nombre: OwnAutoCare.
4. Redirect URI: `com.ownautocare:/oauth2redirect`.
5. API Permissions → Microsoft Graph → Delegated → `Files.ReadWrite.AppFolder`.
6. Guardar `Application (client) ID`.

CLI alternativo:
```bash
az ad app create --display-name OwnAutoCare
```

---

## 📲 Flujo de usuario (ejemplo)

1. **Primer arranque**
   - El usuario abre la app → elige proveedor (Google Drive / OneDrive).
   - Autenticación OAuth → se crea `/Apps/OwnAutoCare/` (o equivalente en OneDrive).
   - Se inicializa `carcare.json` vacío.

2. **Añadir vehículo**
   - Pantalla *Mis Vehículos* → botón `+`.
   - Formulario: marca, modelo, año, matrícula, VIN opcional.
   - La app guarda los datos en `carcare.json`.

3. **Registrar mantenimiento**
   - Seleccionar vehículo → `Nuevo Registro`.
   - Formulario: fecha, kilometraje, tipo de servicio, piezas, mano de obra, coste.
   - Adjuntar foto o PDF de la factura (guardado en `/attachments/veh_X`).
   - **Sugerencias inteligentes**: mientras el usuario escribe, la app sugiere servicios ya usados (*ej. cambio de aceite*), piezas frecuentes, talleres ya guardados, etc. Esto acelera la introducción de datos.
   - **Autocompletado contextual**: si el vehículo ya tiene kilometraje registrado, la app propone el valor anterior + incremento estimado. Si ya se introdujo la moneda, se mantiene por defecto.
   - Se genera un archivo JSON en `/records/veh_X/`.

4. **Consultar historial**
   - Vista cronológica por vehículo.
   - Filtro por tipo de servicio (ej. *ITV*).
   - Búsqueda por fecha o texto libre.
   - Aspecto **moderno y limpio**: tarjetas, iconografía clara, colores suaves.

5. **Recordatorios**
   - Usuario añade un recordatorio (ej. *Próximo cambio de aceite en 10.000 km*).
   - La app lo guarda en `carcare.json`.
   - Opcional: alerta local (sin backend) en el móvil.

6. **Exportar / compartir**
   - El usuario selecciona un vehículo → botón *Exportar historial*.
   - Se genera un `.zip` con JSONs + adjuntos para compartir o respaldar.

---

## 🔍 Inteligencia de autocompletado y sugerencias
- La app debe **aprovechar los datos ya guardados** en `carcare.json` y los registros anteriores para **ofrecer sugerencias y autocompletado**.
- Ejemplos:
  - Sugerir talleres, piezas o servicios ya registrados.
  - Autocompletar matrícula, VIN o moneda en nuevos formularios.
  - Proponer kilometraje estimado a partir del último registro.
- La implementación concreta (historial local en memoria, índices en disco, librerías de autocompletado, etc.) queda a criterio del agente según el stack.

---

(El resto de secciones del AGENTS.md se mantienen sin cambios, adaptando la lógica para soportar múltiples vehículos y experiencias de usuario más ágiles).

