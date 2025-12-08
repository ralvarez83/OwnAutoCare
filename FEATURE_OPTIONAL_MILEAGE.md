# Feature: Kilometraje Opcional con Indicador "--"

## 🎯 Objetivo
Permitir que los registros de servicio tengan kilometraje **opcional**. Cuando no se define o el usuario no lo proporciona, mostrar "--" en lugar de "0" para indicar que es un valor desconocido.

## ✅ Cambios Realizados

### 1. **Entidad de Dominio** 
**Archivo**: `lib/domain/entities/service_record.dart`
- Cambio: `final int mileageKm;` → `final int? mileageKm;`
- Efecto: El campo ahora es **opcional** (nullable)
- Impacto: Permite registrar servicios sin conocer el kilometraje

### 2. **Formulario de Entrada**
**Archivo**: `lib/presentation/screens/service_record_form/service_record_form_screen.dart`
- Cambio 1: Variable `late int _mileageKm;` → `int? _mileageKm;`
- Cambio 2: `_mileageKm = 0;` → `_mileageKm = null;` (para nuevos registros)
- Cambio 3: Campo de texto:
  - **Validación**: Ya NO requiere valor (campo opcional)
  - **Inicial**: `_mileageKm?.toString() ?? ''` (muestra vacío si no hay valor)
  - **Guardado**: `_mileageKm = value != null && value.isNotEmpty ? int.parse(value) : null;`
- Efecto: El usuario puede dejar el campo vacío sin errores

### 3. **Visualización en Timeline**
**Archivo**: `lib/presentation/widgets/service_timeline_tile.dart`
```dart
// Antes: Mostraba "0 km" si no había valor
Text('${NumberFormat('#,###').format(record.mileageKm)} km')

// Ahora: Muestra "--" si no hay valor
Text(
  record.mileageKm != null
      ? '${NumberFormat('#,###').format(record.mileageKm)} km'
      : '--',
  style: Theme.of(context).textTheme.bodyMedium,
)
```

### 4. **Visualización en Lista de Registros**
**Archivo**: `lib/presentation/screens/service_record_list/service_record_list_screen.dart`
```dart
// Antes: Mostraba "0 km" si no había valor
Text(_records.isNotEmpty ? '${_records.first.mileageKm} km' : l10n.noMileageRecorded)

// Ahora: Verifica si mileageKm es null
Text(
  _records.isNotEmpty && _records.first.mileageKm != null
      ? '${_records.first.mileageKm} km'
      : l10n.noMileageRecorded,
)
```

## 🔄 Compatibilidad

### Hacia Adelante ✅
- Registros nuevos pueden NO tener kilometraje
- El símbolo "--" indica "desconocido"
- Claro e intuitivo para el usuario

### Hacia Atrás ✅
- Los registros existentes **con** kilometraje siguen mostrándose normalmente
- Los registros existentes **sin** kilometraje (si hay) ahora muestran "--" en lugar de "0"
- No hay pérdida de datos

## 📊 Ejemplos

| Caso | Antes | Ahora | Observación |
|------|-------|-------|-------------|
| Nuevo registro sin KM | Fuerza a ingresar 0 | Campo vacío ✓ | Usuario puede omitir |
| Nuevo registro con KM | 125000 km | 125000 km ✓ | Funciona igual |
| KM no registrado | Muestra "0 km" | Muestra "--" ✓ | Más claro |
| Editar registro sin KM | Muestra "0" | Muestra vacío ✓ | Consistente |

## ✅ Testing

- **Compilación**: `flutter build web --release` ✅ Exitosa
- **Tests**: `flutter test` ✅ 30/30 PASSED
- **Tipo seguridad**: Sin errores de compilación
- **Backward compatibility**: Mantiene datos existentes

## 🚀 Impacto en UX

**Mejoras**:
- ✨ Campo opcional = menos fricción al registrar
- ✨ "--" en lugar de "0" = más profesionald
- ✨ Usuarios sin odómetro pueden registrar igual
- ✨ Registros históricos claros cuando falta dato

**Casos de Uso Desbloqueados**:
- Servicios en taller sin acceso a odómetro
- Vehículos clásicos/retro sin odómetro digital
- Historial heredado incompleto
- Registros de mantenimiento preventivo genéricos
