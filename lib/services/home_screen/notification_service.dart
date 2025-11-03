import 'dart:convert';
import '../../interfaces/home_screen/notification.dart' as app_notification;
import '../../models/notification_models.dart';
import '../../config/app_config.dart';
import '../http_interceptor_service.dart';

/// Servicio que maneja la lógica de negocio relacionada con las notificaciones
/// 
/// Proporciona funcionalidades para gestionar notificaciones del sistema,
/// incluyendo carga desde API, cache local, filtrado por tipo y prioridad.
/// Utiliza datos de ejemplo para desarrollo y simula llamadas a la API.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // UserContextService removido - no se utilizaba en este servicio

  /// Lista de notificaciones en memoria (cache local)
  List<app_notification.NotificationImpl> _notifications = [];

  /// Timestamp de la última actualización
  DateTime? _lastUpdated;

  /// Estado de carga de las notificaciones
  bool _isLoading = false;

  /// Duración del cache en minutos
  static const int cacheDurationMinutes = 5;

  /// URL base para las notificaciones
  static const String _baseEndpoint = '/notifications';

  /// Obtiene todas las notificaciones (con cache)
  /// 
  /// Retorna la lista completa de notificaciones cargadas desde la API.
  /// Si no hay datos en cache, retorna lista vacía.
  /// 
  /// Retorna lista inmutable de notificaciones
  List<app_notification.NotificationImpl> getAllNotifications() {
    return List.unmodifiable(_notifications);
  }

  /// Verifica si las notificaciones están cargando
  bool get isLoading => _isLoading;

  /// Verifica si hay notificaciones cargadas
  bool get hasNotifications => _notifications.isNotEmpty;

  /// Carga notificaciones desde la API
  /// 
  /// Obtiene las notificaciones del usuario actual desde la API.
  /// 
  /// Retorna lista de notificaciones cargadas
  Future<List<app_notification.NotificationImpl>> loadNotificationsFromAPI() async {
    _isLoading = true;
    
    try {
      // Construir la URL del endpoint (sin parámetros, el token contiene la información)
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}$_baseEndpoint';
      print('🔔 Cargando notificaciones desde: $url');
      
      // Realizar la petición HTTP (HttpInterceptorService maneja automáticamente el token)
      final response = await HttpInterceptorService.get(url).timeout(
        const Duration(milliseconds: AppConfig.connectionTimeout),
      );
      
      print('🔔 Respuesta del servidor: ${response.statusCode}');
      print('🔔 Body de la respuesta: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print('🔔 JSON parseado: $jsonList');
        
        _notifications = jsonList
            .map((json) {
              print('🔔 Procesando notificación: $json');
              return NotificationResponse.fromJson(json as Map<String, dynamic>);
            })
            .map((notification) {
              print('🔔 Convirtiendo a NotificationImpl: ${notification.id}');
              return notification.toNotificationImpl();
            })
            .toList();
        _lastUpdated = DateTime.now();
        print('🔔 Notificaciones cargadas exitosamente: ${_notifications.length}');
        return _notifications;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Inicia sesión nuevamente.');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('🔔 Error al cargar notificaciones: $e');
      // En caso de error, limpiar notificaciones y re-lanzar el error
      _notifications.clear();
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  /// Fuerza la recarga de notificaciones desde la API
  /// 
  /// Limpia el cache y carga las notificaciones más recientes.
  /// Útil para refrescar los datos cuando se sabe que han cambiado.
  /// 
  /// Retorna lista de notificaciones cargadas
  Future<List<app_notification.NotificationImpl>> forceReload() async {
    // Limpiar cache
    _notifications.clear();
    _lastUpdated = null;
    
    // Cargar desde la API
    return await loadNotificationsFromAPI();
  }


  /// Verifica si el cache está expirado
  /// 
  /// Comprueba si han pasado más de [cacheDurationMinutes] desde
  /// la última actualización de los datos.
  bool get isCacheExpired {
    if (_lastUpdated == null) return true;
    return DateTime.now().difference(_lastUpdated!).inMinutes > cacheDurationMinutes;
  }

  /// Fuerza la actualización de notificaciones
  /// 
  /// Recarga los datos desde la API, ignorando el cache.
  Future<void> refreshNotifications() async {
    await loadNotificationsFromAPI();
  }

  /// Obtiene notificaciones por tipo
  /// 
  /// [type] - Tipo de notificación a filtrar
  /// Retorna lista de notificaciones del tipo especificado
  List<app_notification.NotificationImpl> getNotificationsByType(app_notification.NotificationType type) {
    return _notifications.where((notification) => notification.type == type).toList();
  }

  /// Obtiene notificaciones urgentes (críticas y altas)
  /// 
  /// Retorna lista de notificaciones con prioridad crítica o alta
  List<app_notification.NotificationImpl> getUrgentNotifications() {
    return _notifications.where((notification) => 
        notification.priority == app_notification.NotificationPriority.critical ||
        notification.priority == app_notification.NotificationPriority.high
    ).toList();
  }

  /// Obtiene notificaciones de compañeros de piso
  /// 
  /// Retorna lista de notificaciones del tipo 'roommate'
  List<app_notification.NotificationImpl> getRoommateNotifications() {
    return getNotificationsByType(app_notification.NotificationType.roommate);
  }

  /// Obtiene el número total de notificaciones
  int getTotalNotifications() {
    return _notifications.length;
  }

  /// Obtiene el número de notificaciones urgentes
  int getUrgentNotificationCount() {
    return getUrgentNotifications().length;
  }

  /// Obtiene notificaciones no leídas
  /// 
  /// Retorna lista de notificaciones que no han sido marcadas como leídas
  List<app_notification.NotificationImpl> getUnreadNotifications() {
    return _notifications.where((notification) => !notification.isRead).toList();
  }

  /// Elimina una notificación
  /// 
  /// [notificationId] - ID de la notificación a eliminar
  Future<void> deleteNotification(String notificationId) async {
    // TODO: Implementar llamada a API para eliminar
    // await _apiService.deleteNotification(notificationId);
    
    // Actualizar localmente
    _notifications.removeWhere((n) => n.id == notificationId);
  }

  /// Obtiene un resumen de notificaciones
  /// 
  /// Retorna mapa con estadísticas de notificaciones por tipo
  Map<String, int> getNotificationSummary() {
    return {
      'total': getTotalNotifications(),
      'urgent': getUrgentNotificationCount(),
      'roommate': getNotificationsByType(app_notification.NotificationType.roommate).length,
      'reminder': getNotificationsByType(app_notification.NotificationType.reminder).length,
    };
  }
}
