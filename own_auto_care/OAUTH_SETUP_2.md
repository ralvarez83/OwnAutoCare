# 🔐 Configuración actualizada de OAuth para OwnAutoCare

## 📋 Configuración de OAuth Consent Screen

### 1. Información de la aplicación
```
App name: OwnAutoCare
User support email: tu-email@gmail.com
Application home page: http://localhost:8080
Application privacy policy link: http://localhost:8080/privacy
Application terms of service link: http://localhost:8080/terms
Authorized domains: localhost
Developer contact information: tu-email@gmail.com
```

### 2. Scopes necesarios
```
https://www.googleapis.com/auth/drive.file
  - Descripción: Ver y administrar archivos de Google Drive que has abierto o creado con esta app
  - Justificación: Necesario para guardar y leer los archivos JSON de configuración y registros
```

### 3. Test users
```
Añadir tu email como usuario de prueba durante el desarrollo
Esto permitirá el acceso incluso antes de la verificación
```

## 🔑 Actualización de credenciales OAuth

### 1. Tipo de aplicación y URIs
```
Tipo de aplicación: Aplicación web
Nombre: OwnAutoCare Web
URIs de origen autorizados:
  - http://localhost:8080
  - http://localhost:8081
URIs de redirección autorizados:
  - http://localhost:8080
  - http://localhost:8081
```

### 2. Identificadores web
```javascript
// web/index.html
<meta name="google-signin-client_id" content="TU_CLIENT_ID.apps.googleusercontent.com">

// lib/secrets.dart
const String googleClientId = 'TU_CLIENT_ID.apps.googleusercontent.com';
```

## 🚀 Verificación de la aplicación

Para publicar la aplicación y eliminar la advertencia de "no verificada":

1. **Marca de verificación azul**
   - Requiere política de privacidad
   - Términos de servicio
   - Logotipo de la aplicación
   - Verificación del dominio

2. **Durante el desarrollo**
   - Usar usuarios de prueba (test users)
   - La advertencia no afecta a los usuarios agregados

## ⚙️ Configuración recomendada para desarrollo

```
OAuth consent screen:
  Publishing status: Testing
  User type: External
  Test users: Añadir tu email

Credenciales:
  Application type: Web application
  Authorized JavaScript origins:
    - http://localhost:8080
  Authorized redirect URIs:
    - http://localhost:8080

Scopes:
  - drive.file (acceso mínimo necesario)
```

## 🛡️ Mejores prácticas de seguridad

1. **Scopes mínimos**
   - Usar solo `drive.file` en lugar de `drive.appdata`
   - Acceso solo a archivos creados por la app

2. **Manejo de errores**
   - Implementar retry con backoff
   - Manejar token expired
   - Validar offline_access

3. **Testing**
   - Probar flujo completo con usuarios de prueba
   - Verificar manejo de permisos denegados
   - Validar refresh token workflow