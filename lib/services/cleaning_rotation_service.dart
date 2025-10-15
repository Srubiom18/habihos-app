import 'dart:convert';
import '../config/app_config.dart';
import 'http_interceptor_service.dart';

/// Servicio para gestionar la configuración de rotación del calendario de limpieza
/// 
/// Este servicio maneja todos los endpoints relacionados con la rotación:
/// - Configurar rotación (crear/actualizar)
/// - Obtener configuración actual
/// - Activar/desactivar rotación
/// - Procesar rotaciones pendientes
class CleaningRotationService {
  static const String _baseEndpoint = '/cleaning-rotation';

  /// Obtiene la configuración actual de rotación para la casa
  /// 
  /// Endpoint: GET /api/v1/cleaning-rotation/config
  /// Respuesta: RotationConfigResponse con la configuración actual
  /// Si no existe configuración, retorna un objeto con valores null
  static Future<RotationConfigResponse> getRotationConfig() async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}$_baseEndpoint/config';
      final response = await HttpInterceptorService.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return RotationConfigResponse.fromMap(json);
      } else {
        throw Exception('Error al obtener configuración de rotación: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Configura o actualiza la configuración de rotación
  /// 
  /// Endpoint: POST /api/v1/cleaning-rotation/configure
  /// Body: CreateRotationRequest con frecuencia, días personalizados y fecha de inicio
  /// Respuesta: RotationConfigResponse con la nueva configuración
  static Future<RotationConfigResponse> configureRotation(CreateRotationRequest request) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}$_baseEndpoint/configure';
      
      final response = await HttpInterceptorService.post(
        url,
        body: request.toMap(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return RotationConfigResponse.fromMap(json);
      } else {
        throw Exception('Error al configurar rotación: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Activa o desactiva la rotación de limpieza
  /// 
  /// Endpoint: PUT /api/v1/cleaning-rotation/toggle?isActive=true/false
  /// 
  /// Comportamiento:
  /// - Al activar: Configura rotación semanal por defecto y genera horarios
  /// - Al desactivar: Limpia todos los datos de rotación
  /// 
  /// Respuesta: RotationConfigResponse con el nuevo estado
  static Future<RotationConfigResponse> toggleRotation(bool isActive) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}$_baseEndpoint/toggle?isActive=$isActive';
      final response = await HttpInterceptorService.put(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return RotationConfigResponse.fromMap(json);
      } else {
        throw Exception('Error al ${isActive ? 'activar' : 'desactivar'} rotación: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Procesa las rotaciones pendientes en el sistema
  /// 
  /// Endpoint: POST /api/v1/cleaning-rotation/process-pending
  /// 
  /// Este endpoint busca todas las rotaciones que necesitan actualización
  /// y genera nuevos horarios con asignaciones distribuidas
  /// 
  /// Respuesta: String con mensaje de confirmación
  static Future<String> processPendingRotations() async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}$_baseEndpoint/process-pending';
      final response = await HttpInterceptorService.post(url);

      if (response.statusCode == 200) {
        final String message = response.body;
        return message;
      } else {
        throw Exception('Error al procesar rotaciones pendientes: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Verifica si la casa tiene configuración de rotación
  /// 
  /// Utiliza getRotationConfig() y maneja la excepción si no existe configuración
  /// 
  /// Retorna: true si existe configuración, false si no existe
  static Future<bool> hasRotationConfig() async {
    try {
      await getRotationConfig();
      return true;
    } catch (e) {
      // Si no existe configuración, la API lanza una excepción
      return false;
    }
  }

  /// Obtiene el estado actual de la rotación de forma simplificada
  /// 
  /// Retorna un mapa con información básica del estado de rotación
  static Future<Map<String, dynamic>> getRotationStatus() async {
    try {
      final config = await getRotationConfig();
      return {
        'isActive': config.isActive,
        'frequency': config.frequency,
        'nextRotationDate': config.nextRotationDate,
        'hasConfig': true,
      };
    } catch (e) {
      return {
        'isActive': false,
        'frequency': null,
        'nextRotationDate': null,
        'hasConfig': false,
      };
    }
  }

  /// Configura el intervalo de rotación con milisegundos
  /// 
  /// Endpoint: POST /api/v1/cleaning-rotation/configure-interval
  /// Parámetros: intervalMs (Long), frequency (String)
  /// Respuesta: RotationConfigResponse con la nueva configuración
  static Future<RotationConfigResponse> configureRotationInterval(int intervalMs, String frequency) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.apiVersion}$_baseEndpoint/configure-interval';
      
      // Construir URL con parámetros de consulta
      final uri = Uri.parse(url).replace(queryParameters: {
        'intervalMs': intervalMs.toString(),
        'frequency': frequency,
      });
      
      final response = await HttpInterceptorService.post(uri.toString());

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return RotationConfigResponse.fromMap(json);
      } else {
        throw Exception('Error al configurar intervalo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

/// Modelo para crear o actualizar configuración de rotación
/// 
/// Representa los datos necesarios para configurar la rotación:
/// - frequency: Frecuencia de rotación (WEEKLY, MONTHLY, CUSTOM)
/// - customDays: Días personalizados (solo si frequency = CUSTOM)
/// - startDate: Fecha de inicio de la rotación
class CreateRotationRequest {
  final String frequency;
  final int? customDays;
  final DateTime startDate;

  const CreateRotationRequest({
    required this.frequency,
    this.customDays,
    required this.startDate,
  });

  /// Crea una configuración de rotación semanal por defecto
  factory CreateRotationRequest.weeklyDefault() {
    return CreateRotationRequest(
      frequency: 'WEEKLY',
      customDays: null,
      startDate: DateTime.now(),
    );
  }

  /// Crea una configuración de rotación mensual
  factory CreateRotationRequest.monthly(DateTime startDate) {
    return CreateRotationRequest(
      frequency: 'MONTHLY',
      customDays: null,
      startDate: startDate,
    );
  }

  /// Crea una configuración de rotación personalizada
  factory CreateRotationRequest.custom(int days, DateTime startDate) {
    return CreateRotationRequest(
      frequency: 'CUSTOM',
      customDays: days,
      startDate: startDate,
    );
  }

  /// Convierte el objeto a Map para envío a la API
  Map<String, dynamic> toMap() {
    return {
      'frequency': frequency,
      'customDays': customDays,
      'startDate': startDate.toIso8601String(), // ✅ Formato ISO completo con hora: YYYY-MM-DDTHH:mm:ss.sss
    };
  }

  @override
  String toString() {
    return 'CreateRotationRequest(frequency: $frequency, customDays: $customDays, startDate: $startDate)';
  }
}

/// Modelo de respuesta de configuración de rotación
/// 
/// Representa la configuración actual de rotación de la casa:
/// - rotationId: ID único de la configuración (null si no existe)
/// - frequency: Frecuencia configurada (null si no existe)
/// - customDays: Días personalizados (si aplica)
/// - rotationIntervalMs: Intervalo de rotación en milisegundos
/// - startDate: Fecha de inicio (null si no existe)
/// - lastRotationDate: Fecha de la última rotación
/// - nextRotationDate: Fecha de la próxima rotación
/// - timeUntilNextRotationMs: Tiempo restante en milisegundos hasta la próxima rotación
/// - isActive: Estado activo/inactivo
/// - timestamps: Fechas de creación y actualización (null si no existe)
class RotationConfigResponse {
  final String? rotationId;
  final String? frequency;
  final int? customDays;
  final int? rotationIntervalMs;
  final DateTime? startDate;
  final DateTime? lastRotationDate;
  final DateTime? nextRotationDate;
  final int? timeUntilNextRotationMs;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RotationConfigResponse({
    this.rotationId,
    this.frequency,
    this.customDays,
    this.rotationIntervalMs,
    this.startDate,
    this.lastRotationDate,
    this.nextRotationDate,
    this.timeUntilNextRotationMs,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  /// Crea el objeto desde un Map de la API
  factory RotationConfigResponse.fromMap(Map<String, dynamic> map) {
    return RotationConfigResponse(
      rotationId: map['rotationId'] as String?,
      frequency: map['frequency'] as String?,
      customDays: map['customDays'] as int?,
      rotationIntervalMs: map['rotationIntervalMs'] as int?,
      startDate: map['startDate'] != null 
          ? DateTime.parse(map['startDate'] as String) 
          : null,
      lastRotationDate: map['lastRotationDate'] != null 
          ? DateTime.parse(map['lastRotationDate'] as String) 
          : null,
      nextRotationDate: map['nextRotationDate'] != null 
          ? DateTime.parse(map['nextRotationDate'] as String) 
          : null,
      timeUntilNextRotationMs: map['timeUntilNextRotationMs'] as int?,
      isActive: map['isActive'] as bool? ?? false,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'] as String) 
          : null,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'] as String) 
          : null,
    );
  }

  /// Obtiene una descripción legible de la frecuencia
  String get frequencyDescription {
    if (frequency == null) return 'Sin configuración';
    
    switch (frequency) {
      case 'WEEKLY':
        return 'Semanal';
      case 'MONTHLY':
        return 'Mensual';
      case 'CUSTOM':
        return 'Personalizada (${customDays ?? 0} días)';
      default:
        return frequency!;
    }
  }

  /// Verifica si la rotación está configurada como personalizada
  bool get isCustomFrequency => frequency == 'CUSTOM';

  /// Verifica si existe configuración de rotación
  bool get hasConfig => rotationId != null && frequency != null;

  /// Obtiene los días efectivos de rotación
  int get effectiveDays {
    if (frequency == null) return 7;
    
    switch (frequency) {
      case 'WEEKLY':
        return 7;
      case 'MONTHLY':
        return 30;
      case 'CUSTOM':
        return customDays ?? 7;
      default:
        return 7;
    }
  }

  @override
  String toString() {
    return 'RotationConfigResponse(rotationId: $rotationId, frequency: $frequency, isActive: $isActive)';
  }
}
