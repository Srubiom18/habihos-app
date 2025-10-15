import 'package:flutter/material.dart';

/// Tipos de notificación disponibles
enum NotificationType {
  urgent,
  roommate,
  reminder,
  system,
  maintenance,
  payment,
  cleaning,
}

/// Estados de prioridad de notificaciones
enum NotificationPriority {
  low(1, 'Baja'),
  medium(2, 'Media'),
  high(3, 'Alta'),
  critical(4, 'Crítica');

  const NotificationPriority(this.value, this.label);
  final int value;
  final String label;

  /// Compara dos prioridades (para ordenamiento)
  int compareTo(NotificationPriority other) {
    return value.compareTo(other.value);
  }
}

/// Interface que define la estructura de una notificación
abstract class Notification {
  /// ID único de la notificación
  String get id;
  
  /// Tipo de notificación
  NotificationType get type;
  
  /// Prioridad de la notificación
  NotificationPriority get priority;
  
  /// Título de la notificación
  String get title;
  
  /// Mensaje de la notificación
  String get message;
  
  /// Timestamp de creación (ISO 8601)
  DateTime get createdAt;
  
  /// Timestamp de expiración (opcional)
  DateTime? get expiresAt;
  
  /// ID del usuario que creó la notificación
  String? get createdBy;
  
  /// ID del usuario destinatario (null = todos)
  String? get targetUserId;
  
  /// Si la notificación ha sido leída
  bool get isRead;
  
  /// Datos adicionales en formato JSON
  Map<String, dynamic>? get metadata;
  
  /// Color personalizado (opcional, si no se proporciona se usa el del tipo)
  String? get customColor;
  
  /// Icono personalizado (opcional, si no se proporciona se usa el del tipo)
  String? get customIcon;
}

/// Implementación concreta de Notification
class NotificationImpl implements Notification {
  @override
  final String id;
  
  @override
  final NotificationType type;
  
  @override
  final NotificationPriority priority;
  
  @override
  final String title;
  
  @override
  final String message;
  
  @override
  final DateTime createdAt;
  
  @override
  final DateTime? expiresAt;
  
  @override
  final String? createdBy;
  
  @override
  final String? targetUserId;
  
  @override
  final bool isRead;
  
  @override
  final Map<String, dynamic>? metadata;
  
  @override
  final String? customColor;
  
  @override
  final String? customIcon;

  const NotificationImpl({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    required this.createdAt,
    this.expiresAt,
    this.createdBy,
    this.targetUserId,
    this.isRead = false,
    this.metadata,
    this.customColor,
    this.customIcon,
  });

  /// Factory constructor para crear Notification desde Map (respuesta de API)
  factory NotificationImpl.fromMap(Map<String, dynamic> map) {
    return NotificationImpl(
      id: map['id'] as String,
      type: _parseNotificationType(map['type'] as String),
      priority: _parseNotificationPriority(map['priority'] as String),
      title: map['title'] as String,
      message: map['message'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      expiresAt: map['expires_at'] != null 
          ? DateTime.parse(map['expires_at'] as String) 
          : null,
      createdBy: map['created_by'] as String?,
      targetUserId: map['target_user_id'] as String?,
      isRead: map['is_read'] as bool? ?? false,
      metadata: map['metadata'] as Map<String, dynamic>?,
      customColor: map['custom_color'] as String?,
      customIcon: map['custom_icon'] as String?,
    );
  }

  /// Convierte Notification a Map (para enviar a API)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'priority': priority.name,
      'title': title,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'created_by': createdBy,
      'target_user_id': targetUserId,
      'is_read': isRead,
      'metadata': metadata,
      'custom_color': customColor,
      'custom_icon': customIcon,
    };
  }

  /// Convierte string a NotificationType
  static NotificationType _parseNotificationType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'urgent':
        return NotificationType.urgent;
      case 'roommate':
        return NotificationType.roommate;
      case 'reminder':
        return NotificationType.reminder;
      case 'system':
        return NotificationType.system;
      case 'maintenance':
        return NotificationType.maintenance;
      case 'payment':
        return NotificationType.payment;
      case 'cleaning':
        return NotificationType.cleaning;
      default:
        throw ArgumentError('Tipo de notificación no válido: $typeString');
    }
  }

  /// Convierte string a NotificationPriority
  static NotificationPriority _parseNotificationPriority(String priorityString) {
    switch (priorityString.toLowerCase()) {
      case 'low':
        return NotificationPriority.low;
      case 'medium':
        return NotificationPriority.medium;
      case 'high':
        return NotificationPriority.high;
      case 'critical':
        return NotificationPriority.critical;
      default:
        throw ArgumentError('Prioridad de notificación no válida: $priorityString');
    }
  }

  /// Verifica si la notificación es urgente
  bool get isUrgent => priority == NotificationPriority.critical || priority == NotificationPriority.high;

  /// Verifica si la notificación es de compañero de piso
  bool get isFromRoommate => type == NotificationType.roommate;

  /// Verifica si la notificación es un recordatorio
  bool get isReminder => type == NotificationType.reminder;

  /// Verifica si la notificación ha expirado
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Obtiene el tiempo relativo desde la creación
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Ahora';
    }
  }

  /// Obtiene el color de la notificación (personalizado o por tipo)
  Color get displayColor {
    if (customColor != null) {
      return Color(int.parse(customColor!.replaceFirst('#', '0xff')));
    }
    return _getDefaultColorForType();
  }

  /// Obtiene el icono de la notificación (personalizado o por tipo)
  IconData get displayIcon {
    if (customIcon != null) {
      // Aquí podrías mapear strings a IconData
      return _getDefaultIconForType();
    }
    return _getDefaultIconForType();
  }

  /// Obtiene el color por defecto según el tipo
  Color _getDefaultColorForType() {
    switch (type) {
      case NotificationType.urgent:
        return Colors.red;
      case NotificationType.roommate:
        return Colors.purple;
      case NotificationType.reminder:
        return Colors.blue;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.maintenance:
        return Colors.orange;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.cleaning:
        return Colors.amber;
    }
  }

  /// Obtiene el icono por defecto según el tipo
  IconData _getDefaultIconForType() {
    switch (type) {
      case NotificationType.urgent:
        return Icons.warning;
      case NotificationType.roommate:
        return Icons.person;
      case NotificationType.reminder:
        return Icons.notifications;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.maintenance:
        return Icons.build;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.cleaning:
        return Icons.cleaning_services;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationImpl &&
        other.id == id &&
        other.type == type &&
        other.priority == priority &&
        other.title == title &&
        other.message == message &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        priority.hashCode ^
        title.hashCode ^
        message.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'NotificationImpl(id: $id, type: $type, priority: $priority, title: $title, message: $message, createdAt: $createdAt)';
  }
}
