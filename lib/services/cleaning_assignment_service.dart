import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/api_models.dart';
import 'auth_service.dart';

/// Servicio para manejar las asignaciones de usuarios a zonas de limpieza
class CleaningAssignmentService {
  static final CleaningAssignmentService _instance = CleaningAssignmentService._internal();
  factory CleaningAssignmentService() => _instance;
  CleaningAssignmentService._internal();


  /// Asigna un usuario a una zona de limpieza
  /// 
  /// [memberId] - ID del miembro a asignar
  /// [cleaningAreaId] - ID de la zona de limpieza
  /// Retorna la respuesta de la asignación o lanza una excepción
  Future<FixedAssignmentResponse> assignUserToCleaningArea({
    required String memberId,
    required String cleaningAreaId,
  }) async {
    try {
      final token = await AuthService.getCurrentToken();
      if (token == null) {
        throw Exception('No hay token de autenticación válido');
      }

      final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.apiVersion}/cleaning-areas/assign');
      
      final requestBody = {
        'memberId': memberId,
        'cleaningAreaId': cleaningAreaId,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        // Debug: imprimir respuesta de asignación
        print('=== DEBUG: Asignación exitosa ===');
        print('Status: ${response.statusCode}');
        print('Body: ${response.body}');
        
        return FixedAssignmentResponse.fromMap(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        
        // Debug: imprimir error de asignación
        print('=== DEBUG: Error en asignación ===');
        print('Status: ${response.statusCode}');
        print('Body: ${response.body}');
        
        throw Exception(errorData['message'] ?? 'Error al asignar usuario a la zona');
      }
    } catch (e) {
      throw Exception('Error al asignar usuario: ${e.toString()}');
    }
  }

  /// Desasigna un usuario de una zona de limpieza
  /// 
  /// [assignmentId] - ID de la asignación a eliminar
  /// Retorna true si se desasignó correctamente
  Future<bool> unassignUserFromCleaningArea(String assignmentId) async {
    try {
      final token = await AuthService.getCurrentToken();
      if (token == null) {
        throw Exception('No hay token de autenticación válido');
      }

      final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.apiVersion}/cleaning-areas/assign/$assignmentId');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      throw Exception('Error al desasignar usuario: ${e.toString()}');
    }
  }

  /// Obtiene todas las asignaciones fijas de la casa
  /// 
  /// Retorna lista de asignaciones fijas
  Future<List<FixedAssignmentResponse>> getFixedAssignments() async {
    try {
      final token = await AuthService.getCurrentToken();
      if (token == null) {
        throw Exception('No hay token de autenticación válido');
      }

      final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.apiVersion}/cleaning-areas/assignments');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map((data) => FixedAssignmentResponse.fromMap(data)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al obtener asignaciones');
      }
    } catch (e) {
      throw Exception('Error al obtener asignaciones: ${e.toString()}');
    }
  }

  /// Obtiene las asignaciones fijas de un miembro específico
  /// 
  /// [memberId] - ID del miembro
  /// Retorna lista de asignaciones del miembro
  Future<List<FixedAssignmentResponse>> getMemberAssignments(String memberId) async {
    try {
      final token = await AuthService.getCurrentToken();
      if (token == null) {
        throw Exception('No hay token de autenticación válido');
      }

      final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.apiVersion}/cleaning-areas/assignments/member/$memberId');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map((data) => FixedAssignmentResponse.fromMap(data)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al obtener asignaciones del miembro');
      }
    } catch (e) {
      throw Exception('Error al obtener asignaciones del miembro: ${e.toString()}');
    }
  }

  /// Obtiene las zonas sin asignación fija
  /// 
  /// Retorna lista de zonas no asignadas
  Future<List<CleaningAreaResponse>> getUnassignedAreas() async {
    try {
      final token = await AuthService.getCurrentToken();
      if (token == null) {
        throw Exception('No hay token de autenticación válido');
      }

      final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.apiVersion}/cleaning-areas/unassigned');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map((data) => CleaningAreaResponse.fromMap(data)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al obtener zonas sin asignar');
      }
    } catch (e) {
      throw Exception('Error al obtener zonas sin asignar: ${e.toString()}');
    }
  }

  /// Verifica si una zona está asignada de forma fija
  /// 
  /// [areaId] - ID de la zona
  /// Retorna true si está asignada, false en caso contrario
  Future<bool> isAreaFixedlyAssigned(String areaId) async {
    try {
      final token = await AuthService.getCurrentToken();
      if (token == null) {
        throw Exception('No hay token de autenticación válido');
      }

      final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.apiVersion}/cleaning-areas/$areaId/is-assigned');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as bool;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
