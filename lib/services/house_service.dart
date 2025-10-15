import 'dart:convert';
import '../config/app_config.dart';
import '../models/api_models.dart';
import 'auth_service.dart';
import 'http_interceptor_service.dart';

class HouseService {
  // Verificar si la casa está activa
  static Future<bool> isHouseActive() async {
    try {
      final response = await HttpInterceptorService.post(
        '${AppConfig.baseUrl}${AppConfig.apiVersion}/house/is-active',
      ).timeout(
        const Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (response.statusCode == 200) {
        final bool isActive = json.decode(response.body) as bool;
        return isActive;
      } else if (response.statusCode == 401) {
        throw Exception('Token de autenticación inválido');
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

  // Crear una nueva casa
  static Future<CreateHouseResponse> createHouse(CreateHouseRequest request) async {
    try {
      final response = await HttpInterceptorService.post(
        '${AppConfig.baseUrl}${AppConfig.apiVersion}/house/init-new-home',
        body: request.toMap(),
      ).timeout(
        const Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // El servidor ahora devuelve el nuevo token con houseId
        final newToken = response.body;
        
        if (newToken.isNotEmpty) {
          // Guardar el nuevo token
          await AuthService.updateToken(newToken);
        }
        
        // Crear respuesta básica ya que el token se actualizó
        return CreateHouseResponse(
          id: 'created',
          name: 'Casa creada',
          ownerId: 'current_user',
          isActive: true,
          maxParticipants: 0,
          pricePerParticipant: 0,
          totalPrice: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else if (response.statusCode == 401) {
        throw Exception('Token de autenticación inválido');
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error en los datos enviados');
      } else if (response.statusCode == 409) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Ya tienes una casa activa');
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
