import 'dart:convert';
import '../config/app_config.dart';
import 'http_interceptor_service.dart';
import '../models/api_models.dart';

/// Servicio para gestionar las zonas de limpieza
class CleaningAreaService {
  static const String _baseEndpoint = '/cleaning-areas';

  /// Obtiene todas las zonas de limpieza de la casa
  static Future<List<CleaningAreaResponse>> getCleaningAreas() async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}$_baseEndpoint';
      final response = await HttpInterceptorService.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => CleaningAreaResponse.fromMap(json))
            .toList();
      } else {
        throw Exception('Error al obtener zonas de limpieza: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene una zona de limpieza por ID
  static Future<CleaningAreaResponse> getCleaningAreaById(String areaId) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}$_baseEndpoint/$areaId';
      final response = await HttpInterceptorService.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return CleaningAreaResponse.fromMap(json);
      } else {
        throw Exception('Error al obtener zona de limpieza: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Crea una nueva zona de limpieza
  static Future<CleaningAreaResponse> createCleaningArea(
    CreateCleaningAreaRequest request,
  ) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}$_baseEndpoint';
      final response = await HttpInterceptorService.post(
        url,
        body: request.toMap(),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return CleaningAreaResponse.fromMap(json);
      } else {
        throw Exception('Error al crear zona de limpieza: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Actualiza una zona de limpieza existente
  static Future<CleaningAreaResponse> updateCleaningArea(
    String areaId,
    CreateCleaningAreaRequest request,
  ) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}$_baseEndpoint/$areaId';
      final response = await HttpInterceptorService.put(
        url,
        body: request.toMap(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return CleaningAreaResponse.fromMap(json);
      } else {
        throw Exception('Error al actualizar zona de limpieza: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Elimina una zona de limpieza
  static Future<void> deleteCleaningArea(String areaId) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}$_baseEndpoint/$areaId';
      final response = await HttpInterceptorService.delete(url);

      if (response.statusCode != 204) {
        throw Exception('Error al eliminar zona de limpieza: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
