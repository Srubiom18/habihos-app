/// Interfaces para la feature de notificaciones
/// 
/// Define los contratos de datos y servicios utilizados
/// en la funcionalidad de notificaciones.

import '../models/notifications_models.dart';

/// Interface para el servicio de notificaciones
abstract class INotificationsService {
  /// Obtiene todas las notificaciones del usuario
  Future<List<NotificationEntity>> getNotifications();

  /// Marca una notificación como leída
  Future<void> markAsRead(String notificationId);

  /// Marca todas las notificaciones como leídas
  Future<void> markAllAsRead();

  /// Elimina una notificación
  Future<void> deleteNotification(String notificationId);

  /// Elimina todas las notificaciones
  Future<void> deleteAllNotifications();
}

/// Interface para el servicio de API de notificaciones
abstract class INotificationsApi {
  /// Obtiene notificaciones desde la API
  Future<List<NotificationDto>> fetchNotifications(String token);

  /// Marca notificación como leída en la API
  Future<void> markNotificationAsRead(String token, String notificationId);

  /// Marca todas las notificaciones como leídas en la API
  Future<void> markAllNotificationsAsRead(String token);

  /// Elimina notificación en la API
  Future<void> deleteNotification(String token, String notificationId);

  /// Elimina todas las notificaciones en la API
  Future<void> deleteAllNotifications(String token);
}

/// Entidad de notificación (dominio)
class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.metadata,
  });

  /// Crea una copia de la notificación con nuevos valores
  NotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Verifica si la notificación es nueva (no leída)
  bool get isNew => !isRead;

  /// Verifica si la notificación es de tipo importante
  bool get isImportant => type == 'important' || type == 'urgent';

  /// Obtiene el tiempo transcurrido desde la creación
  Duration get timeSinceCreated => DateTime.now().difference(createdAt);

  /// Obtiene el tiempo transcurrido desde que fue leída
  Duration? get timeSinceRead => readAt != null ? DateTime.now().difference(readAt!) : null;
}

/// Estados posibles de la feature de notificaciones
enum NotificationsState {
  /// Estado inicial
  idle,
  /// Cargando notificaciones
  loading,
  /// Notificaciones cargadas exitosamente
  loaded,
  /// Error al cargar notificaciones
  error,
  /// Actualizando notificaciones
  updating,
}

/// Resultado de operaciones de notificaciones
class NotificationResult {
  final bool success;
  final String? error;
  final List<NotificationEntity>? notifications;

  const NotificationResult._({
    required this.success,
    this.error,
    this.notifications,
  });

  /// Crea un resultado exitoso
  factory NotificationResult.success(List<NotificationEntity> notifications) {
    return NotificationResult._(
      success: true,
      notifications: notifications,
    );
  }

  /// Crea un resultado de error
  factory NotificationResult.error(String error) {
    return NotificationResult._(
      success: false,
      error: error,
    );
  }

  /// Crea un resultado exitoso sin datos
  factory NotificationResult.successEmpty() {
    return const NotificationResult._(
      success: true,
      notifications: [],
    );
  }
}

/// Tipos de notificaciones disponibles
enum NotificationType {
  /// Notificación general
  general,
  /// Notificación importante
  important,
  /// Notificación urgente
  urgent,
  /// Notificación de sistema
  system,
  /// Notificación de limpieza
  cleaning,
  /// Notificación de chat
  chat,
}

/// Extensión para NotificationType
extension NotificationTypeExtension on NotificationType {
  /// Obtiene el string del tipo
  String get value {
    switch (this) {
      case NotificationType.general:
        return 'general';
      case NotificationType.important:
        return 'important';
      case NotificationType.urgent:
        return 'urgent';
      case NotificationType.system:
        return 'system';
      case NotificationType.cleaning:
        return 'cleaning';
      case NotificationType.chat:
        return 'chat';
    }
  }

  /// Obtiene el icono del tipo
  String get icon {
    switch (this) {
      case NotificationType.general:
        return 'info';
      case NotificationType.important:
        return 'warning';
      case NotificationType.urgent:
        return 'error';
      case NotificationType.system:
        return 'settings';
      case NotificationType.cleaning:
        return 'cleaning_services';
      case NotificationType.chat:
        return 'chat';
    }
  }

  /// Obtiene el color del tipo
  String get color {
    switch (this) {
      case NotificationType.general:
        return '#2196F3'; // Azul
      case NotificationType.important:
        return '#FF9800'; // Naranja
      case NotificationType.urgent:
        return '#F44336'; // Rojo
      case NotificationType.system:
        return '#9C27B0'; // Púrpura
      case NotificationType.cleaning:
        return '#4CAF50'; // Verde
      case NotificationType.chat:
        return '#00BCD4'; // Cian
    }
  }
}
