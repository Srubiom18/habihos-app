/// Modelos de datos para la feature de notificaciones
/// 
/// Contiene DTOs para intercambio con la API y mappers
/// para convertir entre DTOs y entidades de dominio.

import '../interfaces/notifications_interfaces.dart';

/// DTO para notificación (intercambio con API)
class NotificationDto {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final String createdAt;
  final String? readAt;
  final Map<String, dynamic>? metadata;

  const NotificationDto({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.readAt,
    this.metadata,
  });

  /// Crea un DTO desde JSON
  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String,
      readAt: json['read_at'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convierte DTO a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt,
      'read_at': readAt,
      'metadata': metadata,
    };
  }

  /// Crea una copia del DTO con nuevos valores
  NotificationDto copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    String? createdAt,
    String? readAt,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationDto(
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
}

/// DTO para crear una nueva notificación
class CreateNotificationDto {
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic>? metadata;

  const CreateNotificationDto({
    required this.title,
    required this.body,
    required this.type,
    this.metadata,
  });

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'metadata': metadata,
    };
  }
}

/// DTO para actualizar una notificación
class UpdateNotificationDto {
  final String? title;
  final String? body;
  final String? type;
  final bool? isRead;
  final Map<String, dynamic>? metadata;

  const UpdateNotificationDto({
    this.title,
    this.body,
    this.type,
    this.isRead,
    this.metadata,
  });

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    
    if (title != null) json['title'] = title;
    if (body != null) json['body'] = body;
    if (type != null) json['type'] = type;
    if (isRead != null) json['is_read'] = isRead;
    if (metadata != null) json['metadata'] = metadata;
    
    return json;
  }
}

/// DTO para respuesta de la API de notificaciones
class NotificationsResponseDto {
  final bool success;
  final String message;
  final List<NotificationDto> notifications;
  final int totalCount;
  final int unreadCount;

  const NotificationsResponseDto({
    required this.success,
    required this.message,
    required this.notifications,
    required this.totalCount,
    required this.unreadCount,
  });

  /// Crea desde JSON
  factory NotificationsResponseDto.fromJson(Map<String, dynamic> json) {
    return NotificationsResponseDto(
      success: json['success'] as bool,
      message: json['message'] as String,
      notifications: (json['notifications'] as List)
          .map((item) => NotificationDto.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] as int,
      unreadCount: json['unread_count'] as int,
    );
  }
}

/// Mapper para convertir entre DTOs y entidades
class NotificationMapper {
  /// Convierte DTO a entidad de dominio
  static NotificationEntity toEntity(NotificationDto dto) {
    return NotificationEntity(
      id: dto.id,
      title: dto.title,
      body: dto.body,
      type: dto.type,
      isRead: dto.isRead,
      createdAt: DateTime.parse(dto.createdAt),
      readAt: dto.readAt != null ? DateTime.parse(dto.readAt!) : null,
      metadata: dto.metadata,
    );
  }

  /// Convierte entidad de dominio a DTO
  static NotificationDto toDto(NotificationEntity entity) {
    return NotificationDto(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      type: entity.type,
      isRead: entity.isRead,
      createdAt: entity.createdAt.toIso8601String(),
      readAt: entity.readAt?.toIso8601String(),
      metadata: entity.metadata,
    );
  }

  /// Convierte lista de DTOs a entidades
  static List<NotificationEntity> toEntityList(List<NotificationDto> dtos) {
    return dtos.map((dto) => toEntity(dto)).toList();
  }

  /// Convierte lista de entidades a DTOs
  static List<NotificationDto> toDtoList(List<NotificationEntity> entities) {
    return entities.map((entity) => toDto(entity)).toList();
  }
}

/// DTO para filtros de notificaciones
class NotificationFiltersDto {
  final String? type;
  final bool? isRead;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? limit;
  final int? offset;

  const NotificationFiltersDto({
    this.type,
    this.isRead,
    this.fromDate,
    this.toDate,
    this.limit,
    this.offset,
  });

  /// Convierte a query parameters
  Map<String, String> toQueryParams() {
    final Map<String, String> params = {};
    
    if (type != null) params['type'] = type!;
    if (isRead != null) params['is_read'] = isRead.toString();
    if (fromDate != null) params['from_date'] = fromDate!.toIso8601String();
    if (toDate != null) params['to_date'] = toDate!.toIso8601String();
    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();
    
    return params;
  }
}

/// DTO para estadísticas de notificaciones
class NotificationStatsDto {
  final int totalCount;
  final int unreadCount;
  final int readCount;
  final Map<String, int> countByType;

  const NotificationStatsDto({
    required this.totalCount,
    required this.unreadCount,
    required this.readCount,
    required this.countByType,
  });

  /// Crea desde JSON
  factory NotificationStatsDto.fromJson(Map<String, dynamic> json) {
    return NotificationStatsDto(
      totalCount: json['total_count'] as int,
      unreadCount: json['unread_count'] as int,
      readCount: json['read_count'] as int,
      countByType: Map<String, int>.from(json['count_by_type'] as Map),
    );
  }
}
