import 'dart:convert';
import '../config/app_config.dart';
import 'http_interceptor_service.dart';
import '../models/api_models.dart';

/// Servicio para gestionar el calendario de limpieza
class CleaningCalendarService {
  static const String _baseEndpoint = '/cleaning-schedule';

  /// Obtiene el calendario de limpieza con información de usuarios asignados
  static Future<CleaningCalendarResponse> getCleaningCalendar() async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}$_baseEndpoint/calendar';
      final response = await HttpInterceptorService.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return CleaningCalendarResponse.fromMap(json);
      } else {
        throw Exception('Error al obtener calendario de limpieza: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Activa o desactiva la rotación de limpieza
  static Future<void> toggleRotation(bool isActive) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}/cleaning-rotation/toggle';
      final response = await HttpInterceptorService.put(
        url,
        body: {'isActive': isActive},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al cambiar estado de rotación: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Asigna un usuario a una zona de limpieza
  static Future<void> assignUserToZone(String areaId, String memberId) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}/cleaning-areas/assign';
      print('URL de asignación: $url');
      print('Datos enviados: cleaningAreaId=$areaId, memberId=$memberId');
      
      final response = await HttpInterceptorService.post(
        url,
        body: {
          'cleaningAreaId': areaId,
          'memberId': memberId,
        },
      );

      print('Respuesta de asignación: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al asignar usuario a zona: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en assignUserToZone: $e');
      rethrow;
    }
  }

  /// Obtiene las asignaciones fijas de la casa
  static Future<List<FixedAssignmentResponse>> getFixedAssignments() async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}/cleaning-areas/assignments';
      print('URL de asignaciones: $url');
      
      final response = await HttpInterceptorService.get(url);

      print('Respuesta de asignaciones: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => FixedAssignmentResponse.fromMap(json)).toList();
      } else {
        throw Exception('Error al obtener asignaciones: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en getFixedAssignments: $e');
      rethrow;
    }
  }

  /// Desasigna un usuario de una zona de limpieza
  static Future<void> unassignUserFromZone(String assignmentId) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}/cleaning-areas/assign/$assignmentId';
      print('URL de desasignación: $url');
      print('AssignmentId: $assignmentId');
      
      final response = await HttpInterceptorService.delete(url);

      print('Respuesta de desasignación: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al desasignar usuario de zona: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en unassignUserFromZone: $e');
      rethrow;
    }
  }
}
