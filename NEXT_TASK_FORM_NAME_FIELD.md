# 🎯 PRÓXIMA TAREA: Formulario de Registro con Campo "Nombre"

> **Para el siguiente agente**: Este documento contiene EXACTAMENTE qué hacer a continuación

## 📋 Resumen Ejecutivo

La entidad `ServiceRecord` ahora tiene un campo opcional `name` que permite a los usuarios personalizar el nombre de cada registro de servicio. El widget de presentación ya está actualizado para mostrar este nombre, o como fallback, mostrar los tipos de servicio.

**Lo que falta**: El formulario `ServiceRecordFormScreen` aún NO permite que el usuario introduzca este nombre. Sin esto, todos los registros nuevos se crean con `name = null`.

## 🎯 Tarea Específica

### Objetivo
Actualizar `ServiceRecordFormScreen` para incluir un campo de entrada de texto donde el usuario pueda introducir un nombre personalizado para el registro de servicio (completamente opcional).

### Ubicación del archivo a modificar
```
lib/presentation/screens/service_record_form/service_record_form_screen.dart
```

### Qué agregar

#### Paso 1: Nueva variable para almacenar el nombre
Dentro de `_ServiceRecordFormScreenState`, agregar:
```dart
String? _recordName; // Nuevo campo para almacenar el nombre
```

#### Paso 2: Campo de entrada en el formulario
En el build method del formulario, después del widget de `visitType` y antes del widget de fecha, agregar:

```dart
// Nombre personalizado del registro (opcional)
Padding(
  padding: const EdgeInsets.only(bottom: 20),
  child: TextFormField(
    initialValue: _recordName,
    onChanged: (value) {
      setState(() => _recordName = value.isEmpty ? null : value);
    },
    decoration: InputDecoration(
      labelText: l10n.serviceRecordName, // String a localizar
      hintText: l10n.serviceRecordNameHint, // Ej: "e.g., Oil change, Brake service"
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      prefixIcon: const Icon(Icons.label_outline),
    ),
    maxLength: 100,
    buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
      // Opcional: mostrar contador de caracteres
      return Text(
        '$currentLength/${maxLength ?? 0}',
        style: Theme.of(context).textTheme.bodySmall,
      );
    },
  ),
),
```

#### Paso 3: Pasar el nombre al crear el registro
En el método que crea el `ServiceRecord` (probablemente en `_saveServiceRecord()` o similar), actualizar para pasar `name`:

**Antes:**
```dart
final serviceRecord = ServiceRecord(
  id: generateId(),
  vehicleId: widget.vehicle.id,
  date: _selectedDate ?? DateTime.now(),
  mileageKm: int.parse(_mileageController.text),
  visitType: _selectedVisitType,
  items: _items,
  cost: totalCost,
  currency: _selectedCurrency,
  // ... otros campos ...
);
```

**Después:**
```dart
final serviceRecord = ServiceRecord(
  id: generateId(),
  vehicleId: widget.vehicle.id,
  date: _selectedDate ?? DateTime.now(),
  mileageKm: int.parse(_mileageController.text),
  visitType: _selectedVisitType,
  items: _items,
  cost: totalCost,
  currency: _selectedCurrency,
  name: _recordName, // ← AÑADIDO
  // ... otros campos ...
);
```

### Paso 4: Strings de localización necesarios
Agregar a `lib/l10n/app_en.arb`:
```json
"serviceRecordName": "Record name (optional)",
"serviceRecordNameHint": "e.g., Routine oil change, Annual inspection"
```

Agregar a `lib/l10n/app_es.arb`:
```json
"serviceRecordName": "Nombre del registro (opcional)",
"serviceRecordNameHint": "p.ej., Cambio de aceite rutinario, Inspección anual"
```

Luego regenerar con:
```bash
cd own_auto_care && flutter gen-l10n
```

## ✅ Criterios de Aceptación

- [ ] El formulario compila sin errores
- [ ] Aparece un nuevo campo de texto en el formulario
- [ ] El usuario puede introducir un nombre (máximo 100 caracteres)
- [ ] El usuario puede dejar el campo vacío (es opcional)
- [ ] El nombre se guarda correctamente en `ServiceRecord`
- [ ] Los tests siguen pasando (30/30)
- [ ] Cuando se edita un registro, el nombre anterior aparece pre-llenado
- [ ] Los strings están localizados en English y Spanish
- [ ] Las strings de localization son claras y útiles

## 🧪 Testing después de cambios

```bash
# 1. Generar localizaciones
cd own_auto_care && flutter gen-l10n

# 2. Compilar para web
flutter build web --release

# 3. Ejecutar todos los tests
flutter test

# 4. (Opcional) Correr la app en desarrollo
flutter run -d web
```

## 📝 Notas Importantes

### Backward Compatibility
- ✅ Registros antiguos sin `name` seguirán funcionando
- ✅ El campo es nullable, así que no rompe nada
- ✅ El widget de presentación maneja automáticamente `name == null`

### UX Considerations
- El campo debe ser **claramente opcional** (usar label y hint text descriptivos)
- Considerar mostrar un contador de caracteres o máximo
- El placeholder debe ser útil (ej: "Cambio de aceite rutinario")

### Ubicación en el formulario
- Debe estar después de `visitType` (el usuario sabe qué tipo de servicio es)
- Debe estar antes de la fecha o mileage (datos técnicos)
- Debe tener espaciado consistente con otros campos

## 🔗 Referencias

**Archivos relacionados**:
- ✅ `lib/domain/entities/service_record.dart` - Ya actualizado (tiene `name` field)
- ✅ `lib/presentation/widgets/service_timeline_tile.dart` - Ya actualizado (display logic)
- ⏳ `lib/presentation/screens/service_record_form/service_record_form_screen.dart` - **NECESITA ACTUALIZACIÓN**
- `lib/l10n/app_en.arb` - Strings de localización (English)
- `lib/l10n/app_es.arb` - Strings de localización (Spanish)

**Documentación útil**:
- `IMPLEMENTATION_SUMMARY.md` - Resumen técnico de lo que se hizo
- `VISUAL_GUIDE_SERVICE_NAMES.md` - Guía visual de cómo se verá

## 🚀 Próximos pasos después de completar esta tarea

1. ✅ Actualizar formulario (THIS TASK)
2. ⏳ Crear o actualizar tests para el nuevo campo `name`
3. ⏳ Verificación manual: crear registros con/sin nombre
4. ⏳ Testear edición de registros existentes
5. ⏳ Verificar persistencia en Google Drive

## 📞 Contacto

Si hay dudas:
- Revisar `VISUAL_GUIDE_SERVICE_NAMES.md` para entender el contexto completo
- Revisar `IMPLEMENTATION_SUMMARY.md` para detalles técnicos
- Leer el código en `service_timeline_tile.dart` para ver cómo se usa el `name` field
- Revisar `SESSION_LOG.md` Sesión #8 para historial completo

---

**Agente anterior**: GitHub Copilot  
**Estado**: Ready for next agent  
**Difficulty**: ⭐ Fácil-Intermedio (cambios localizados, sin lógica compleja)  
**Estimated time**: 30-45 minutos
