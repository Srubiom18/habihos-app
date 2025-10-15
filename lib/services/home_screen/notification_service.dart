import '../../interfaces/home_screen/notification.dart' as app_notification;

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

  /// Duración del cache en minutos
  static const int cacheDurationMinutes = 5;

  /// Inicializa el servicio con datos de ejemplo (para desarrollo)
  void _initializeWithExampleData() {
    _notifications = [
      app_notification.NotificationImpl(
        id: '1',
        type: app_notification.NotificationType.urgent,
        priority: app_notification.NotificationPriority.critical,
        title: '¡Tiempo limitado!',
        message: 'Te quedan 2 minutos para limpiar la zona actual ⏰',
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      app_notification.NotificationImpl(
        id: '2',
        type: app_notification.NotificationType.payment,
        priority: app_notification.NotificationPriority.high,
        title: 'Factura pendiente',
        message: 'Recordatorio: La factura de la luz vence mañana 💡',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      app_notification.NotificationImpl(
        id: '3',
        type: app_notification.NotificationType.maintenance,
        priority: app_notification.NotificationPriority.high,
        title: 'Mantenimiento',
        message: 'El técnico vendrá mañana a las 10:00 AM 🔧',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      app_notification.NotificationImpl(
        id: '4',
        type: app_notification.NotificationType.roommate,
        priority: app_notification.NotificationPriority.medium,
        title: 'Mensaje de Ana',
        message: '¡Hola! ¿Podrías comprar pan cuando salgas? 🍞',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        createdBy: 'ana_user_id',
      ),
      app_notification.NotificationImpl(
        id: '5',
        type: app_notification.NotificationType.roommate,
        priority: app_notification.NotificationPriority.medium,
        title: 'Mensaje de Carlos',
        message: '¿Alguien puede recoger el paquete del buzón? 📦',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        createdBy: 'carlos_user_id',
      ),
      app_notification.NotificationImpl(
        id: '6',
        type: app_notification.NotificationType.roommate,
        priority: app_notification.NotificationPriority.medium,
        title: 'Mensaje de María',
        message: '¿Podrías bajar la basura? El contenedor está lleno 🗑️',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        createdBy: 'maria_user_id',
      ),
      app_notification.NotificationImpl(
        id: '7',
        type: app_notification.NotificationType.reminder,
        priority: app_notification.NotificationPriority.low,
        title: 'Recordatorio',
        message: 'El pago del WiFi vence en 3 días 💳',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      app_notification.NotificationImpl(
        id: '8',
        type: app_notification.NotificationType.reminder,
        priority: app_notification.NotificationPriority.low,
        title: 'Lista de compras',
        message: 'Falta leche y huevos en la nevera 🥛🥚',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      app_notification.NotificationImpl(
        id: '9',
        type: app_notification.NotificationType.cleaning,
        priority: app_notification.NotificationPriority.low,
        title: '¡Zona completada!',
        message: '¡Excelente trabajo! La zona está impecable ✨',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
    _lastUpdated = DateTime.now();
  }

  /// Obtiene todas las notificaciones (con cache)
  /// 
  /// Retorna la lista completa de notificaciones. Si no hay datos
  /// en cache, inicializa con datos de ejemplo.
  /// 
  /// Retorna lista inmutable de notificaciones
  List<app_notification.NotificationImpl> getAllNotifications() {
    if (_notifications.isEmpty) {
      _initializeWithExampleData();
    }
    return List.unmodifiable(_notifications);
  }

  /// Carga notificaciones desde la API
  /// 
  /// Simula una llamada a la API para obtener notificaciones.
  /// En caso de error, utiliza datos de ejemplo como fallback.
  /// 
  /// Retorna lista de notificaciones cargadas
  Future<List<app_notification.NotificationImpl>> loadNotificationsFromAPI() async {
    try {
      // TODO: Implementar llamada real a la API
      // final response = await _apiService.getNotifications();
      // _notifications = response.map((json) => app_notification.NotificationImpl.fromMap(json)).toList();
      
      // Por ahora, usar datos de ejemplo
      _initializeWithExampleData();
      _lastUpdated = DateTime.now();
      
      return _notifications;
    } catch (e) {
      // En caso de error, usar datos de ejemplo
      _initializeWithExampleData();
      return _notifications;
    }
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
