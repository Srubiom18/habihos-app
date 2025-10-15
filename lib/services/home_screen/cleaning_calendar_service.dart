import 'dart:convert';
import '../../models/api_models.dart';
import '../../interfaces/home_screen/cleaning_area.dart';
import '../../config/app_config.dart';
import '../http_interceptor_service.dart';

/// Servicio para consumir el endpoint del calendario de limpieza
/// 
/// Maneja la comunicación con la API para obtener el calendario
/// de limpieza del usuario y procesar las respuestas.
class CleaningCalendarService {
  static final CleaningCalendarService _instance = CleaningCalendarService._internal();
  factory CleaningCalendarService() => _instance;
  CleaningCalendarService._internal();
  
  // URL base de la API (usando la configuración de la app)
  static String get _baseUrl => '${AppConfig.baseUrl}${AppConfig.apiVersion}';
  
  /// Obtiene el calendario de limpieza del usuario actual
  /// 
  /// Retorna la respuesta del calendario con las zonas configuradas
  /// o un mensaje indicando que no hay zonas configuradas.
  Future<CleaningCalendarResponse> getCleaningCalendar() async {
    try {
      // Realizar la petición HTTP usando el interceptor (maneja automáticamente el token)
      final response = await HttpInterceptorService.get(
        '$_baseUrl/cleaning-schedule/calendar',
      ).timeout(
        const Duration(milliseconds: AppConfig.connectionTimeout),
      );

      // Verificar el código de respuesta
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return CleaningCalendarResponse.fromMap(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Inicia sesión nuevamente.');
      } else {
        throw Exception('Error al obtener el calendario: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return CleaningCalendarResponse(
          isActive: false,
          hasConfiguredZones: false,
          zoneRotation: [],
          message: 'Tiempo de espera agotado. Verifica tu conexión.',
        );
      } else if (e.toString().contains('SocketException')) {
        return CleaningCalendarResponse(
          isActive: false,
          hasConfiguredZones: false,
          zoneRotation: [],
          message: 'No se puede conectar al servidor. Verifica que la API esté ejecutándose.',
        );
      } else {
        // En caso de error, retornar una respuesta con mensaje de error
        return CleaningCalendarResponse(
          isActive: false,
          hasConfiguredZones: false,
          zoneRotation: [],
          message: 'Error al cargar el calendario: ${e.toString()}',
        );
      }
    }
  }

  /// Convierte las zonas de rotación a CleaningArea para compatibilidad
  /// 
  /// [zoneRotation] - Lista de zonas de rotación de la API
  /// Retorna lista de CleaningArea compatible con el sistema existente
  List<CleaningAreaFromAPI> convertZonesToCleaningAreas(
    List<CleaningZoneRotationResponse> zoneRotation
  ) {
    return zoneRotation.map((zone) => CleaningAreaFromAPI(
      id: zone.cleaningAreaId,
      name: zone.cleaningAreaName,
      description: zone.cleaningAreaDescription,
      color: zone.cleaningAreaColor,
      isCurrent: zone.isCurrent,
      isOverdue: zone.isOverdue,
      positionInRotation: zone.positionInRotation,
      status: zone.status,
      assignmentId: zone.assignmentId,
      periodStart: zone.periodStart,
      periodEnd: zone.periodEnd,
      completedAt: zone.completedAt,
      notes: zone.notes,
    )).toList();
  }
}

/// Modelo temporal para representar áreas de limpieza desde la API
/// 
/// Esta clase actúa como puente entre la respuesta de la API
/// y el sistema existente de CleaningArea.
class CleaningAreaFromAPI {
  final String id;
  final String name;
  final String description;
  final String color;
  final bool isCurrent;
  final bool isOverdue;
  final int positionInRotation;
  final String? status;
  final String? assignmentId;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final DateTime? completedAt;
  final String? notes;

  const CleaningAreaFromAPI({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.isCurrent,
    required this.isOverdue,
    required this.positionInRotation,
    this.status,
    this.assignmentId,
    this.periodStart,
    this.periodEnd,
    this.completedAt,
    this.notes,
  });

  /// Convierte a CleaningAreaImpl para compatibilidad
  CleaningAreaImpl toCleaningAreaImpl() {
    return CleaningAreaImpl(
      id: id,
      name: name,
      description: description,
      priority: positionInRotation,
      estimatedMinutes: 30, // Valor por defecto
      difficulty: 2, // Valor por defecto
      customColor: color,
      status: _parseStatus(status),
      lastCleanedAt: completedAt,
      assignedAt: periodStart,
      dueDate: periodEnd,
      metadata: {
        'isCurrent': isCurrent,
        'isOverdue': isOverdue,
        'positionInRotation': positionInRotation,
        'assignmentId': assignmentId,
        'notes': notes,
      },
    );
  }

  /// Convierte el status string a CleaningStatus enum
  CleaningStatus _parseStatus(String? statusString) {
    if (statusString == null) return CleaningStatus.pending;
    
    switch (statusString.toLowerCase()) {
      case 'completed':
        return CleaningStatus.completed;
      case 'in_progress':
        return CleaningStatus.inProgress;
      case 'overdue':
        return CleaningStatus.overdue;
      case 'skipped':
        return CleaningStatus.skipped;
      default:
        return CleaningStatus.pending;
    }
  }
}
