import 'dart:convert';
import '../config/app_config.dart';
import '../models/shopping_list_response.dart';
import '../models/add_product_request.dart';
import 'http_interceptor_service.dart';

/// Servicio para gestionar la lista de compras compartida
class ShoppingListService {
  static const String _baseEndpoint = '/shopping-list';

  /// Obtiene todos los datos de la lista de compras
  static Future<ShoppingListResponse> getShoppingList() async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}$_baseEndpoint';
      final response = await HttpInterceptorService.get(url).timeout(
        const Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ShoppingListResponse.fromJson(json);
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
        rethrow;
      }
    }
  }

  /// Agrega un nuevo producto a la lista
  static Future<ShoppingListResponse> addProduct(String productName) async {
    try {
      final request = AddProductRequest(name: productName);
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}$_baseEndpoint/items';
      
      final response = await HttpInterceptorService.post(
        url,
        body: request.toJson(),
      ).timeout(
        const Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ShoppingListResponse.fromJson(json);
      } else if (response.statusCode == 401) {
        throw Exception('Token de autenticación inválido');
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error en los datos enviados');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Tiempo de espera agotado. Verifica tu conexión.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor. Verifica que la API esté ejecutándose.');
      } else {
        rethrow;
      }
    }
  }

  /// Marca un producto como comprado
  static Future<ShoppingListResponse> markAsPurchased(String itemId, double price) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}$_baseEndpoint/items/$itemId/purchase';
      
      final response = await HttpInterceptorService.put(
        url,
        body: {'price': price},
      ).timeout(
        const Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ShoppingListResponse.fromJson(json);
      } else if (response.statusCode == 401) {
        throw Exception('Token de autenticación inválido');
      } else if (response.statusCode == 404) {
        throw Exception('Producto no encontrado');
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error en los datos enviados');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Tiempo de espera agotado. Verifica tu conexión.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor. Verifica que la API esté ejecutándose.');
      } else {
        rethrow;
      }
    }
  }
}

