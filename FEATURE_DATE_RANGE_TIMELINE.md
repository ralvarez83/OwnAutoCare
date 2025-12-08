# Feature: Rango de Fechas en Timeline

## 🎯 Objetivo
Cuando hay registros con fechas anteriores y posteriores, mostrar un **rango de fechas** junto a la fecha del registro actual para dar contexto del historial completo.

## ✅ Cambios Realizados

### 1. **Widget `ServiceTimelineTile`**
**Archivo**: `lib/presentation/widgets/service_timeline_tile.dart`

#### Parámetros Añadidos
```dart
final DateTime? earliestDate; // Fecha más antigua en el listado
final DateTime? latestDate;   // Fecha más reciente en el listado
```

#### Nuevo Método: `_formatDateWithRange()`
```dart
String _formatDateWithRange(DateTime date) {
  final formattedDate = DateFormat('dd/MM/yyyy').format(date);
  
  if (earliestDate != null && latestDate != null) {
    final daysFromEarliest = date.difference(earliestDate!).inDays;
    final daysFromLatest = latestDate!.difference(date).inDays;
    
    // Muestra rango si hay registros antes y después
    if (daysFromEarliest > 0 && daysFromLatest > 0) {
      final rangeText = '(${DateFormat('dd/MM/yy').format(earliestDate!)} - ${DateFormat('dd/MM/yy').format(latestDate!)})';
      return '$formattedDate $rangeText';
    }
  }
  
  return formattedDate;
}
```

#### Actualización de Subtítulos
Se actualizaron todas las instancias donde se formatea la fecha:
- ITV records: `DateFormat('dd/MM/yyyy').format(record.date)` → `_formatDateWithRange(record.date)`
- Registros con nombre: idem
- Registros sin nombre: idem

### 2. **Pantalla de Lista de Registros**
**Archivo**: `lib/presentation/screens/service_record_list/service_record_list_screen.dart`

#### Lógica de Cálculo de Rango
En la construcción del `ListView`, se calcula automáticamente:
```dart
// Calcular fechas mínima y máxima para mostrar rango
DateTime? earliestDate;
DateTime? latestDate;
if (_records.length > 1) {
  final dates = _records.map((r) => r.date).toList();
  dates.sort();
  earliestDate = dates.first;
  latestDate = dates.last;
}
```

#### Paso de Parámetros
```dart
ServiceTimelineTile(
  record: record,
  isFirst: index == 0,
  isLast: index == _records.length - 1,
  earliestDate: earliestDate,      // ← Nuevo
  latestDate: latestDate,          // ← Nuevo
  // ... resto de parámetros
)
```

## 📊 Ejemplos de Visualización

### Caso 1: Un solo registro
```
✓ Cambio de aceite
  05/12/2025
```
*Sin rango (no hay antes/después)*

### Caso 2: Múltiples registros
```
Primera línea:
  ✓ ITV
    05/12/2025 (01/01/2020 - 05/12/2025)

Registro intermedio:
  ⚙️  Cambio de aceite
    10/10/2024 (01/01/2020 - 05/12/2025)

Última línea:
  ✓ Neumáticos
    01/01/2020
```
*Cada línea muestra el rango completo para contexto*

## 🎨 Formato Visual

**Fórmula**: `DD/MM/YYYY (DD/MM/YY - DD/MM/YY)`

- Fecha actual: **Formato completo** `DD/MM/YYYY`
- Rango: **Formato corto** en paréntesis (fecha más antigua - fecha más reciente)
- Compacto pero informativo

## ⚙️ Lógica de Visualización

El rango se muestra **solo si**:
1. ✅ Hay más de 1 registro (`_records.length > 1`)
2. ✅ El registro actual no es el primero (`daysFromEarliest > 0`)
3. ✅ El registro actual no es el último (`daysFromLatest > 0`)

**Ventaja**: Registros al inicio y final del rango no muestran información redundante.

## ✅ Testing

- **Compilación**: `flutter build web --release` ✅ Exitosa
- **Tests**: `flutter test` ✅ 30/30 PASSED
- **Tipo seguridad**: Sin errores de compilación
- **Backward compatibility**: Parámetros opcionales, sin breaking changes

## 📱 UX Improvements

**Beneficios para el usuario**:
- 🎯 **Contexto histórico**: Ve rápidamente el rango temporal de su historial
- 📅 **Orientación temporal**: Sabe dónde cae cada registro en el timeline
- 🔍 **Mejor legibilidad**: Información compacta pero clara
- 📊 **Análisis visual**: Facilita ver patrones de mantenimiento a lo largo del tiempo

**Casos de Uso**:
- Vender vehículo: mostrar rango de mantenimiento registrado
- Análisis histórico: ver evolución del mantenimiento
- Recordatorios: contexto de cuándo fue el último mantenimiento
- Auditoría: documentación clara del período de cobertura

## 🔄 Compatibilidad

### Hacia Adelante ✅
- Nuevo parámetro es **completamente opcional**
- Si no se proporciona `earliestDate`/`latestDate`, funciona sin rango
- Diseño escalable para futuras mejoras

### Hacia Atrás ✅
- Registros existentes se muestran igual si no hay rango
- Sin cambios en datos o estructura
- Totalmente no-destructivo
