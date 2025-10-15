import 'package:flutter/material.dart';

/// Estados posibles de una área de limpieza
enum CleaningStatus {
  pending('Pendiente'),
  inProgress('En progreso'),
  completed('Completada'),
  overdue('Vencida'),
  skipped('Omitida');

  const CleaningStatus(this.label);
  final String label;
}

/// Interface que define la estructura de un área de limpieza
abstract class CleaningArea {
  /// ID único del área de limpieza
  String get id;
  
  /// Nombre del área de limpieza
  String get name;
  
  /// Descripción detallada del área
  String get description;
  
  /// Orden de prioridad en el calendario (1 = más alta)
  int get priority;
  
  /// Si el área está activa para limpieza
  bool get isActive;
  
  /// Tiempo estimado de limpieza en minutos
  int get estimatedMinutes;
  
  /// Dificultad de limpieza (1-5)
  int get difficulty;
  
  /// Color personalizado (opcional)
  String? get customColor;
  
  /// Icono personalizado (opcional)
  String? get customIcon;
  
  /// Instrucciones específicas de limpieza
  List<String> get instructions;
  
  /// Materiales necesarios para la limpieza
  List<String> get requiredMaterials;
  
  /// Fecha de última limpieza
  DateTime? get lastCleanedAt;
  
  /// ID del usuario asignado para esta área
  String? get assignedUserId;
  
  /// Fecha de asignación
  DateTime? get assignedAt;
  
  /// Fecha de vencimiento de la asignación
  DateTime? get dueDate;
  
  /// Estado de la limpieza
  CleaningStatus get status;
  
  /// Metadatos adicionales
  Map<String, dynamic>? get metadata;
  
  /// Color para mostrar en la UI
  Color get color;
  
  /// Icono para mostrar en la UI
  IconData get icon;
}

/// Implementación concreta de CleaningArea
class CleaningAreaImpl implements CleaningArea {
  @override
  final String id;
  
  @override
  final String name;
  
  @override
  final String description;
  
  @override
  final int priority;
  
  @override
  final bool isActive;
  
  @override
  final int estimatedMinutes;
  
  @override
  final int difficulty;
  
  @override
  final String? customColor;
  
  @override
  final String? customIcon;
  
  @override
  final List<String> instructions;
  
  @override
  final List<String> requiredMaterials;
  
  @override
  final DateTime? lastCleanedAt;
  
  @override
  final String? assignedUserId;
  
  @override
  final DateTime? assignedAt;
  
  @override
  final DateTime? dueDate;
  
  @override
  final CleaningStatus status;
  
  @override
  final Map<String, dynamic>? metadata;

  const CleaningAreaImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.priority,
    this.isActive = true,
    required this.estimatedMinutes,
    required this.difficulty,
    this.customColor,
    this.customIcon,
    this.instructions = const [],
    this.requiredMaterials = const [],
    this.lastCleanedAt,
    this.assignedUserId,
    this.assignedAt,
    this.dueDate,
    this.status = CleaningStatus.pending,
    this.metadata,
  });

  /// Factory constructor para crear CleaningArea desde Map (respuesta de API)
  factory CleaningAreaImpl.fromMap(Map<String, dynamic> map) {
    return CleaningAreaImpl(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      priority: map['priority'] as int,
      isActive: map['is_active'] as bool? ?? true,
      estimatedMinutes: map['estimated_minutes'] as int,
      difficulty: map['difficulty'] as int,
      customColor: map['custom_color'] as String?,
      customIcon: map['custom_icon'] as String?,
      instructions: List<String>.from(map['instructions'] ?? []),
      requiredMaterials: List<String>.from(map['required_materials'] ?? []),
      lastCleanedAt: map['last_cleaned_at'] != null 
          ? DateTime.parse(map['last_cleaned_at'] as String) 
          : null,
      assignedUserId: map['assigned_user_id'] as String?,
      assignedAt: map['assigned_at'] != null 
          ? DateTime.parse(map['assigned_at'] as String) 
          : null,
      dueDate: map['due_date'] != null 
          ? DateTime.parse(map['due_date'] as String) 
          : null,
      status: _parseCleaningStatus(map['status'] as String),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convierte CleaningArea a Map (para enviar a API)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'priority': priority,
      'is_active': isActive,
      'estimated_minutes': estimatedMinutes,
      'difficulty': difficulty,
      'custom_color': customColor,
      'custom_icon': customIcon,
      'instructions': instructions,
      'required_materials': requiredMaterials,
      'last_cleaned_at': lastCleanedAt?.toIso8601String(),
      'assigned_user_id': assignedUserId,
      'assigned_at': assignedAt?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'status': status.name,
      'metadata': metadata,
    };
  }

  /// Convierte string a CleaningStatus
  static CleaningStatus _parseCleaningStatus(String statusString) {
    switch (statusString.toLowerCase()) {
      case 'pending':
        return CleaningStatus.pending;
      case 'in_progress':
        return CleaningStatus.inProgress;
      case 'completed':
        return CleaningStatus.completed;
      case 'overdue':
        return CleaningStatus.overdue;
      case 'skipped':
        return CleaningStatus.skipped;
      default:
        return CleaningStatus.pending;
    }
  }

  /// Obtiene el color de display (personalizado o por defecto)
  @override
  Color get color {
    if (customColor != null) {
      return Color(int.parse(customColor!.replaceFirst('#', '0xff')));
    }
    return _getDefaultColorForPriority();
  }

  /// Obtiene el icono de display (personalizado o por defecto)
  @override
  IconData get icon {
    if (customIcon != null) {
      // Aquí podrías mapear strings a IconData
      return _getDefaultIconForName();
    }
    return _getDefaultIconForName();
  }

  /// Verifica si el área está vencida
  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) && status != CleaningStatus.completed;
  }

  /// Obtiene el tiempo restante hasta la fecha de vencimiento
  Duration? get timeUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now());
  }

  /// Obtiene el color por defecto según la prioridad
  Color _getDefaultColorForPriority() {
    switch (priority) {
      case 1:
        return Colors.red;    // Alta prioridad
      case 2:
        return Colors.orange; // Media prioridad
      case 3:
        return Colors.blue;   // Baja prioridad
      default:
        return Colors.grey;   // Sin prioridad
    }
  }

  /// Obtiene el icono por defecto según el nombre del área
  IconData _getDefaultIconForName() {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('comedor') || nameLower.contains('dining')) {
      return Icons.dining;
    } else if (nameLower.contains('cocina') || nameLower.contains('kitchen')) {
      return Icons.kitchen;
    } else if (nameLower.contains('baño') || nameLower.contains('bathroom')) {
      return Icons.bathtub;
    } else if (nameLower.contains('pasillo') || nameLower.contains('hallway')) {
      return Icons.door_front_door;
    } else if (nameLower.contains('sala') || nameLower.contains('living')) {
      return Icons.living;
    } else if (nameLower.contains('habitación') || nameLower.contains('bedroom')) {
      return Icons.bed;
    } else {
      return Icons.cleaning_services; // Icono por defecto
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CleaningAreaImpl &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.priority == priority;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        priority.hashCode;
  }

  @override
  String toString() {
    return 'CleaningAreaImpl(id: $id, name: $name, priority: $priority, status: $status)';
  }
}
