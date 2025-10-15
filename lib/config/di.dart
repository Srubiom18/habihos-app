/// Configuración de Inyección de Dependencias
/// 
/// Este archivo centraliza la configuración de dependencias
/// para facilitar el testing y la mantenibilidad.

import '../services/auth_service.dart';
import '../services/house_service.dart';
import '../services/jwt_service.dart';
import '../services/http_interceptor_service.dart';
import '../services/common/snackbar_service.dart';
import '../services/common/user_context_service.dart';

/// Contenedor de dependencias simple
class DIContainer {
  static final DIContainer _instance = DIContainer._internal();
  factory DIContainer() => _instance;
  DIContainer._internal();

  // Servicios singleton
  late final AuthService _authService;
  late final HouseService _houseService;
  late final JwtService _jwtService;
  late final HttpInterceptorService _httpInterceptorService;
  late final SnackBarService _snackBarService;
  late final UserContextService _userContextService;

  /// Inicializa todas las dependencias
  void initialize() {
    // Inicializar servicios en orden de dependencia
    _jwtService = JwtService();
    _httpInterceptorService = HttpInterceptorService();
    _snackBarService = SnackBarService();
    _userContextService = UserContextService();
    _authService = AuthService();
    _houseService = HouseService();
  }

  /// Obtiene el servicio de autenticación
  AuthService get authService => _authService;

  /// Obtiene el servicio de casas
  HouseService get houseService => _houseService;

  /// Obtiene el servicio JWT
  JwtService get jwtService => _jwtService;

  /// Obtiene el servicio de interceptor HTTP
  HttpInterceptorService get httpInterceptorService => _httpInterceptorService;

  /// Obtiene el servicio de SnackBar
  SnackBarService get snackBarService => _snackBarService;

  /// Obtiene el servicio de contexto de usuario
  UserContextService get userContextService => _userContextService;

  /// Resetea todas las dependencias (útil para testing)
  void reset() {
    // Reinicializar todas las dependencias
    initialize();
  }
}

/// Instancia global del contenedor de dependencias
final DIContainer di = DIContainer();

/// Extensiones para facilitar el acceso a dependencias
extension DIExtensions on DIContainer {
  /// Verifica si las dependencias están inicializadas
  bool get isInitialized {
    try {
      // Intentar acceder a un servicio para verificar si está inicializado
      final _ = _authService;
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Factory para crear instancias de servicios con dependencias inyectadas
class ServiceFactory {
  /// Crea un servicio con sus dependencias inyectadas
  static T createService<T>(T Function() factory) {
    return factory();
  }

  /// Crea un servicio con dependencias específicas
  static T createServiceWithDeps<T>(
    T Function(DIContainer container) factory,
  ) {
    return factory(di);
  }
}

/// Mixin para servicios que necesitan acceso a dependencias
mixin DIAccess {
  /// Obtiene el contenedor de dependencias
  DIContainer get di => DIContainer();

  /// Obtiene el servicio de autenticación
  AuthService get authService => di.authService;

  /// Obtiene el servicio de casas
  HouseService get houseService => di.houseService;

  /// Obtiene el servicio JWT
  JwtService get jwtService => di.jwtService;

  /// Obtiene el servicio de SnackBar
  SnackBarService get snackBarService => di.snackBarService;

  /// Obtiene el servicio de contexto de usuario
  UserContextService get userContextService => di.userContextService;
}

/// Clase base para servicios que siguen el patrón de inyección de dependencias
abstract class BaseService {
  /// Inicializa el servicio con sus dependencias
  void initialize(DIContainer container);

  /// Limpia los recursos del servicio
  void dispose();
}

/// Registro de servicios para testing
class ServiceRegistry {
  static final Map<Type, dynamic> _services = {};

  /// Registra un servicio para testing
  static void register<T>(T service) {
    _services[T] = service;
  }

  /// Obtiene un servicio registrado
  static T? get<T>() {
    return _services[T] as T?;
  }

  /// Limpia todos los servicios registrados
  static void clear() {
    _services.clear();
  }
}
