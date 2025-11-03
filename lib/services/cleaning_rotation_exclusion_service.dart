import 'dart:convert';
import '../config/app_config.dart';
import 'http_interceptor_service.dart';
import '../models/api_models.dart';

/// Servicio para gestionar las exclusiones de rotación de limpieza
class CleaningRotationExclusionService {
  static const String _baseEndpoint = '/rotation-exclusions';

  /// Crea una nueva exclusión de rotación
  static Future<CleaningRotationExclusionResponse> createExclusion(
    String memberId,
    String cleaningAreaId, {
    String? reason,
  }) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}$_baseEndpoint';
      
      final body = {
        'memberId': memberId,
        'cleaningAreaId': cleaningAreaId,
        'reason': reason,
        'expiresAt': null, // Exclusión permanente por defecto
      };
      
      print('URL de creación de exclusión: $url');
      print('Datos enviados: $body');
      
      final response = await HttpInterceptorService.post(url, body: body);

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return CleaningRotationExclusionResponse.fromMap(json);
      } else {
        throw Exception('Error al crear exclusión: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Elimina una exclusión de rotación existente
  static Future<void> removeExclusion(String exclusionId) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}$_baseEndpoint/$exclusionId';
      
      print('URL de eliminación de exclusión: $url');
      
      final response = await HttpInterceptorService.delete(url);

      if (response.statusCode != 204) {
        throw Exception('Error al eliminar exclusión: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
