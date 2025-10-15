import '../../models/api_models.dart';

/// Servicio que maneja el contexto del usuario actual
class UserContextService {
  static final UserContextService _instance = UserContextService._internal();
  factory UserContextService() => _instance;
  UserContextService._internal();

  UserModel? _currentUser;
  HouseConfigModel? _currentHouse;
  CleaningCalendarModel? _currentCalendar;

  /// Usuario actual
  UserModel? get currentUser => _currentUser;

  /// Casa actual
  HouseConfigModel? get currentHouse => _currentHouse;

  /// Calendario actual
  CleaningCalendarModel? get currentCalendar => _currentCalendar;

  /// ID del usuario actual
  String? get currentUserId => _currentUser?.id;

  /// ID de la casa actual
  String? get currentHouseId => _currentHouse?.id;

  /// Verifica si hay un usuario logueado
  bool get isLoggedIn => _currentUser != null;

  /// Verifica si hay una casa seleccionada
  bool get hasHouseSelected => _currentHouse != null;

  /// Verifica si hay un calendario activo
  bool get hasActiveCalendar => _currentCalendar != null;

  /// Establece el usuario actual
  void setCurrentUser(UserModel user) {
    _currentUser = user;
  }

  /// Establece la casa actual
  void setCurrentHouse(HouseConfigModel house) {
    _currentHouse = house;
  }

  /// Establece el calendario actual
  void setCurrentCalendar(CleaningCalendarModel calendar) {
    _currentCalendar = calendar;
  }

  /// Obtiene las preferencias del usuario
  Map<String, dynamic>? getUserPreferences() {
    return _currentUser?.preferences;
  }

  /// Obtiene una preferencia específica del usuario
  T? getUserPreference<T>(String key) {
    return _currentUser?.preferences?[key] as T?;
  }

  /// Establece una preferencia del usuario
  void setUserPreference(String key, dynamic value) {
    if (_currentUser != null) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        avatar: _currentUser!.avatar,
        phone: _currentUser!.phone,
        createdAt: _currentUser!.createdAt,
        lastActiveAt: _currentUser!.lastActiveAt,
        isActive: _currentUser!.isActive,
        preferences: {
          ...(_currentUser!.preferences ?? {}),
          key: value,
        },
      );
    }
  }

  /// Obtiene la configuración de limpieza de la casa
  Map<String, dynamic>? getCleaningSettings() {
    return _currentHouse?.cleaningSettings;
  }

  /// Obtiene la configuración de notificaciones de la casa
  Map<String, dynamic>? getNotificationSettings() {
    return _currentHouse?.notificationSettings;
  }

  /// Obtiene los IDs de los miembros de la casa
  List<String> getHouseMemberIds() {
    return _currentHouse?.memberIds ?? [];
  }

  /// Verifica si el usuario actual es miembro de la casa
  bool isCurrentUserHouseMember() {
    if (_currentUser == null || _currentHouse == null) return false;
    return _currentHouse!.memberIds.contains(_currentUser!.id);
  }

  /// Obtiene el horario de limpieza actual del usuario
  List<CleaningScheduleModel> getCurrentUserSchedules() {
    if (_currentCalendar == null || _currentUser == null) return [];
    return _currentCalendar!.schedules
        .where((schedule) => schedule.userId == _currentUser!.id)
        .toList();
  }

  /// Obtiene el próximo horario de limpieza del usuario
  CleaningScheduleModel? getNextUserSchedule() {
    final schedules = getCurrentUserSchedules();
    if (schedules.isEmpty) return null;

    final now = DateTime.now();
    final upcomingSchedules = schedules
        .where((schedule) => schedule.scheduledDate.isAfter(now))
        .toList();

    if (upcomingSchedules.isEmpty) return null;

    upcomingSchedules.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return upcomingSchedules.first;
  }

  /// Obtiene el horario de limpieza actual (en progreso)
  CleaningScheduleModel? getCurrentUserSchedule() {
    final schedules = getCurrentUserSchedules();
    if (schedules.isEmpty) return null;

    final now = DateTime.now();
    return schedules.firstWhere(
      (schedule) => 
          schedule.scheduledDate.isBefore(now) && 
          schedule.status == 'in_progress',
      orElse: () => schedules.firstWhere(
        (schedule) => 
            schedule.scheduledDate.isBefore(now) && 
            schedule.status == 'pending',
        orElse: () => schedules.first,
      ),
    );
  }

  /// Limpia el contexto (para logout)
  void clearContext() {
    _currentUser = null;
    _currentHouse = null;
    _currentCalendar = null;
  }

  /// Actualiza la información del usuario
  void updateUser(UserModel updatedUser) {
    if (_currentUser?.id == updatedUser.id) {
      _currentUser = updatedUser;
    }
  }

  /// Actualiza la información de la casa
  void updateHouse(HouseConfigModel updatedHouse) {
    if (_currentHouse?.id == updatedHouse.id) {
      _currentHouse = updatedHouse;
    }
  }

  /// Actualiza el calendario
  void updateCalendar(CleaningCalendarModel updatedCalendar) {
    if (_currentCalendar?.id == updatedCalendar.id) {
      _currentCalendar = updatedCalendar;
    }
  }

  /// Obtiene un resumen del contexto actual
  Map<String, dynamic> getContextSummary() {
    return {
      'user_id': _currentUser?.id,
      'user_name': _currentUser?.name,
      'house_id': _currentHouse?.id,
      'house_name': _currentHouse?.name,
      'calendar_id': _currentCalendar?.id,
      'is_logged_in': isLoggedIn,
      'has_house_selected': hasHouseSelected,
      'has_active_calendar': hasActiveCalendar,
      'next_schedule': getNextUserSchedule()?.id,
      'current_schedule': getCurrentUserSchedule()?.id,
    };
  }
}
