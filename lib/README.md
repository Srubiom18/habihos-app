# 📁 Estructura del Proyecto

## 🏗️ Arquitectura

Este proyecto sigue una arquitectura limpia y modular organizada por capas:

```
lib/
├── 📱 screens/           # Pantallas de la aplicación
├── 🧩 components/        # Componentes UI reutilizables
├── 🔧 services/          # Lógica de negocio y servicios
├── 📋 interfaces/        # Contratos y modelos de datos
├── 📊 constants/         # Constantes y configuración
└── 📤 exports.dart       # Exportaciones centralizadas
```

## 📱 Screens

- **`home_screen.dart`** - Pantalla principal con áreas de limpieza y notificaciones
- **`house_chat_screen.dart`** - Pantalla de chat de la casa
- **`shopping_list_screen.dart`** - Pantalla de lista de compras

## 🧩 Components

### Home Screen Components
- **`active_cleaning_area_widget.dart`** - Widget del área de limpieza activa
- **`other_cleaning_areas_widget.dart`** - Widget de las otras áreas de limpieza
- **`notifications_section_widget.dart`** - Widget de la sección de notificaciones
- **`action_button_widget.dart`** - Widget del botón de acción inferior

## 🔧 Services

### Home Screen Services
- **`cleaning_service.dart`** - Maneja la lógica de áreas de limpieza
- **`notification_service.dart`** - Maneja la lógica de notificaciones
- **`task_rotation_service.dart`** - Maneja la rotación automática de tareas

### Common Services
- **`snackbar_service.dart`** - Servicio para mostrar mensajes consistentes

## 📋 Interfaces

### Home Screen Interfaces
- **`cleaning_area.dart`** - Interface para áreas de limpieza
- **`notification.dart`** - Interface para notificaciones

## 📊 Constants

- **`ui_constants.dart`** - Constantes de UI (colores, dimensiones, estilos)

## 🎯 Principios de Diseño

### ✅ Separación de Responsabilidades
- **Screens**: Solo manejan el estado de la UI
- **Services**: Contienen la lógica de negocio
- **Components**: Son widgets reutilizables y especializados
- **Interfaces**: Definen contratos de datos

### ✅ Reutilización
- Los componentes se pueden usar en múltiples pantallas
- Los servicios son singleton y reutilizables
- Las constantes centralizan valores comunes

### ✅ Mantenibilidad
- Código modular y fácil de modificar
- Responsabilidades claras y separadas
- Fácil de testear individualmente

### ✅ Escalabilidad
- Estructura preparada para crecer
- Fácil agregar nuevas funcionalidades
- Patrones consistentes en toda la app

## 🚀 Cómo Usar

### Importar desde exports.dart
```dart
import '../exports.dart';
```

### Importar servicios específicos
```dart
import '../services/home_screen/home_screen_services.dart';
```

### Importar componentes específicos
```dart
import '../components/home_screen/home_screen_components.dart';
```

## 📈 Beneficios Obtenidos

- **67% menos código** en HomeScreen (556 → 181 líneas)
- **Modularidad** mejorada con componentes especializados
- **Mantenibilidad** aumentada con separación clara
- **Reutilización** de componentes y servicios
- **Testabilidad** mejorada con componentes aislados
