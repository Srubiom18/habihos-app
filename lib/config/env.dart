/// Configuración de variables de entorno
/// 
/// Este archivo maneja las variables de entorno y configuración
/// específica del entorno de ejecución.

import 'dart:io';

/// Configuración de entorno de la aplicación
class Environment {
  // Constructor privado para evitar instanciación
  Environment._();

  /// Entorno actual
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  /// Verifica si estamos en desarrollo
  static bool get isDevelopment => _environment == 'development';

  /// Verifica si estamos en producción
  static bool get isProduction => _environment == 'production';

  /// Verifica si estamos en testing
  static bool get isTesting => _environment == 'testing';

  /// Obtiene el entorno actual
  static String get current => _environment;

  /// Configuración de la API según el entorno
  static ApiConfig get apiConfig {
    switch (_environment) {
      case 'production':
        return ApiConfig.production();
      case 'testing':
        return ApiConfig.testing();
      default:
        return ApiConfig.development();
    }
  }

  /// Configuración de logging según el entorno
  static LoggingConfig get loggingConfig {
    switch (_environment) {
      case 'production':
        return LoggingConfig.production();
      case 'testing':
        return LoggingConfig.testing();
      default:
        return LoggingConfig.development();
    }
  }

  /// Configuración de debugging según el entorno
  static DebugConfig get debugConfig {
    switch (_environment) {
      case 'production':
        return DebugConfig.production();
      case 'testing':
        return DebugConfig.testing();
      default:
        return DebugConfig.development();
    }
  }
}

/// Configuración de la API
class ApiConfig {
  final String baseUrl;
  final String apiVersion;
  final int connectionTimeout;
  final int receiveTimeout;
  final bool enableLogging;
  final bool enableRetry;

  const ApiConfig({
    required this.baseUrl,
    required this.apiVersion,
    required this.connectionTimeout,
    required this.receiveTimeout,
    required this.enableLogging,
    required this.enableRetry,
  });

  /// Configuración para desarrollo
  factory ApiConfig.development() {
    return ApiConfig(
      baseUrl: _getBaseUrl(),
      apiVersion: '/api/v1',
      connectionTimeout: 30000, // 30 segundos
      receiveTimeout: 30000, // 30 segundos
      enableLogging: true,
      enableRetry: true,
    );
  }

  /// Configuración para testing
  factory ApiConfig.testing() {
    return ApiConfig(
      baseUrl: 'http://localhost:8080',
      apiVersion: '/api/v1',
      connectionTimeout: 10000, // 10 segundos
      receiveTimeout: 10000, // 10 segundos
      enableLogging: false,
      enableRetry: false,
    );
  }

  /// Configuración para producción
  factory ApiConfig.production() {
    return ApiConfig(
      baseUrl: 'https://api.micasa.com',
      apiVersion: '/api/v1',
      connectionTimeout: 15000, // 15 segundos
      receiveTimeout: 15000, // 15 segundos
      enableLogging: false,
      enableRetry: true,
    );
  }

  /// Obtiene la URL base según la plataforma
  static String _getBaseUrl() {
    if (Platform.isAndroid) {
      // Para emulador Android, usar IP especial
      return 'http://10.0.2.2:8080';
    } else if (Platform.isIOS) {
      // Para simulador iOS, usar localhost
      return 'http://localhost:8080';
    } else {
      // Para web/desktop, usar localhost
      return 'http://localhost:8080';
    }
  }

  /// URLs alternativas para diferentes escenarios
  static const String androidEmulatorUrl = 'http://10.0.2.2:8080';
  static const String localhostUrl = 'http://localhost:8080';
  static const String networkUrl = 'http://192.168.1.XXX:8080'; // Cambiar XXX por tu IP real

  /// Obtiene la URL completa de la API
  String get fullUrl => '$baseUrl$apiVersion';
}

/// Configuración de logging
class LoggingConfig {
  final bool enableConsoleLogging;
  final bool enableFileLogging;
  final String logLevel;
  final int maxLogFiles;
  final int maxLogFileSize;

  const LoggingConfig({
    required this.enableConsoleLogging,
    required this.enableFileLogging,
    required this.logLevel,
    required this.maxLogFiles,
    required this.maxLogFileSize,
  });

  /// Configuración para desarrollo
  factory LoggingConfig.development() {
    return const LoggingConfig(
      enableConsoleLogging: true,
      enableFileLogging: false,
      logLevel: 'DEBUG',
      maxLogFiles: 5,
      maxLogFileSize: 1024 * 1024, // 1MB
    );
  }

  /// Configuración para testing
  factory LoggingConfig.testing() {
    return const LoggingConfig(
      enableConsoleLogging: false,
      enableFileLogging: false,
      logLevel: 'ERROR',
      maxLogFiles: 1,
      maxLogFileSize: 100 * 1024, // 100KB
    );
  }

  /// Configuración para producción
  factory LoggingConfig.production() {
    return const LoggingConfig(
      enableConsoleLogging: false,
      enableFileLogging: true,
      logLevel: 'WARNING',
      maxLogFiles: 10,
      maxLogFileSize: 5 * 1024 * 1024, // 5MB
    );
  }
}

/// Configuración de debugging
class DebugConfig {
  final bool enableDebugMode;
  final bool enablePerformanceOverlay;
  final bool enableWidgetInspector;
  final bool enableSlowAnimations;
  final bool enableSemanticsDebugger;

  const DebugConfig({
    required this.enableDebugMode,
    required this.enablePerformanceOverlay,
    required this.enableWidgetInspector,
    required this.enableSlowAnimations,
    required this.enableSemanticsDebugger,
  });

  /// Configuración para desarrollo
  factory DebugConfig.development() {
    return const DebugConfig(
      enableDebugMode: true,
      enablePerformanceOverlay: false,
      enableWidgetInspector: false,
      enableSlowAnimations: false,
      enableSemanticsDebugger: false,
    );
  }

  /// Configuración para testing
  factory DebugConfig.testing() {
    return const DebugConfig(
      enableDebugMode: false,
      enablePerformanceOverlay: false,
      enableWidgetInspector: false,
      enableSlowAnimations: false,
      enableSemanticsDebugger: false,
    );
  }

  /// Configuración para producción
  factory DebugConfig.production() {
    return const DebugConfig(
      enableDebugMode: false,
      enablePerformanceOverlay: false,
      enableWidgetInspector: false,
      enableSlowAnimations: false,
      enableSemanticsDebugger: false,
    );
  }
}

/// Configuración de la aplicación
class AppConfig {
  /// Nombre de la aplicación
  static const String appName = 'Mi Casa';

  /// Versión de la aplicación
  static const String appVersion = '1.0.0';

  /// Configuración de JWT
  static const String jwtSecret = 'your-jwt-secret'; // Esto debería estar en variables de entorno
  static const int jwtExpirationHours = 24;

  /// Endpoints de la API
  static const String loginEndpoint = '/auth/login';
  static const String guestLoginEndpoint = '/house-members/guest-login';
  static const String joinHouseEndpoint = '/house/join';
  static const String createGuestEndpoint = '/house-members/create-guest';
  static const String getMembersEndpoint = '/house-members/members';

  /// URLs completas
  static String get loginUrl => '${Environment.apiConfig.fullUrl}$loginEndpoint';
  static String get guestLoginUrl => '${Environment.apiConfig.fullUrl}$guestLoginEndpoint';
  static String get joinHouseUrl => '${Environment.apiConfig.fullUrl}$joinHouseEndpoint';
  static String get createGuestUrl => '${Environment.apiConfig.fullUrl}$createGuestEndpoint';
  static String get getMembersUrl => '${Environment.apiConfig.fullUrl}$getMembersEndpoint';
}
