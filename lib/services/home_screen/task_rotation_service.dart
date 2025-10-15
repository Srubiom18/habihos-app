import 'dart:async';
import '../../models/api_models.dart';
import '../common/user_context_service.dart';

/// Servicio que maneja la lógica de rotación de tareas de limpieza
/// 
/// Gestiona la rotación automática y manual de tareas de limpieza,
/// incluyendo timers, callbacks de cambio de tarea y seguimiento
/// del progreso. Integra con UserContextService para obtener
/// configuraciones del usuario.
class TaskRotationService {
  static final TaskRotationService _instance = TaskRotationService._internal();
  factory TaskRotationService() => _instance;
  TaskRotationService._internal();

  final UserContextService _userContext = UserContextService();

  Timer? _timer;
  int _currentTaskIndex = 0;
  bool _isCompleted = false;
  
  /// Duración de rotación por defecto (1 semana)
  static const Duration defaultRotationDuration = Duration(days: 7);

  /// Callback que se ejecuta cuando cambia la tarea actual
  Function(int newIndex)? onTaskChanged;
  
  /// Callback que se ejecuta cuando se marca una tarea como completada
  Function(int taskIndex)? onTaskCompleted;

  /// Obtiene el índice de la tarea actual
  int get currentTaskIndex => _currentTaskIndex;

  /// Obtiene si la tarea actual está completada
  bool get isCompleted => _isCompleted;

  /// Obtiene si el timer está activo
  bool get isTimerActive => _timer?.isActive ?? false;

  /// Inicia la rotación automática de tareas
  /// 
  /// Configura un timer que rota automáticamente las tareas según
  /// la duración especificada. Si ya hay un timer activo, lo detiene primero.
  /// 
  /// [rotationDuration] - Duración entre rotaciones (opcional)
  void startTaskRotation({Duration? rotationDuration}) {
    stopTaskRotation(); // Detener cualquier timer existente
    
    final duration = rotationDuration ?? defaultRotationDuration;
    
    _timer = Timer.periodic(duration, (timer) {
      _rotateToNextTask();
    });
  }

  /// Detiene la rotación automática de tareas
  /// 
  /// Cancela el timer de rotación automática si está activo.
  void stopTaskRotation() {
    _timer?.cancel();
    _timer = null;
  }

  /// Obtiene el número total de áreas de limpieza disponibles
  /// 
  /// TODO: Integrar con CleaningService para obtener el valor dinámicamente
  int get _totalAreas {
    // TODO: Obtener dinámicamente del CleaningService
    return 4; // Por ahora, valor fijo
  }

  /// Rota a la siguiente tarea internamente
  /// 
  /// Actualiza el índice actual y resetea el estado de completado.
  /// Notifica a los listeners del cambio.
  void _rotateToNextTask() {
    _currentTaskIndex = (_currentTaskIndex + 1) % _totalAreas;
    _isCompleted = false;
    
    // Notificar el cambio
    onTaskChanged?.call(_currentTaskIndex);
  }

  /// Rota manualmente a la siguiente tarea
  /// 
  /// Permite al usuario avanzar manualmente a la siguiente tarea
  /// sin esperar el timer automático.
  void rotateToNextTask() {
    _rotateToNextTask();
  }

  /// Rota manualmente a la tarea anterior
  /// 
  /// Permite al usuario retroceder a la tarea anterior.
  /// Útil para correcciones o revisión de tareas.
  void rotateToPreviousTask() {
    _currentTaskIndex = (_currentTaskIndex - 1 + _totalAreas) % _totalAreas;
    _isCompleted = false;
    
    // Notificar el cambio
    onTaskChanged?.call(_currentTaskIndex);
  }

  /// Establece el índice de la tarea actual
  /// 
  /// [index] - Nuevo índice de tarea (debe ser válido)
  /// Valida el índice antes de establecerlo y notifica el cambio.
  void setCurrentTaskIndex(int index) {
    if (index >= 0 && index < _totalAreas) {
      _currentTaskIndex = index;
      _isCompleted = false;
      
      // Notificar el cambio
      onTaskChanged?.call(_currentTaskIndex);
    }
  }

  /// Marca la tarea actual como completada
  /// 
  /// Actualiza el estado de completado y notifica a los listeners.
  /// Solo se puede marcar una vez por tarea.
  void markCurrentTaskAsCompleted() {
    if (!_isCompleted) {
      _isCompleted = true;
      
      // Notificar la completación
      onTaskCompleted?.call(_currentTaskIndex);
    }
  }

  /// Marca la tarea actual como no completada
  /// 
  /// Permite deshacer la marcación de completado de la tarea actual.
  void markCurrentTaskAsIncomplete() {
    _isCompleted = false;
  }

  /// Reinicia el estado de completado
  /// 
  /// Resetea el estado de completado sin cambiar la tarea actual.
  void resetCompletionStatus() {
    _isCompleted = false;
  }

  /// Obtiene el progreso de la tarea actual (0.0 a 1.0)
  /// 
  /// Retorna 1.0 si la tarea está completada, 0.0 en caso contrario.
  double getCurrentTaskProgress() {
    return _isCompleted ? 1.0 : 0.0;
  }

  /// Obtiene el tiempo restante hasta la próxima rotación
  /// 
  /// TODO: Implementar tracking del tiempo restante del timer
  /// Retorna null por limitaciones del Timer.periodic estándar
  Duration? getTimeUntilNextRotation() {
    if (_timer?.isActive == true) {
      // Como no tenemos acceso directo al tiempo restante del Timer,
      // retornamos null. En una implementación real, podrías usar
      // un Timer.periodic personalizado que trackee el tiempo restante
      return null;
    }
    return null;
  }

  /// Obtiene información del estado actual
  /// 
  /// Retorna mapa con el estado completo del servicio para debugging
  Map<String, dynamic> getCurrentState() {
    return {
      'currentTaskIndex': _currentTaskIndex,
      'isCompleted': _isCompleted,
      'isTimerActive': isTimerActive,
      'progress': getCurrentTaskProgress(),
    };
  }

  /// Reinicia el servicio a su estado inicial
  /// 
  /// Detiene el timer, resetea el índice y el estado de completado.
  void reset() {
    stopTaskRotation();
    _currentTaskIndex = 0;
    _isCompleted = false;
  }

  /// Libera los recursos del servicio
  /// 
  /// Detiene el timer y limpia los callbacks. Debe llamarse
  /// cuando el servicio ya no se necesite.
  void dispose() {
    stopTaskRotation();
    onTaskChanged = null;
    onTaskCompleted = null;
  }

  /// Obtiene el porcentaje de progreso como string
  /// 
  /// Retorna el progreso formateado como porcentaje (ej: "75%")
  String getProgressPercentage() {
    return '${(getCurrentTaskProgress() * 100).toInt()}%';
  }

  /// Verifica si se puede marcar la tarea como completada
  /// 
  /// Retorna true si la tarea actual no está completada
  bool canMarkAsCompleted() {
    return !_isCompleted;
  }

  /// Obtiene el estado de la tarea como string
  /// 
  /// Retorna descripción textual del estado actual de la tarea
  String getTaskStatus() {
    return _isCompleted ? 'Completada' : 'En progreso';
  }

  /// Obtiene la duración de rotación basada en la configuración del usuario
  /// 
  /// Consulta la configuración del usuario para obtener la duración
  /// personalizada de rotación. Si no está configurada, usa el valor por defecto.
  /// 
  /// Retorna duración de rotación en días
  Duration getRotationDuration() {
    final settings = _userContext.getCleaningSettings();
    if (settings != null && settings['rotation_duration_days'] != null) {
      final days = settings['rotation_duration_days'] as int;
      return Duration(days: days);
    }
    return defaultRotationDuration;
  }

  /// Obtiene el horario de limpieza actual del usuario
  /// 
  /// Delega al UserContextService para obtener el horario activo.
  /// 
  /// Retorna horario actual o null si no hay ninguno activo
  CleaningScheduleModel? getCurrentUserSchedule() {
    return _userContext.getCurrentUserSchedule();
  }

  /// Obtiene el próximo horario de limpieza del usuario
  /// 
  /// Delega al UserContextService para obtener el próximo horario.
  /// 
  /// Retorna próximo horario o null si no hay ninguno programado
  CleaningScheduleModel? getNextUserSchedule() {
    return _userContext.getNextUserSchedule();
  }

  /// Verifica si hay un horario de limpieza activo
  /// 
  /// Comprueba si el usuario tiene un horario de limpieza en progreso.
  /// 
  /// Retorna true si hay horario activo, false en caso contrario
  bool hasActiveSchedule() {
    return getCurrentUserSchedule() != null;
  }

  /// Obtiene el tiempo restante hasta el próximo horario
  /// 
  /// Calcula la diferencia entre ahora y el próximo horario programado.
  /// 
  /// Retorna duración restante o null si no hay próximo horario
  Duration? getTimeUntilNextSchedule() {
    final nextSchedule = getNextUserSchedule();
    if (nextSchedule == null) return null;
    
    final now = DateTime.now();
    if (nextSchedule.scheduledDate.isAfter(now)) {
      return nextSchedule.scheduledDate.difference(now);
    }
    return null;
  }
}
