# 🔐 Sistema de Autenticación - Mi Casa App

## 📋 Resumen de Implementación

He implementado un sistema de autenticación completo que se conecta con tu API local. El sistema incluye:

### ✅ Archivos Creados

1. **`config/app_config.dart`** - Configuración de la API y endpoints
2. **`models/auth_models.dart`** - Modelos de datos para login y JWT
3. **`services/jwt_service.dart`** - Servicio para decodificar tokens JWT
4. **`services/auth_service.dart`** - Servicio principal de autenticación
5. **`test_jwt.dart`** - Archivo de prueba para verificar JWT (se puede eliminar)

### 🔧 Configuración Actual

- **URL Base**: `http://localhost:8080`
- **Endpoint Login**: `/api/v1/auth/login`
- **URL Completa**: `http://localhost:8080/api/v1/auth/login`

### 🚀 Funcionalidades Implementadas

#### Login Funcional
- ✅ Conexión real con tu API
- ✅ Envío de credenciales (email/password)
- ✅ Recepción y decodificación de JWT
- ✅ Extracción de información del usuario (ID, nickname, roles, permisos)
- ✅ Manejo de errores (credenciales incorrectas, servidor no disponible, etc.)
- ✅ Indicador de carga durante el proceso
- ✅ Navegación automática al home tras login exitoso

#### Decodificación JWT
- ✅ Decodificación completa del payload
- ✅ Extracción de información del usuario
- ✅ Validación de expiración del token
- ✅ Manejo de tokens inválidos

### 🧪 Prueba del JWT

El JWT que proporcionaste se decodifica correctamente y contiene:
- **ID Usuario**: `67ee0af8-1d94-4264-bc82-0bd7e2b0ac89`
- **Nickname**: `Admin Sistema`
- **Roles**: `["ADMIN"]`
- **Permisos**: `["CAN_MANAGE_USERS", "CAN_MANAGE_ROLES", "CAN_MANAGE_CLEANING_AREAS"]`

### 🔄 Flujo de Autenticación

1. **Usuario ingresa credenciales** en `LoginScreen`
2. **Se valida el formulario** (email válido, contraseña no vacía)
3. **Se envía petición POST** a `http://localhost:8080/api/v1/auth/login`
4. **API responde con JWT** como string
5. **Se decodifica el JWT** para extraer información del usuario
6. **Se navega al home** si es exitoso
7. **Se muestra error** si falla

### ⚠️ Próximos Pasos

Para completar la implementación necesitarás:

1. **Agregar SharedPreferences** para persistir el token:
   ```yaml
   dependencies:
     shared_preferences: ^2.2.2
   ```

2. **Implementar logout** con llamada al endpoint correspondiente

3. **Agregar interceptor HTTP** para incluir el token en las peticiones

4. **Implementar refresh token** si tu API lo soporta

### 🧪 Cómo Probar

1. **Asegúrate de que tu API esté ejecutándose** en `localhost:8080`
2. **Usa credenciales válidas** de tu base de datos
3. **Verifica la consola** para ver los logs de la petición
4. **El login debería funcionar** y llevarte al home

### 🐛 Manejo de Errores

El sistema maneja los siguientes errores:
- **401**: Credenciales incorrectas
- **400**: Datos de login inválidos
- **Timeout**: Servidor no responde
- **SocketException**: API no disponible
- **JWT inválido**: Token malformado

### 📱 Estado de la UI

- **Loading**: Botón deshabilitado con spinner
- **Éxito**: Navegación automática + mensaje de bienvenida
- **Error**: Mensaje de error en SnackBar

¡El sistema está listo para usar! 🎉
