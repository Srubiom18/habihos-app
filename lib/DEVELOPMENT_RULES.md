# 📋 REGLA ÚNICA DE DESARROLLO FLUTTER
## PATRÓN "LAYERED COMPONENT ARCHITECTURE"

### 🎯 OBJETIVO
Mantener un patrón consistente por capas, evitando duplicados, documentando todo, y reutilizando funciones/componentes existentes.

---

## 📁 ESTRUCTURA BASE

```
lib/
├── config/                    # Configuración global
│   ├── routes.dart
│   ├── di.dart
│   ├── ui_constants.dart
│   └── env.dart
├── shared/                    # Utilidades transversales
│   ├── widgets/
│   ├── utils/
│   └── extensions/
├── features/                  # Funcionalidades por feature
│   └── <feature>/
│       ├── components/        # UI: pages, widgets, controller
│       │   ├── pages/
│       │   ├── widgets/
│       │   ├── <feature>_controller.dart
│       │   └── <feature>_state.dart
│       ├── services/          # Lógica de negocio
│       │   └── <feature>_service.dart
│       ├── models/            # Modelos de API
│       │   └── <feature>_models.dart
│       ├── interfaces/        # Contratos
│       │   └── <feature>_interfaces.dart
│       ├── components.dart    # Exportador interno
│       └── services.dart      # Exportador interno
└── exports.dart               # Índice global
```

---

## 🎯 LA REGLA DE LOS 4 NIVELES

### NIVEL 1: Estructura base por feature
Crear directorios: `components/`, `services/`, `models/`, `interfaces/`

### NIVEL 2: Implementar los 4 archivos base
1. `<feature>_controller.dart` - Navegación y acciones
2. `<feature>_service.dart` - Lógica de negocio
3. `<feature>_models.dart` - DTOs y mappers
4. `<feature>_interfaces.dart` - Contratos

### NIVEL 3: Crear exportadores internos
1. `components.dart` - Exporta UI y controlador
2. `services.dart` - Exporta servicios e interfaces

### NIVEL 4: Actualizar exports.dart
Añadir líneas para la nueva feature

---

## ✅ CHECKLIST RÁPIDO

- [ ] ¿Reutilización: revisé si existe algo similar en shared/?
- [ ] ¿Sin duplicados: extraje helpers comunes?
- [ ] ¿Documentación: docstrings en clases públicas?
- [ ] ¿Lógica de negocio solo en services/?
- [ ] ¿Interfaces: servicios dependen de interfaces?
- [ ] ¿Modelos: DTOs con fromJson/toJson?
- [ ] ¿Seguridad: token via AuthService.getCurrentToken()?
- [ ] ¿Config: estilos en ui_constants.dart?
- [ ] ¿Errores tipados: Result/Failure?
- [ ] ¿Rendimiento: const en widgets inmutables?
- [ ] ¿Tests: unit tests de servicio y controller?
- [ ] ¿Lints: cumplir flutter_lints?
- [ ] ¿Exports: barrel files locales?

---

## 📝 PLANTILLAS MÍNIMAS

### Controller
```dart
/// Controlador de la feature <feature>. Orquesta navegación y acciones de UI.
class <Feature>Controller {
  final <Feature>Service service;
  <Feature>State state;

  <Feature>Controller({required this.service}) : state = const <Feature>State.idle();

  /// Carga inicial de datos.
  Future<void> load() async {
    state = const <Feature>State.loading();
    try {
      final data = await service.fetchInitial();
      state = <Feature>State.ready(data);
    } catch (e) {
      state = <Feature>State.error('No se pudo cargar la información');
    }
  }
}
```

### Service
```dart
/// Servicio de negocio para <feature>.
class <Feature>Service {
  final I<Feature>Api api;
  final AuthService auth;

  <Feature>Service({required this.api, required this.auth});

  Future<Object> fetchInitial() async {
    final token = await auth.getCurrentToken();
    final dto = await api.getInitial(token);
    return dto;
  }
}
```

### Models
```dart
/// DTOs de la feature <feature> para intercambio con la API.
class <Feature>Dto {
  final String id;
  final String name;

  <Feature>Dto({required this.id, required this.name});

  factory <Feature>Dto.fromJson(Map<String, dynamic> j) =>
      <Feature>Dto(id: j['id'] as String, name: j['name'] as String);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
```

---

## 🎯 REGLA MEMORIZABLE

**"4 NIVELES, 4 ARCHIVOS, 2 EXPORTADORES, 4 LÍNEAS"**

- 4 niveles: Estructura → Archivos base → Exportadores → Integración
- 4 archivos: controller, service, models, interfaces
- 2 exportadores: components.dart, services.dart
- 4 líneas: en exports.dart

---

## 🚀 IMPLEMENTACIÓN GRADUAL

1. **FASE 1**: Aplicar a nuevas funcionalidades
2. **FASE 2**: Migrar features existentes cuando se modifiquen
3. **FASE 3**: Limpiar duplicados y estandarizar

---

*Última actualización: $(date)*
