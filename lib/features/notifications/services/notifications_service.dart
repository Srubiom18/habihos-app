/// Servicio de negocio para notificaciones
/// 
/// Encapsula la lógica de negocio relacionada con notificaciones
/// y orquesta las llamadas a la API.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../interfaces/notifications_interfaces.dart';
import '../models/notifications_models.dart';
import '../../../exports.dart';

/// Implementación del servicio de notificaciones
class NotificationsService implements INotificationsService {
  final INotificationsApi _api;

  /// Lista de notificaciones en cache
  List<NotificationEntity> _notifications = [];
  
  /// Timestamp de la última actualización
  DateTime? _lastUpdated;
  
  /// Duración del cache en minutos
  static const int cacheDurationMinutes = 5;

  NotificationsService({
    required INotificationsApi api,
  }) : _api = api;

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    try {
      // Verificar si el cache está expirado
      if (_isCacheExpired || _notifications.isEmpty) {
        await _loadNotificationsFromAPI();
      }
      
      return List.unmodifiable(_notifications);
    } catch (e) {
      // En caso de error, retornar cache si existe
      return List.unmodifiable(_notifications);
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final token = await AuthService.getCurrentToken();
      if (token == null) throw Exception('No hay sesión activa');

      // Marcar como leída en la API
      await _api.markNotificationAsRead(token, notificationId);

      // Actualizar cache local
      _updateNotificationInCache(notificationId, isRead: true);
    } catch (e) {
      throw Exception('Error al marcar notificación como leída: ${e.toString()}');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final token = await AuthService.getCurrentToken();
      if (token == null) throw Exception('No hay sesión activa');

      // Marcar todas como leídas en la API
      await _api.markAllNotificationsAsRead(token);

      // Actualizar cache local
      _markAllNotificationsAsReadInCache();
    } catch (e) {
      throw Exception('Error al marcar todas las notificaciones como leídas: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      final token = await AuthService.getCurrentToken();
      if (token == null) throw Exception('No hay sesión activa');

      // Eliminar en la API
      await _api.deleteNotification(token, notificationId);

      // Actualizar cache local
      _removeNotificationFromCache(notificationId);
    } catch (e) {
      throw Exception('Error al eliminar notificación: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAllNotifications() async {
    try {
      final token = await AuthService.getCurrentToken();
      if (token == null) throw Exception('No hay sesión activa');

      // Eliminar todas en la API
      await _api.deleteAllNotifications(token);

      // Limpiar cache local
      _notifications.clear();
      _lastUpdated = DateTime.now();
    } catch (e) {
      throw Exception('Error al eliminar todas las notificaciones: ${e.toString()}');
    }
  }

  /// Carga notificaciones desde la API
  Future<void> _loadNotificationsFromAPI() async {
    try {
      final token = await AuthService.getCurrentToken();
      if (token == null) throw Exception('No hay sesión activa');

      // Obtener notificaciones desde la API
      final dtos = await _api.fetchNotifications(token);
      
      // Convertir DTOs a entidades
      _notifications = NotificationMapper.toEntityList(dtos);
      _lastUpdated = DateTime.now();
    } catch (e) {
      // En caso de error, mantener cache existente
      throw Exception('Error al cargar notificaciones: ${e.toString()}');
    }
  }

  /// Verifica si el cache está expirado
  bool get _isCacheExpired {
    if (_lastUpdated == null) return true;
    return DateTime.now().difference(_lastUpdated!).inMinutes > cacheDurationMinutes;
  }

  /// Actualiza una notificación en el cache
  void _updateNotificationInCache(String notificationId, {bool? isRead, DateTime? readAt}) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = _notifications[index];
      _notifications[index] = notification.copyWith(
        isRead: isRead ?? notification.isRead,
        readAt: readAt ?? notification.readAt,
      );
    }
  }

  /// Marca todas las notificaciones como leídas en el cache
  void _markAllNotificationsAsReadInCache() {
    _notifications = _notifications.map((notification) {
      return notification.copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
    }).toList();
  }

  /// Remueve una notificación del cache
  void _removeNotificationFromCache(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
  }

  /// Fuerza la actualización del cache
  Future<void> refreshNotifications() async {
    await _loadNotificationsFromAPI();
  }

  /// Obtiene el número de notificaciones no leídas
  int get unreadCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  /// Obtiene el número total de notificaciones
  int get totalCount {
    return _notifications.length;
  }

  /// Obtiene notificaciones por tipo
  List<NotificationEntity> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Obtiene notificaciones no leídas
  List<NotificationEntity> get unreadNotifications {
    return _notifications.where((n) => !n.isRead).toList();
  }

  /// Obtiene notificaciones leídas
  List<NotificationEntity> get readNotifications {
    return _notifications.where((n) => n.isRead).toList();
  }
}

/// Implementación del servicio de API de notificaciones
class NotificationsApiService implements INotificationsApi {
  @override
  Future<List<NotificationDto>> fetchNotifications(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${Environment.apiConfig.fullUrl}/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Duration(milliseconds: Environment.apiConfig.connectionTimeout),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final responseDto = NotificationsResponseDto.fromJson(data);
        return responseDto.notifications;
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<void> markNotificationAsRead(String token, String notificationId) async {
    try {
      final response = await http.patch(
        Uri.parse('${Environment.apiConfig.fullUrl}/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Duration(milliseconds: Environment.apiConfig.connectionTimeout),
      );

      if (response.statusCode != 200) {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(String token) async {
    try {
      final response = await http.patch(
        Uri.parse('${Environment.apiConfig.fullUrl}/notifications/read-all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Duration(milliseconds: Environment.apiConfig.connectionTimeout),
      );

      if (response.statusCode != 200) {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteNotification(String token, String notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('${Environment.apiConfig.fullUrl}/notifications/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Duration(milliseconds: Environment.apiConfig.connectionTimeout),
      );

      if (response.statusCode != 200) {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAllNotifications(String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${Environment.apiConfig.fullUrl}/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Duration(milliseconds: Environment.apiConfig.connectionTimeout),
      );

      if (response.statusCode != 200) {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
