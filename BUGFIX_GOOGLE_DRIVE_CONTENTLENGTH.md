# BugFix: Google Drive ContentLength Error

## Problema
Al guardar un registro de servicio con 2 o más servicios, la app fallaba con este error:
```
Error al guardar registro de servicio: Failed to save service record: 
Failed to write data: ClientException: Content size exceeds specified contentLength. 
1855 bytes written while expected 1851.
```

**Síntoma**: El error ocurría únicamente después de añadir el campo `name` (opcional) a `ServiceRecord`, que aumentaba el tamaño del JSON en ~4 bytes.

## Root Cause (Causa Raíz)
En `google_drive_provider.dart` línea 263, el código calculaba `content.length` del **string JSON**, no de los **bytes UTF-8**:

```dart
// ❌ INCORRECTO (antes del fix)
final content = json.encode(data);
final media = drive.Media(
  Stream.value(utf8.encode(content)),
  content.length,  // ← Número de caracteres, no de bytes
  contentType: 'application/json',
);
```

**Por qué falló**:
- `String.length` en Dart devuelve el número de **caracteres Unicode**, no de **bytes**
- Para caracteres ASCII puros esto coincide, pero `json.encode()` produce a veces caracteres especiales
- Google Drive API cacheaba el tamaño anterior (1851 bytes)
- Al actualizar con contenido más grande (1855 bytes), el `contentLength` declarado no coincidía
- Google Drive rechazaba la actualización por discrepancia de tamaño

## Solución
Cambiar para usar el tamaño real de los **bytes UTF-8 codificados**:

```dart
// ✅ CORRECTO (después del fix)
final content = json.encode(data);
final utf8Bytes = utf8.encode(content);
final media = drive.Media(
  Stream.value(utf8Bytes),
  utf8Bytes.length,  // ← Número real de bytes
  contentType: 'application/json',
);
```

**Ventajas**:
- Usa siempre el tamaño correcto del contenido en bytes
- Compatible con caracteres especiales, emojis, etc.
- Mantiene sincronización con Google Drive API
- Funciona con archivos de cualquier tamaño

## Archivo Modificado
- **Path**: `lib/infrastructure/providers/google_drive_provider.dart`
- **Método**: `writeRootMetadata()`
- **Líneas**: 251-263
- **Cambio**: Calcular `utf8Bytes` explícitamente y usar su `length`

## Testing
- ✅ Compilación: `flutter build web --release` (success)
- ✅ Tests: `flutter test` (30/30 passed)
- ✅ Tipo seguridad: Sin errores de compilación
- ✅ Compatibilidad: Hacia atrás compatible

## Impacto
- **Scope**: Solo afecta la persistencia en Google Drive
- **Usuarios**: Todos los que guardan registros con el nuevo campo `name`
- **Datos existentes**: No son afectados (solo cambio en cómo se calcula el tamaño al guardar)
- **Próximos cambios**: Cualquier cambio en el esquema JSON debe usar el mismo patrón

## Referencias
- Google Drive API Media Upload: https://developers.google.com/drive/api/guides/manage-uploads
- Dart UTF-8 Encoding: https://api.dart.dev/stable/latest/dart-convert/utf8.html
