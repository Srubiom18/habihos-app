# 📱 Guía de Conexión: Emulador Android + API Local

## 🚨 **Problema Identificado**

El emulador de Android **NO** puede acceder a `localhost` de tu máquina host. Esto es un problema común en desarrollo móvil.

## ✅ **Solución Implementada**

He actualizado `app_config.dart` para detectar automáticamente la plataforma y usar la URL correcta:

### **URLs por Plataforma:**
- **Android Emulator**: `http://10.0.2.2:8080` ✅
- **iOS Simulator**: `http://localhost:8080` ✅  
- **Web/Desktop**: `http://localhost:8080` ✅

## 🔧 **Cómo Funciona**

### **1. IP Especial para Emulador Android**
- `10.0.2.2` es una IP especial que el emulador Android usa para referenciar la máquina host
- Es equivalente a `localhost` pero desde la perspectiva del emulador

### **2. Detección Automática**
```dart
static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8080'; // Emulador Android
  } else if (Platform.isIOS) {
    return 'http://localhost:8080'; // Simulador iOS
  } else {
    return 'http://localhost:8080'; // Web/Desktop
  }
}
```

## 🧪 **Cómo Probar**

### **1. Con Emulador Android:**
1. ✅ Inicia tu API en `localhost:8080`
2. ✅ Ejecuta la app en emulador Android
3. ✅ El login debería funcionar automáticamente

### **2. Con Dispositivo Físico:**
Si quieres probar en un dispositivo físico, necesitarás:

1. **Encontrar tu IP local:**
   ```bash
   # Windows
   ipconfig
   
   # Mac/Linux  
   ifconfig
   ```

2. **Actualizar la configuración:**
   ```dart
   // En app_config.dart, cambiar:
   static const String networkUrl = 'http://192.168.1.XXX:8080'; // Tu IP real
   ```

3. **Usar la IP de red:**
   ```dart
   static String get baseUrl {
     if (Platform.isAndroid) {
       return 'http://192.168.1.XXX:8080'; // Tu IP real
     }
     // ...
   }
   ```

## 🔍 **Verificar Coneectividad**

### **1. Desde el Emulador:**
```bash
# En terminal del emulador (si tienes acceso)
curl http://10.0.2.2:8080/api/v1/auth/login
```

### **2. Desde tu Máquina:**
```bash
# Verificar que tu API responde
curl http://localhost:8080/api/v1/auth/login
```

## ⚠️ **Posibles Problemas**

### **1. Firewall:**
- Asegúrate de que el puerto 8080 esté abierto
- Windows Defender puede bloquear conexiones

### **2. API no accesible:**
- Verifica que tu API esté ejecutándose
- Comprueba que escuche en `0.0.0.0:8080` (no solo `127.0.0.1:8080`)

### **3. Red diferente:**
- Si estás en una red corporativa, puede haber restricciones
- Usa la IP de red real en lugar de `10.0.2.2`

## 🚀 **Configuración Recomendada para Producción**

Para diferentes entornos, puedes crear configuraciones específicas:

```dart
class AppConfig {
  static const bool isDevelopment = true; // Cambiar a false en producción
  
  static String get baseUrl {
    if (isDevelopment) {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080';
      }
      return 'http://localhost:8080';
    } else {
      return 'https://tu-api-produccion.com';
    }
  }
}
```

## ✅ **Estado Actual**

- ✅ Configuración automática por plataforma
- ✅ Emulador Android: `10.0.2.2:8080`
- ✅ iOS/Web: `localhost:8080`
- ✅ Listo para probar

**¡Tu app debería conectarse correctamente con la API desde el emulador Android!** 🎉
