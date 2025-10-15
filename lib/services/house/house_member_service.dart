import 'dart:convert';
import '../../config/app_config.dart';
import '../../models/house_member_models.dart';
import '../http_interceptor_service.dart';

/// Servicio para manejar los miembros de la casa
class HouseMemberService {
  
  /// Obtiene la lista de miembros de la casa activa del usuario
  static Future<List<HouseMemberInfo>> getHouseMembers() async {
    try {
      final response = await HttpInterceptorService.get(AppConfig.getMembersUrl);
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => HouseMemberInfo.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener miembros: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Crea un nuevo usuario invitado en la casa activa
  static Future<CreateGuestResponse> createGuest(String guestName) async {
    try {
      final request = CreateGuestRequest(guestName: guestName);
      print('Enviando petición a: ${AppConfig.createGuestUrl}');
      print('Body de la petición: ${request.toJson()}');
      
      final response = await HttpInterceptorService.post(
        AppConfig.createGuestUrl,
        body: request.toJson(),
      );
      
      print('Status code: ${response.statusCode}');
      print('Headers de respuesta: ${response.headers}');
      
      if (response.statusCode == 200) {
        try {
          print('Respuesta del servidor: ${response.body}');
          final jsonResponse = json.decode(response.body);
          print('JSON decodificado: $jsonResponse');
          return CreateGuestResponse.fromJson(jsonResponse);
        } catch (jsonError) {
          print('Error al decodificar JSON: $jsonError');
          print('Respuesta cruda: ${response.body}');
          throw Exception('Error al procesar respuesta del servidor: $jsonError');
        }
      } else {
        try {
          final errorBody = json.decode(response.body);
          throw Exception('Error al crear invitado: ${errorBody['message'] ?? 'Error ${response.statusCode}'}');
        } catch (jsonError) {
          throw Exception('Error al crear invitado: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      if (e.toString().contains('Exception')) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }
}
