/// Modelos para las respuestas de la API
/// 
/// Estos modelos representan la estructura de datos que viene del backend
/// y se convierten a las interfaces de la aplicación.

/// Respuesta base de la API
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory ApiResponse.fromMap(Map<String, dynamic> map, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      success: map['success'] as bool,
      message: map['message'] as String?,
      data: map['data'] != null ? fromJsonT(map['data']) : null,
      errors: map['errors'] as Map<String, dynamic>?,
      statusCode: map['status_code'] as int?,
    );
  }
}

/// Respuesta paginada de la API
class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedResponse.fromMap(
    Map<String, dynamic> map, 
    T Function(dynamic) fromJsonT
  ) {
    return PaginatedResponse<T>(
      items: (map['items'] as List).map((item) => fromJsonT(item)).toList(),
      currentPage: map['current_page'] as int,
      totalPages: map['total_pages'] as int,
      totalItems: map['total_items'] as int,
      itemsPerPage: map['items_per_page'] as int,
      hasNextPage: map['has_next_page'] as bool,
      hasPreviousPage: map['has_previous_page'] as bool,
    );
  }
}

/// Modelo de usuario/participante
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? phone;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final bool isActive;
  final Map<String, dynamic>? preferences;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.phone,
    required this.createdAt,
    this.lastActiveAt,
    this.isActive = true,
    this.preferences,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      avatar: map['avatar'] as String?,
      phone: map['phone'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastActiveAt: map['last_active_at'] != null 
          ? DateTime.parse(map['last_active_at'] as String) 
          : null,
      isActive: map['is_active'] as bool? ?? true,
      preferences: map['preferences'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'last_active_at': lastActiveAt?.toIso8601String(),
      'is_active': isActive,
      'preferences': preferences,
    };
  }
}

/// Modelo de calendario de limpieza
class CleaningCalendarModel {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final List<CleaningScheduleModel> schedules;
  final String status; // 'active', 'completed', 'paused'
  final Map<String, dynamic>? metadata;

  const CleaningCalendarModel({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.schedules,
    required this.status,
    this.metadata,
  });

  factory CleaningCalendarModel.fromMap(Map<String, dynamic> map) {
    return CleaningCalendarModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      schedules: (map['schedules'] as List)
          .map((item) => CleaningScheduleModel.fromMap(item))
          .toList(),
      status: map['status'] as String,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Modelo de horario de limpieza
class CleaningScheduleModel {
  final String id;
  final String areaId;
  final String userId;
  final DateTime scheduledDate;
  final DateTime? completedAt;
  final String status; // 'pending', 'in_progress', 'completed', 'overdue', 'skipped'
  final int estimatedMinutes;
  final int? actualMinutes;
  final String? notes;
  final Map<String, dynamic>? metadata;

  const CleaningScheduleModel({
    required this.id,
    required this.areaId,
    required this.userId,
    required this.scheduledDate,
    this.completedAt,
    required this.status,
    required this.estimatedMinutes,
    this.actualMinutes,
    this.notes,
    this.metadata,
  });

  factory CleaningScheduleModel.fromMap(Map<String, dynamic> map) {
    return CleaningScheduleModel(
      id: map['id'] as String,
      areaId: map['area_id'] as String,
      userId: map['user_id'] as String,
      scheduledDate: DateTime.parse(map['scheduled_date'] as String),
      completedAt: map['completed_at'] != null 
          ? DateTime.parse(map['completed_at'] as String) 
          : null,
      status: map['status'] as String,
      estimatedMinutes: map['estimated_minutes'] as int,
      actualMinutes: map['actual_minutes'] as int?,
      notes: map['notes'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Modelo de configuración de la casa
class HouseConfigModel {
  final String id;
  final String name;
  final String address;
  final List<String> memberIds;
  final Map<String, dynamic> cleaningSettings;
  final Map<String, dynamic> notificationSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HouseConfigModel({
    required this.id,
    required this.name,
    required this.address,
    required this.memberIds,
    required this.cleaningSettings,
    required this.notificationSettings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HouseConfigModel.fromMap(Map<String, dynamic> map) {
    return HouseConfigModel(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      memberIds: List<String>.from(map['member_ids']),
      cleaningSettings: map['cleaning_settings'] as Map<String, dynamic>,
      notificationSettings: map['notification_settings'] as Map<String, dynamic>,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

/// Modelo para crear una nueva casa
class CreateHouseRequest {
  final String name;
  final int maxParticipants;
  final List<CleaningAreaRequest> cleaningAreas;

  const CreateHouseRequest({
    required this.name,
    required this.maxParticipants,
    required this.cleaningAreas,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'maxParticipants': maxParticipants,
      'cleaningAreas': cleaningAreas.map((area) => area.toMap()).toList(),
    };
  }
}

/// Modelo para área de limpieza en la creación de casa
class CleaningAreaRequest {
  final String name;
  final String? description;

  const CleaningAreaRequest({
    required this.name,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
    };
  }
}

/// Modelo de respuesta al crear una casa
class CreateHouseResponse {
  final String id;
  final String name;
  final String ownerId;
  final bool isActive;
  final int maxParticipants;
  final int pricePerParticipant;
  final int totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CreateHouseResponse({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.isActive,
    required this.maxParticipants,
    required this.pricePerParticipant,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CreateHouseResponse.fromMap(Map<String, dynamic> map) {
    return CreateHouseResponse(
      id: map['id'] as String,
      name: map['name'] as String,
      ownerId: map['ownerId'] as String,
      isActive: map['isActive'] as bool,
      maxParticipants: map['maxParticipants'] as int,
      pricePerParticipant: map['pricePerParticipant'] as int,
      totalPrice: map['totalPrice'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}

// ========== MODELOS PARA CALENDARIO DE LIMPIEZA ==========

/// Modelo de respuesta del calendario de limpieza
class CleaningCalendarResponse {
  final String? rotationId;
  final String? frequency;
  final int? rotationDays;
  final DateTime? startDate;
  final DateTime? nextRotationDate;
  final int? timeUntilNextRotationMs;
  final bool isActive;
  final bool hasConfiguredZones;
  final List<CleaningZoneRotationResponse> zoneRotation;
  final String message;

  const CleaningCalendarResponse({
    this.rotationId,
    this.frequency,
    this.rotationDays,
    this.startDate,
    this.nextRotationDate,
    this.timeUntilNextRotationMs,
    required this.isActive,
    required this.hasConfiguredZones,
    required this.zoneRotation,
    required this.message,
  });

  factory CleaningCalendarResponse.fromMap(Map<String, dynamic> map) {
    return CleaningCalendarResponse(
      rotationId: map['rotationId'] as String?,
      frequency: map['frequency'] as String?,
      rotationDays: map['rotationDays'] as int?,
      startDate: map['startDate'] != null 
          ? DateTime.parse(map['startDate'] as String) 
          : null,
      nextRotationDate: map['nextRotationDate'] != null 
          ? DateTime.parse(map['nextRotationDate'] as String) 
          : null,
      timeUntilNextRotationMs: map['timeUntilNextRotationMs'] as int?,
      isActive: map['isActive'] as bool? ?? false,
      hasConfiguredZones: map['hasConfiguredZones'] as bool? ?? false,
      zoneRotation: (map['zoneRotation'] as List? ?? [])
          .map((item) => CleaningZoneRotationResponse.fromMap(item))
          .toList(),
      message: map['message'] as String? ?? '',
    );
  }
}

/// Modelo de zona de rotación en el calendario
class CleaningZoneRotationResponse {
  final String? assignmentId;
  final String cleaningAreaId;
  final String cleaningAreaName;
  final String cleaningAreaDescription;
  final String cleaningAreaColor;
  final String? status;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final DateTime? completedAt;
  final String? notes;
  final bool isCurrent;
  final bool isOverdue;
  final int positionInRotation;
  final List<AssignedUserInfo> assignedUsers; // Lista de usuarios asignados

  const CleaningZoneRotationResponse({
    this.assignmentId,
    required this.cleaningAreaId,
    required this.cleaningAreaName,
    required this.cleaningAreaDescription,
    required this.cleaningAreaColor,
    this.status,
    this.periodStart,
    this.periodEnd,
    this.completedAt,
    this.notes,
    required this.isCurrent,
    required this.isOverdue,
    required this.positionInRotation,
    required this.assignedUsers,
  });

  factory CleaningZoneRotationResponse.fromMap(Map<String, dynamic> map) {
    return CleaningZoneRotationResponse(
      assignmentId: map['assignmentId'] as String?,
      cleaningAreaId: map['cleaningAreaId'] as String,
      cleaningAreaName: map['cleaningAreaName'] as String,
      cleaningAreaDescription: map['cleaningAreaDescription'] as String,
      cleaningAreaColor: map['cleaningAreaColor'] as String,
      status: map['status'] as String?,
      periodStart: map['periodStart'] != null 
          ? DateTime.parse(map['periodStart'] as String) 
          : null,
      periodEnd: map['periodEnd'] != null 
          ? DateTime.parse(map['periodEnd'] as String) 
          : null,
      completedAt: map['completedAt'] != null 
          ? DateTime.parse(map['completedAt'] as String) 
          : null,
      notes: map['notes'] as String?,
      isCurrent: map['isCurrent'] as bool? ?? false,
      isOverdue: map['isOverdue'] as bool? ?? false,
      positionInRotation: map['positionInRotation'] as int? ?? 0,
      assignedUsers: map['assignedUsers'] != null 
          ? (map['assignedUsers'] as List)
              .map((user) => AssignedUserInfo.fromMap(user as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

/// Modelo de respuesta para una asignación fija de zona de limpieza
class FixedAssignmentResponse {
  final String assignmentId;
  final String memberId;
  final String memberName;
  final String memberEmail;
  final String cleaningAreaId;
  final String cleaningAreaName;
  final String cleaningAreaDescription;
  final String cleaningAreaColor;
  final DateTime assignedAt;
  final String assignedBy;

  const FixedAssignmentResponse({
    required this.assignmentId,
    required this.memberId,
    required this.memberName,
    required this.memberEmail,
    required this.cleaningAreaId,
    required this.cleaningAreaName,
    required this.cleaningAreaDescription,
    required this.cleaningAreaColor,
    required this.assignedAt,
    required this.assignedBy,
  });

  factory FixedAssignmentResponse.fromMap(Map<String, dynamic> map) {
    return FixedAssignmentResponse(
      assignmentId: map['assignmentId'] as String,
      memberId: map['memberId'] as String,
      memberName: map['memberName'] as String,
      memberEmail: map['memberEmail'] as String,
      cleaningAreaId: map['cleaningAreaId'] as String,
      cleaningAreaName: map['cleaningAreaName'] as String,
      cleaningAreaDescription: map['cleaningAreaDescription'] as String,
      cleaningAreaColor: map['cleaningAreaColor'] as String,
      assignedAt: DateTime.parse(map['assignedAt'] as String),
      assignedBy: map['assignedBy'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assignmentId': assignmentId,
      'memberId': memberId,
      'memberName': memberName,
      'memberEmail': memberEmail,
      'cleaningAreaId': cleaningAreaId,
      'cleaningAreaName': cleaningAreaName,
      'cleaningAreaDescription': cleaningAreaDescription,
      'cleaningAreaColor': cleaningAreaColor,
      'assignedAt': assignedAt.toIso8601String(),
      'assignedBy': assignedBy,
    };
  }
}

/// Modelo de información de usuario asignado a una zona
class AssignedUserInfo {
  final String memberId;
  final String memberName;
  final String memberEmail;
  final String userInitials;
  final bool hasRegisteredAccount;
  final String? assignmentId; // ID de la asignación para poder desasignar

  const AssignedUserInfo({
    required this.memberId,
    required this.memberName,
    required this.memberEmail,
    required this.userInitials,
    required this.hasRegisteredAccount,
    this.assignmentId,
  });

  factory AssignedUserInfo.fromMap(Map<String, dynamic> map) {
    return AssignedUserInfo(
      memberId: map['memberId'] as String,
      memberName: map['memberName'] as String,
      memberEmail: map['memberEmail'] as String,
      userInitials: map['userInitials'] as String,
      hasRegisteredAccount: map['hasRegisteredAccount'] as bool? ?? false,
      assignmentId: map['assignmentId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'memberEmail': memberEmail,
      'userInitials': userInitials,
      'hasRegisteredAccount': hasRegisteredAccount,
      'assignmentId': assignmentId,
    };
  }
}

// ========== MODELOS PARA ZONAS DE LIMPIEZA ==========

/// Modelo de respuesta para una zona de limpieza
class CleaningAreaResponse {
  final String id;
  final String name;
  final String description;
  final String color;
  final String houseId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CleaningAreaResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.houseId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CleaningAreaResponse.fromMap(Map<String, dynamic> map) {
    return CleaningAreaResponse(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      color: map['color'] as String? ?? '#3B82F6',
      houseId: map['houseId'] as String? ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'houseId': houseId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Modelo de request para crear/actualizar una zona de limpieza
class CreateCleaningAreaRequest {
  final String name;
  final String description;
  final String color;

  const CreateCleaningAreaRequest({
    required this.name,
    required this.description,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'color': color,
    };
  }
}


/// Modelo de request para asignar zona de limpieza
class AssignCleaningAreaRequest {
  final String memberId;
  final String cleaningAreaId;

  const AssignCleaningAreaRequest({
    required this.memberId,
    required this.cleaningAreaId,
  });

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'cleaningAreaId': cleaningAreaId,
    };
  }
}

/// Modelo de información de miembro de la casa
class HouseMemberInfoResponse {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? phone;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final bool isActive;
  final String memberType;

  const HouseMemberInfoResponse({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.phone,
    required this.createdAt,
    this.lastActiveAt,
    this.isActive = true,
    required this.memberType,
  });

  factory HouseMemberInfoResponse.fromMap(Map<String, dynamic> map) {
    // Debug: imprimir datos del mapa
    print('=== DEBUG: Mapeando miembro ===');
    print('Mapa completo: $map');
    print('ID: ${map['id']}');
    print('Name: ${map['name']}');
    print('Email: ${map['email']}');
    
    return HouseMemberInfoResponse(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      avatar: map['avatar'] as String?,
      phone: map['phone'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastActiveAt: map['lastActiveAt'] != null 
          ? DateTime.parse(map['lastActiveAt'] as String) 
          : null,
      isActive: map['isActive'] as bool? ?? true,
      memberType: map['memberType'] as String? ?? 'MEMBER',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'isActive': isActive,
      'memberType': memberType,
    };
  }
}