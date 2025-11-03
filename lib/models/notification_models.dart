import '../interfaces/home_screen/notification.dart' as app_notification;

/// Modelo para la respuesta de la API de notificaciones
class NotificationResponse {
  final String id;
  final String type;
  final String title;
  final String description;
  final String createdAt;
  final String? expiresAt;
  final String? targetMemberId;
  final String houseId;

  const NotificationResponse({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    this.expiresAt,
    this.targetMemberId,
    required this.houseId,
  });

  /// Factory constructor para crear desde JSON
  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: json['createdAt'] as String,
      expiresAt: json['expiresAt'] as String?,
      targetMemberId: json['targetMemberId'] as String?,
      houseId: json['houseId'] as String,
    );
  }

  /// Convierte a NotificationImpl para compatibilidad con el sistema existente
  app_notification.NotificationImpl toNotificationImpl() {
    return app_notification.NotificationImpl(
      id: id,
      type: _parseNotificationType(type),
      priority: _parseNotificationPriority(type),
      title: title,
      message: description,
      createdAt: DateTime.parse(createdAt),
      expiresAt: expiresAt != null ? DateTime.parse(expiresAt!) : null,
      targetUserId: targetMemberId,
      isRead: false, // Las notificaciones de la API no tienen estado de leído
    );
  }

  /// Convierte string de la API a NotificationType
  app_notification.NotificationType _parseNotificationType(String typeString) {
    switch (typeString.toUpperCase()) {
      case 'CLEANING_ASSIGNMENT':
        return app_notification.NotificationType.cleaning;
      case 'CLEANING_COMPLETED':
        return app_notification.NotificationType.cleaning;
      case 'CLEANING_OVERDUE':
        return app_notification.NotificationType.urgent;
      case 'CLEANING_SKIPPED':
        return app_notification.NotificationType.cleaning;
      case 'NEW_MEMBER_JOINED':
        return app_notification.NotificationType.roommate;
      case 'MEMBER_LEFT':
        return app_notification.NotificationType.roommate;
      case 'MEMBER_STATUS_CHANGED':
        return app_notification.NotificationType.roommate;
      case 'HOUSE_UPDATE':
        return app_notification.NotificationType.system;
      case 'HOUSE_ANNOUNCEMENT':
        return app_notification.NotificationType.system;
      case 'HOUSE_SETTINGS_CHANGED':
        return app_notification.NotificationType.system;
      case 'PAYMENT_REMINDER':
        return app_notification.NotificationType.payment;
      case 'PAYMENT_RECEIVED':
        return app_notification.NotificationType.payment;
      case 'PAYMENT_OVERDUE':
        return app_notification.NotificationType.payment;
      case 'SYSTEM_ANNOUNCEMENT':
        return app_notification.NotificationType.system;
      case 'SYSTEM_MAINTENANCE':
        return app_notification.NotificationType.maintenance;
      default:
        return app_notification.NotificationType.system;
    }
  }

  /// Convierte tipo de notificación a prioridad
  app_notification.NotificationPriority _parseNotificationPriority(String typeString) {
    switch (typeString.toUpperCase()) {
      case 'CLEANING_OVERDUE':
      case 'PAYMENT_OVERDUE':
        return app_notification.NotificationPriority.critical;
      case 'CLEANING_ASSIGNMENT':
      case 'PAYMENT_REMINDER':
      case 'NEW_MEMBER_JOINED':
      case 'MEMBER_LEFT':
        return app_notification.NotificationPriority.high;
      case 'CLEANING_COMPLETED':
      case 'PAYMENT_RECEIVED':
      case 'HOUSE_UPDATE':
        return app_notification.NotificationPriority.medium;
      default:
        return app_notification.NotificationPriority.low;
    }
  }
}
