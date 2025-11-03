import 'dart:convert';
import '../config/app_config.dart';
import '../models/api_models.dart';
import 'http_interceptor_service.dart';

class UserProfileService {
  // Obtener información del perfil de usuario
  static Future<UserProfileResponse> getUserProfile() async {
    try {
      final response = await HttpInterceptorService.get(
        '${AppConfig.baseUrl}${AppConfig.apiVersion}/user/profile',
      ).timeout(
        const Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserProfileResponse.fromMap(data);
      } else if (response.statusCode == 401) {
        throw Exception('Token de autenticación inválido');
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Tiempo de espera agotado. Verifica tu conexión.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor. Verifica que la API esté ejecutándose.');
      } else {
        throw Exception('Error de conexión: ${e.toString()}');
      }
    }
  }

  // Actualizar perfil de usuario
  static Future<UserProfileResponse> updateUserProfile(UpdateUserProfileRequest request) async {
    try {
      final response = await HttpInterceptorService.put(
        '${AppConfig.baseUrl}${AppConfig.apiVersion}/user/profile',
        body: request.toMap(),
      ).timeout(
        const Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserProfileResponse.fromMap(data);
      } else if (response.statusCode == 401) {
        throw Exception('Token de autenticación inválido');
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error en los datos enviados');
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Tiempo de espera agotado. Verifica tu conexión.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor. Verifica que la API esté ejecutándose.');
      } else {
        throw Exception('Error de conexión: ${e.toString()}');
      }
    }
  }
}
