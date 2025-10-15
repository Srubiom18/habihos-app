import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/api_models.dart';
import 'auth_service.dart';
import 'cleaning_assignment_service.dart';

/// Servicio para manejar los miembros de la casa
class HouseMembersService {
  static final HouseMembersService _instance = HouseMembersService._internal();
  factory HouseMembersService() => _instance;
  HouseMembersService._internal();


  /// Obtiene todos los miembros de la casa
  /// 
  /// Retorna lista de información de miembros de la casa
  Future<List<HouseMemberInfoResponse>> getHouseMembers() async {
    try {
      final token = await AuthService.getCurrentToken();
      if (token == null) {
        throw Exception('No hay token de autenticación válido');
      }

      final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.apiVersion}/house-members/members');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        
        // Debug: imprimir respuesta de la API
        print('=== DEBUG: Respuesta API miembros ===');
        print('Status: ${response.statusCode}');
        print('Body: ${response.body}');
        
        return responseData.map((data) => HouseMemberInfoResponse.fromMap(data)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al obtener miembros de la casa');
      }
    } catch (e) {
      throw Exception('Error al obtener miembros: ${e.toString()}');
    }
  }

  /// Obtiene un miembro específico por ID
  /// 
  /// [memberId] - ID del miembro
  /// Retorna información del miembro o null si no existe
  Future<HouseMemberInfoResponse?> getMemberById(String memberId) async {
    try {
      final members = await getHouseMembers();
      return members.firstWhere(
        (member) => member.id == memberId,
        orElse: () => throw Exception('Miembro no encontrado'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Filtra miembros que no están asignados a una zona específica
  /// 
  /// [cleaningAreaId] - ID de la zona de limpieza
  /// Retorna lista de miembros disponibles para asignar
  Future<List<HouseMemberInfoResponse>> getAvailableMembersForArea(String cleaningAreaId) async {
    try {
      final allMembers = await getHouseMembers();
      final assignmentService = CleaningAssignmentService();
      final assignments = await assignmentService.getFixedAssignments();
      
      // Obtener IDs de miembros ya asignados a esta zona
      final assignedMemberIds = assignments
          .where((assignment) => assignment.cleaningAreaId == cleaningAreaId)
          .map((assignment) => assignment.memberId)
          .toSet();
      
      // Filtrar miembros no asignados a esta zona
      return allMembers
          .where((member) => !assignedMemberIds.contains(member.id))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener miembros disponibles: ${e.toString()}');
    }
  }
}