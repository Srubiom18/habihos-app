import 'dart:io';

class AppConfig {
  // Configuración de la API
  static const String apiVersion = '/api/v1';
  
  // Detectar automáticamente la URL base según la plataforma
  static String get baseUrl {
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
  
  // URLs alternativas para diferentes escenarios
  static const String androidEmulatorUrl = 'http://10.0.2.2:8080';
  static const String localhostUrl = 'http://localhost:8080';
  static const String networkUrl = 'http://192.168.1.XXX:8080'; // Cambiar XXX por tu IP real
  
  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String guestLoginEndpoint = '/house-members/guest-login';
  static const String joinHouseEndpoint = '/house/join';
  static const String createGuestEndpoint = '/house-members/create-guest';
  static const String getMembersEndpoint = '/house-members/members';
  
  // Configuración de JWT
  static const String jwtSecret = 'your-jwt-secret'; // Esto debería estar en variables de entorno
  static const int jwtExpirationHours = 24;
  
  // Configuración de la app
  static const String appName = 'Mi Casa';
  static const String appVersion = '1.0.0';
  
  // URLs completas
  static String get loginUrl => '$baseUrl$apiVersion$loginEndpoint';
  static String get guestLoginUrl => '$baseUrl$apiVersion$guestLoginEndpoint';
  static String get joinHouseUrl => '$baseUrl$apiVersion$joinHouseEndpoint';
  static String get createGuestUrl => '$baseUrl$apiVersion$createGuestEndpoint';
  static String get getMembersUrl => '$baseUrl$apiVersion$getMembersEndpoint';
  
  // Configuración de timeouts
  static const int connectionTimeout = 30000; // 30 segundos
  static const int receiveTimeout = 30000; // 30 segundos
}
