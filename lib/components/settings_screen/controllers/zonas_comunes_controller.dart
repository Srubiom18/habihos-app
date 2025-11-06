import 'dart:async';
import 'package:flutter/material.dart';
import '../../../services/cleaning_area_service.dart';
import '../../../services/cleaning_calendar_service.dart';
import '../../../services/cleaning_rotation_service.dart';
import '../../../services/cleaning_rotation_exclusion_service.dart';
import '../../../services/common/zones_update_notifier_service.dart';
import '../../../services/house/house_member_service.dart';
import '../../../models/api_models.dart';
import '../../../models/house_member_models.dart';

/// Controlador para manejar la lógica de negocio de las zonas comunes
class ZonasComunesController extends ChangeNotifier {
  List<CleaningAreaResponse> _zonasComunes = [];
  CleaningCalendarResponse? _calendarData;
  List<FixedAssignmentResponse> _fixedAssignments = [];
  RotationConfigResponse? _rotationConfig;
  bool _isLoading = true;
  bool _isRefreshing = false; // Para recargas en background
  String? _errorMessage;
  
  // Cronómetro de rotación
  Timer? _rotationTimer;
  Duration _timeUntilNextRotation = Duration.zero;
  bool _isRotationCountdownActive = false;

  // Getters
  List<CleaningAreaResponse> get zonasComunes => _zonasComunes;
  CleaningCalendarResponse? get calendarData => _calendarData;
  List<FixedAssignmentResponse> get fixedAssignments => _fixedAssignments;
  RotationConfigResponse? get rotationConfig => _rotationConfig;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing; // Para mostrar indicador opcional
  String? get errorMessage => _errorMessage;
  int get zonasActivas => _zonasComunes.length;
  bool get isRotationActive => _calendarData?.isActive ?? false;
  
  // Getters del cronómetro
  Duration get timeUntilNextRotation => _timeUntilNextRotation;
  bool get isRotationCountdownActive => _isRotationCountdownActive;
  String get rotationCountdownText => _formatCountdown(_timeUntilNextRotation);
  
  /// Obtiene información detallada del estado de rotación
  Map<String, dynamic> get rotationStatus => {
    'isActive': isRotationActive,
    'hasConfig': _rotationConfig?.hasConfig ?? false,
    'frequency': _rotationConfig?.frequency,
    'nextRotationDate': _rotationConfig?.nextRotationDate,
    'frequencyDescription': _rotationConfig?.frequencyDescription ?? 'Sin configuración',
  };

  /// Carga las zonas de limpieza desde la API
  /// 
  /// [silent] - Si es true, no muestra el loader completo (para recargas en background)
  Future<void> loadCleaningAreas({bool silent = false}) async {
    try {
      if (silent) {
        _isRefreshing = true;
        notifyListeners();
      } else {
        _setLoadingState(true);
      }
      _errorMessage = null;

      final areas = await CleaningAreaService.getCleaningAreas();
      
      // Ordenar alfabéticamente por nombre
      areas.sort((a, b) => a.name.compareTo(b.name));
      
      _zonasComunes = areas;
      
      if (silent) {
        _isRefreshing = false;
        notifyListeners();
      } else {
        _setLoadingState(false);
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (silent) {
        _isRefreshing = false;
        notifyListeners();
      } else {
        _setLoadingState(false);
      }
      rethrow; // Re-lanzar para que la UI pueda manejar el error
    }
  }

  /// Carga el calendario de limpieza con información de usuarios asignados
  /// 
  /// [silent] - Si es true, no muestra el loader completo (para recargas en background)
  Future<void> loadCleaningCalendar({bool silent = false}) async {
    try {
      if (silent) {
        _isRefreshing = true;
        notifyListeners();
      } else {
        _setLoadingState(true);
      }
      _errorMessage = null;

      // Cargar calendario, asignaciones fijas y configuración de rotación en paralelo
      final results = await Future.wait([
        CleaningCalendarService.getCleaningCalendar(),
        CleaningCalendarService.getFixedAssignments(),
        _loadRotationConfig(),
      ]);
      
      _calendarData = results[0] as CleaningCalendarResponse;
      _fixedAssignments = results[1] as List<FixedAssignmentResponse>;
      _rotationConfig = results[2] as RotationConfigResponse?;
      
      // Iniciar cronómetro si la rotación está activa y hay tiempo calculado
      if (isRotationActive && _calendarData!.timeUntilNextRotationMs != null) {
        _startRotationCountdownFromCalendar();
      }
      
      if (silent) {
        _isRefreshing = false;
        notifyListeners();
      } else {
        _setLoadingState(false);
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (silent) {
        _isRefreshing = false;
        notifyListeners();
      } else {
        _setLoadingState(false);
      }
      rethrow; // Re-lanzar para que la UI pueda manejar el error
    }
  }

  /// Crea una nueva zona de limpieza
  Future<void> createCleaningArea(CreateCleaningAreaRequest request) async {
    try {
      await CleaningAreaService.createCleaningArea(request);
      
      // Notificar que se creó una nueva zona
      ZonesUpdateNotifierService().notifyZonesChanged();
      
      // Recargar la lista
      await loadCleaningAreas();
    } catch (e) {
      rethrow; // Re-lanzar para que la UI pueda manejar el error
    }
  }

  /// Actualiza una zona de limpieza existente
  Future<void> updateCleaningArea(String id, CreateCleaningAreaRequest request) async {
    try {
      await CleaningAreaService.updateCleaningArea(id, request);
      
      // Notificar que se actualizó una zona
      ZonesUpdateNotifierService().notifyZonesChanged();
      
      // Recargar la lista
      await loadCleaningAreas();
    } catch (e) {
      rethrow; // Re-lanzar para que la UI pueda manejar el error
    }
  }

  /// Elimina una zona de limpieza
  Future<void> deleteCleaningArea(String id) async {
    try {
      await CleaningAreaService.deleteCleaningArea(id);
      
      // Notificar a la home screen que se eliminó una zona
      ZonesUpdateNotifierService().notifyZonesChanged();
      
      // Eliminar de la lista local en lugar de recargar todo
      _zonasComunes.removeWhere((zona) => zona.id == id);
      
      // También actualizar el calendario si contiene información de esta zona
      if (_calendarData != null) {
        final filteredZones = _calendarData!.zoneRotation
            .where((zone) => zone.cleaningAreaId != id)
            .toList();
        
        // Crear una nueva instancia del calendario con las zonas filtradas
        _calendarData = CleaningCalendarResponse(
          rotationId: _calendarData!.rotationId,
          frequency: _calendarData!.frequency,
          rotationDays: _calendarData!.rotationDays,
          startDate: _calendarData!.startDate,
          nextRotationDate: _calendarData!.nextRotationDate,
          timeUntilNextRotationMs: _calendarData!.timeUntilNextRotationMs,
          isActive: _calendarData!.isActive,
          hasConfiguredZones: _calendarData!.hasConfiguredZones,
          zoneRotation: filteredZones,
          message: _calendarData!.message,
        );
      }
      
      // Notificar a los listeners para actualizar la UI
      notifyListeners();
    } catch (e) {
      rethrow; // Re-lanzar para que la UI pueda manejar el error
    }
  }

  /// Activa o desactiva la rotación de limpieza
  /// 
  /// Comportamiento:
  /// - Al activar: Configura rotación semanal por defecto y genera horarios
  /// - Al desactivar: Limpia todos los datos de rotación
  Future<void> toggleRotation(bool isActive) async {
    try {
      _isRefreshing = true;
      _errorMessage = null;
      notifyListeners();
      
      _rotationConfig = await CleaningRotationService.toggleRotation(isActive);
      
      // Notificar que se cambió el estado de rotación
      ZonesUpdateNotifierService().notifyZonesChanged();
      
      // Recargar el calendario para obtener los datos actualizados (silenciosamente)
      await loadCleaningCalendar(silent: true);
      
      // Iniciar o detener cronómetro según el estado
      if (isActive) {
        await loadCleaningCalendar(silent: true); // Recargar para obtener datos actualizados
      } else {
        _stopRotationCountdown();
      }
      
      _isRefreshing = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isRefreshing = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Asigna un usuario a una zona de limpieza
  Future<void> assignUserToZone(String areaId, String memberId) async {
    try {
      await CleaningCalendarService.assignUserToZone(areaId, memberId);
      
      // Notificar que se asignó un usuario
      ZonesUpdateNotifierService().notifyZonesChanged();
      
      // Recargar el calendario
      await loadCleaningCalendar();
    } catch (e) {
      rethrow; // Re-lanzar para que la UI pueda manejar el error
    }
  }

  /// Desasigna un usuario de una zona de limpieza
  Future<void> unassignUserFromZone(String assignmentId) async {
    try {
      await CleaningCalendarService.unassignUserFromZone(assignmentId);
      
      // Notificar que se desasignó un usuario
      ZonesUpdateNotifierService().notifyZonesChanged();
      
      // Recargar el calendario
      await loadCleaningCalendar();
    } catch (e) {
      rethrow; // Re-lanzar para que la UI pueda manejar el error
    }
  }

  /// Obtiene la próxima limpieza programada
  String getProximaLimpieza() {
    // Simulación - en el futuro vendrá de la API
    return 'Mañana 9:00 AM';
  }

  /// Convierte un string de color hexadecimal a Color
  Color parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue; // Color por defecto si hay error
    }
  }

  /// Formatea una fecha para mostrar
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoy ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Obtiene el icono correspondiente para cada zona
  IconData getZonaIcon(String nombreZona) {
    switch (nombreZona.toLowerCase()) {
      case 'cocina':
        return Icons.kitchen_rounded;
      case 'sala de estar':
        return Icons.living_rounded;
      case 'baño principal':
      case 'baño':
        return Icons.bathroom_rounded;
      case 'pasillo':
        return Icons.door_front_door_rounded;
      case 'balcón':
        return Icons.balcony_rounded;
      case 'terraza':
        return Icons.deck_rounded;
      case 'garaje':
        return Icons.garage_rounded;
      default:
        return Icons.room_rounded;
    }
  }

  /// Establece el estado de carga y notifica a los listeners
  void _setLoadingState(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Obtiene los miembros de la casa disponibles para asignar
  Future<List<HouseMemberInfo>> getAvailableMembers() async {
    try {
      return await HouseMemberService.getHouseMembers();
    } catch (e) {
      throw Exception('Error al cargar miembros: $e');
    }
  }


  // ========== MÉTODOS DE GESTIÓN DE ROTACIÓN ==========

  /// Carga la configuración de rotación de forma segura
  /// 
  /// Si no existe configuración, retorna null sin lanzar excepción
  Future<RotationConfigResponse?> _loadRotationConfig() async {
    try {
      return await CleaningRotationService.getRotationConfig();
    } catch (e) {
      return null;
    }
  }

  /// Configura la rotación con parámetros específicos
  /// 
  /// Permite configurar frecuencia, días personalizados y fecha de inicio
  Future<void> configureRotation(CreateRotationRequest request) async {
    try {
      _isRefreshing = true;
      _errorMessage = null;
      notifyListeners();
      
      _rotationConfig = await CleaningRotationService.configureRotation(request);
      
      // Notificar que se configuró la rotación
      ZonesUpdateNotifierService().notifyZonesChanged();
      
      // Recargar el calendario (silenciosamente)
      await loadCleaningCalendar(silent: true);
      
      _isRefreshing = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isRefreshing = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Configura rotación semanal por defecto
  Future<void> configureWeeklyRotation() async {
    final request = CreateRotationRequest.weeklyDefault();
    await configureRotation(request);
  }

  /// Configura rotación mensual
  Future<void> configureMonthlyRotation(DateTime startDate) async {
    final request = CreateRotationRequest.monthly(startDate);
    await configureRotation(request);
  }

  /// Configura rotación personalizada
  Future<void> configureCustomRotation(int days, DateTime startDate) async {
    final request = CreateRotationRequest.custom(days, startDate);
    await configureRotation(request);
  }

  /// Procesa las rotaciones pendientes
  /// 
  /// Busca todas las rotaciones que necesitan actualización y genera nuevos horarios
  Future<void> processPendingRotations() async {
    try {
      _isRefreshing = true;
      _errorMessage = null;
      notifyListeners();
      
      await CleaningRotationService.processPendingRotations();
      
      // Notificar que se procesaron las rotaciones
      ZonesUpdateNotifierService().notifyZonesChanged();
      
      // Recargar el calendario para obtener los nuevos horarios (silenciosamente)
      await loadCleaningCalendar(silent: true);
      
      _isRefreshing = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isRefreshing = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Verifica si existe configuración de rotación
  Future<bool> hasRotationConfig() async {
    try {
      return await CleaningRotationService.hasRotationConfig();
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el estado actual de la rotación
  Future<Map<String, dynamic>> getRotationStatus() async {
    try {
      return await CleaningRotationService.getRotationStatus();
    } catch (e) {
      return {
        'isActive': false,
        'frequency': null,
        'nextRotationDate': null,
        'hasConfig': false,
      };
    }
  }

  /// Obtiene información detallada de la próxima rotación
  String getNextRotationInfo() {
    if (_rotationConfig?.nextRotationDate == null) {
      return 'No hay próxima rotación programada';
    }
    
    final nextDate = _rotationConfig!.nextRotationDate!;
    final now = DateTime.now();
    final difference = nextDate.difference(now);
    
    if (difference.inDays > 0) {
      return 'Próxima rotación en ${difference.inDays} días';
    } else if (difference.inDays == 0) {
      return 'Próxima rotación hoy';
    } else {
      return 'Rotación pendiente de procesamiento';
    }
  }

  /// Verifica si hay rotaciones pendientes de procesar
  bool get hasPendingRotations {
    if (_rotationConfig?.nextRotationDate == null) return false;
    
    final nextDate = _rotationConfig!.nextRotationDate!;
    final now = DateTime.now();
    
    return now.isAfter(nextDate) || now.isAtSameMomentAs(nextDate);
  }

  /// Configura el intervalo de rotación con milisegundos
  Future<void> configureRotationInterval(int intervalMs, String frequency) async {
    try {
      _isRefreshing = true;
      notifyListeners();
      
      // Obtener la respuesta del POST que ya incluye timeUntilNextRotationMs
      final rotationResponse = await CleaningRotationService.configureRotationInterval(intervalMs, frequency);
      _rotationConfig = rotationResponse;
      
      // Notificar cambios
      ZonesUpdateNotifierService().notifyZonesChanged();
      
      // Recargar todos los datos para ver cambios reflejados (silenciosamente)
      await Future.wait([
        loadCleaningAreas(silent: true),
        loadCleaningCalendar(silent: true),
      ]);
      
      // Iniciar cronómetro usando los datos del calendario (que tiene timeUntilNextRotationMs)
      if (isRotationActive && _calendarData?.timeUntilNextRotationMs != null) {
        _startRotationCountdownFromCalendar();
      }
      
      _isRefreshing = false;
      notifyListeners();
    } catch (e) {
      _isRefreshing = false;
      notifyListeners();
      throw Exception('Error al configurar intervalo de rotación: $e');
    }
  }

  // ========== MÉTODOS DEL CRONÓMETRO ==========


  /// Detiene el cronómetro de rotación
  void _stopRotationCountdown() {
    _rotationTimer?.cancel();
    _rotationTimer = null;
    _isRotationCountdownActive = false;
    _timeUntilNextRotation = Duration.zero;
  }

  /// Se ejecuta cuando el cronómetro llega a cero
  Future<void> _onRotationCountdownFinished() async {
    _stopRotationCountdown();
    
    try {
      // Recargar todas las zonas con sus asignaciones actualizadas (SILENCIOSAMENTE)
      await loadCleaningAreas(silent: true);
      await loadCleaningCalendar(silent: true);
      await _loadRotationConfig();
      
      // Reiniciar cronómetro si la rotación sigue activa
      if (isRotationActive) {
        _startRotationCountdownFromNextDate();
      }
      
      notifyListeners();
    } catch (e) {
      // Error silencioso
    }
  }

  /// Formatea el tiempo restante en un string legible
  String _formatCountdown(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h ${duration.inMinutes % 60}m';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m ${duration.inSeconds % 60}s';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Inicia el cronómetro basándose en el tiempo calculado por el servidor
  void _startRotationCountdownFromCalendar() {
    _stopRotationCountdown();
    
    if (_calendarData?.timeUntilNextRotationMs == null) {
      return;
    }
    
    final remainingMs = _calendarData!.timeUntilNextRotationMs!;
    
    // Si ya pasó la fecha (tiempo <= 0), ejecutar actualización inmediata
    if (remainingMs <= 0) {
      _timeUntilNextRotation = Duration.zero;
      _isRotationCountdownActive = true;
      notifyListeners();
      Future.microtask(() => _onRotationCountdownFinished());
      return;
    }
    
    _timeUntilNextRotation = Duration(milliseconds: remainingMs);
    _isRotationCountdownActive = true;
    notifyListeners();
    
    _rotationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeUntilNextRotation.inSeconds > 0) {
        _timeUntilNextRotation = Duration(seconds: _timeUntilNextRotation.inSeconds - 1);
        notifyListeners();
      } else {
        _onRotationCountdownFinished();
      }
    });
  }

  /// Inicia el cronómetro basándose en la próxima fecha de rotación (legacy)
  void _startRotationCountdownFromNextDate() {
    // Delegar al método que usa el tiempo calculado por el servidor
    _startRotationCountdownFromCalendar();
  }

  // ========== MÉTODOS DE GESTIÓN DE EXCLUSIONES ==========

  /// Crea una exclusión de rotación para un usuario en una zona específica
  Future<void> createRotationExclusion(String memberId, String cleaningAreaId, {String? reason}) async {
    try {
      final exclusionResponse = await CleaningRotationExclusionService.createExclusion(
        memberId,
        cleaningAreaId,
        reason: reason,
      );
      
      // Notificar que se creó una exclusión
      ZonesUpdateNotifierService().notifyZonesChanged();
      
      // Actualizar localmente el calendario en lugar de recargar todo
      if (_calendarData != null) {
        // Buscar la zona correspondiente
        final existingZoneIndex = _calendarData!.zoneRotation.indexWhere(
          (zone) => zone.cleaningAreaId == cleaningAreaId
        );
        
        // Crear un nuevo AssignedUserInfo con la información de la exclusión
        // El fromMap ya garantiza que todos los campos String no sean null
        final excludedUser = AssignedUserInfo(
          memberId: exclusionResponse.memberId,
          memberName: exclusionResponse.memberName,
          memberEmail: exclusionResponse.memberEmail,
          userInitials: _generateInitials(exclusionResponse.memberName),
          hasRegisteredAccount: false, // Valor por defecto, no crítico para mostrar
          assignmentId: null,
          exclusionId: exclusionResponse.id,
        );
        
        List<CleaningZoneRotationResponse> updatedZones;
        
        if (existingZoneIndex >= 0) {
          // La zona existe, actualizar la lista de usuarios excluidos
          final existingZone = _calendarData!.zoneRotation[existingZoneIndex];
          
          // Verificar que el usuario no esté ya excluido
          final alreadyExcluded = existingZone.excludeUsers.any(
            (user) => user.memberId == memberId || user.exclusionId == exclusionResponse.id
          );
          
          if (!alreadyExcluded) {
            // Crear nueva lista de usuarios excluidos con el nuevo usuario
            final updatedExcludedUsers = List<AssignedUserInfo>.from(existingZone.excludeUsers)..add(excludedUser);
            
            // Crear nueva instancia de la zona con los usuarios excluidos actualizados
            final updatedZone = CleaningZoneRotationResponse(
              assignmentId: existingZone.assignmentId,
              cleaningAreaId: existingZone.cleaningAreaId,
              cleaningAreaName: existingZone.cleaningAreaName,
              cleaningAreaDescription: existingZone.cleaningAreaDescription,
              cleaningAreaColor: existingZone.cleaningAreaColor,
              status: existingZone.status,
              periodStart: existingZone.periodStart,
              periodEnd: existingZone.periodEnd,
              completedAt: existingZone.completedAt,
              notes: existingZone.notes,
              isCurrent: existingZone.isCurrent,
              isOverdue: existingZone.isOverdue,
              positionInRotation: existingZone.positionInRotation,
              assignedUsers: existingZone.assignedUsers,
              excludeUsers: updatedExcludedUsers,
            );
            
            // Reemplazar la zona en la lista
            updatedZones = List<CleaningZoneRotationResponse>.from(_calendarData!.zoneRotation);
            updatedZones[existingZoneIndex] = updatedZone;
          } else {
            // Ya está excluido, no hacer nada
            updatedZones = _calendarData!.zoneRotation;
          }
        } else {
          // La zona no existe en zoneRotation, crear una nueva entrada
          // Buscar información de la zona en zonas comunes
          final zonaComun = _zonasComunes.firstWhere(
            (zona) => zona.id == cleaningAreaId,
            orElse: () => CleaningAreaResponse(
              id: cleaningAreaId,
              name: exclusionResponse.cleaningAreaName,
              description: exclusionResponse.cleaningAreaDescription,
              color: exclusionResponse.cleaningAreaColor,
              houseId: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          
          // Crear nueva zona con el usuario excluido
          final newZone = CleaningZoneRotationResponse(
            assignmentId: null,
            cleaningAreaId: cleaningAreaId,
            cleaningAreaName: zonaComun.name,
            cleaningAreaDescription: zonaComun.description,
            cleaningAreaColor: zonaComun.color,
            status: null,
            periodStart: null,
            periodEnd: null,
            completedAt: null,
            notes: null,
            isCurrent: false,
            isOverdue: false,
            positionInRotation: 0,
            assignedUsers: [],
            excludeUsers: [excludedUser],
          );
          
          // Añadir la nueva zona a la lista
          updatedZones = List<CleaningZoneRotationResponse>.from(_calendarData!.zoneRotation)..add(newZone);
        }
        
        // Crear nueva instancia del calendario con las zonas actualizadas
        _calendarData = CleaningCalendarResponse(
          rotationId: _calendarData!.rotationId,
          frequency: _calendarData!.frequency,
          rotationDays: _calendarData!.rotationDays,
          startDate: _calendarData!.startDate,
          nextRotationDate: _calendarData!.nextRotationDate,
          timeUntilNextRotationMs: _calendarData!.timeUntilNextRotationMs,
          isActive: _calendarData!.isActive,
          hasConfiguredZones: _calendarData!.hasConfiguredZones,
          zoneRotation: updatedZones,
          message: _calendarData!.message,
        );
        
        notifyListeners();
      }
    } catch (e) {
      rethrow; // Re-lanzar para que la UI pueda manejar el error
    }
  }

  /// Elimina una exclusión de rotación existente
  Future<void> removeRotationExclusion(String exclusionId) async {
    try {
      await CleaningRotationExclusionService.removeExclusion(exclusionId);
      
      // Notificar que se eliminó una exclusión
      ZonesUpdateNotifierService().notifyZonesChanged();
      
      // Actualizar localmente el calendario en lugar de recargar todo
      if (_calendarData != null) {
        final updatedZones = _calendarData!.zoneRotation.map((zone) {
          // Filtrar el usuario excluido por exclusionId
          final updatedExcludedUsers = zone.excludeUsers
              .where((user) => user.exclusionId != exclusionId)
              .toList();
          
          // Solo actualizar si hubo cambios
          if (updatedExcludedUsers.length != zone.excludeUsers.length) {
            // Crear nueva instancia de la zona con los usuarios excluidos actualizados
            return CleaningZoneRotationResponse(
              assignmentId: zone.assignmentId,
              cleaningAreaId: zone.cleaningAreaId,
              cleaningAreaName: zone.cleaningAreaName,
              cleaningAreaDescription: zone.cleaningAreaDescription,
              cleaningAreaColor: zone.cleaningAreaColor,
              status: zone.status,
              periodStart: zone.periodStart,
              periodEnd: zone.periodEnd,
              completedAt: zone.completedAt,
              notes: zone.notes,
              isCurrent: zone.isCurrent,
              isOverdue: zone.isOverdue,
              positionInRotation: zone.positionInRotation,
              assignedUsers: zone.assignedUsers,
              excludeUsers: updatedExcludedUsers,
            );
          }
          return zone;
        }).toList();
        
        // Crear nueva instancia del calendario con las zonas actualizadas
        _calendarData = CleaningCalendarResponse(
          rotationId: _calendarData!.rotationId,
          frequency: _calendarData!.frequency,
          rotationDays: _calendarData!.rotationDays,
          startDate: _calendarData!.startDate,
          nextRotationDate: _calendarData!.nextRotationDate,
          timeUntilNextRotationMs: _calendarData!.timeUntilNextRotationMs,
          isActive: _calendarData!.isActive,
          hasConfiguredZones: _calendarData!.hasConfiguredZones,
          zoneRotation: updatedZones,
          message: _calendarData!.message,
        );
        
        notifyListeners();
      }
    } catch (e) {
      rethrow; // Re-lanzar para que la UI pueda manejar el error
    }
  }

  /// Genera las iniciales del nombre para mostrar en avatares
  String _generateInitials(String name) {
    final words = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    
    if (words.length == 1) {
      return words[0].substring(0, words[0].length >= 1 ? 1 : words[0].length).toUpperCase();
    }
    
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
  }

  @override
  void dispose() {
    _stopRotationCountdown();
    super.dispose();
  }
}
