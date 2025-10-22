import '../../interfaces/home_screen/cleaning_area.dart';
import '../../models/api_models.dart';
import 'cleaning_calendar_service.dart';
import '../common/cleaning_zones_state_service.dart';
import '../house/house_member_service.dart';

/// Servicio que maneja la lógica de negocio relacionada con las áreas de limpieza
/// 
/// Proporciona funcionalidades para gestionar áreas de limpieza, incluyendo
/// carga desde API, cache local, filtrado y búsqueda. Ahora integra con
/// el endpoint real del calendario de limpieza.
class CleaningService {
  static final CleaningService _instance = CleaningService._internal();
  factory CleaningService() => _instance;
  CleaningService._internal() {
    _initializeWithExampleData();
  }

  final CleaningCalendarService _calendarService = CleaningCalendarService();
  final CleaningZonesStateService _zonesStateService = CleaningZonesStateService();

  /// Lista de áreas de limpieza en memoria (cache local)
  List<CleaningArea> _cleaningAreas = [];

  /// Timestamp de la última actualización
  DateTime? _lastUpdated;

  /// Duración del cache en minutos
  static const int cacheDurationMinutes = 10;

  /// Estado del calendario de la API
  CleaningCalendarResponse? _calendarResponse;

  /// Cache para el memberId del usuario actual
  String? _cachedMemberId;
  DateTime? _memberIdCacheTime;
  static const int memberIdCacheMinutes = 30;

  /// Indica si hay zonas configuradas según la API
  bool get hasConfiguredZones => _calendarResponse?.hasConfiguredZones ?? false;

  /// Mensaje de estado del calendario
  String get calendarMessage => _calendarResponse?.message ?? '';

  /// Indica si la rotación está activa
  bool get isRotationActive => _calendarResponse?.isActive ?? false;

  /// Inicializa el servicio con datos de ejemplo (para desarrollo)
  void _initializeWithExampleData() {
    _cleaningAreas = [
      const CleaningAreaImpl(
        id: '1',
        name: 'Comedor',
        description: 'Mesa, sillas y área de comedor',
        priority: 1,
        estimatedMinutes: 30,
        difficulty: 2,
        instructions: [
          'Limpiar la mesa con desinfectante',
          'Aspirar las sillas',
          'Barrer y trapear el suelo'
        ],
        requiredMaterials: ['Desinfectante', 'Aspiradora', 'Escoba', 'Trapeador'],
      ),
      const CleaningAreaImpl(
        id: '2',
        name: 'Cocina',
        description: 'Encimera, electrodomésticos y fregadero',
        priority: 2,
        estimatedMinutes: 45,
        difficulty: 3,
        instructions: [
          'Limpiar la encimera',
          'Limpiar el fregadero',
          'Limpiar los electrodomésticos por fuera',
          'Barrer y trapear el suelo'
        ],
        requiredMaterials: ['Desinfectante', 'Esponja', 'Escoba', 'Trapeador'],
      ),
      const CleaningAreaImpl(
        id: '3',
        name: 'Baño',
        description: 'Lavabo, inodoro y ducha',
        priority: 3,
        estimatedMinutes: 25,
        difficulty: 4,
        instructions: [
          'Limpiar el inodoro',
          'Limpiar el lavabo',
          'Limpiar la ducha',
          'Limpiar los espejos',
          'Barrer y trapear el suelo'
        ],
        requiredMaterials: ['Desinfectante', 'Limpiavidrios', 'Escoba', 'Trapeador'],
      ),
      const CleaningAreaImpl(
        id: '4',
        name: 'Pasillo',
        description: 'Suelo, puertas y pasillos',
        priority: 4,
        estimatedMinutes: 15,
        difficulty: 1,
        instructions: [
          'Aspirar el suelo',
          'Limpiar las puertas',
          'Limpiar los interruptores'
        ],
        requiredMaterials: ['Aspiradora', 'Desinfectante', 'Paño'],
      ),
    ];
    _lastUpdated = DateTime.now();
  }

  /// Obtiene todas las áreas de limpieza (con cache)
  /// 
  /// Retorna la lista completa de áreas de limpieza. Si no hay datos
  /// en cache, inicializa con datos de ejemplo.
  /// 
  /// Retorna lista inmutable de áreas de limpieza
  List<CleaningArea> getAllCleaningAreas() {
    if (_cleaningAreas.isEmpty) {
      _initializeWithExampleData();
    }
    return List.unmodifiable(_cleaningAreas);
  }

  /// Carga áreas de limpieza desde la API
  /// 
  /// Obtiene el calendario de limpieza desde la API y convierte
  /// las zonas a CleaningArea. En caso de error, utiliza datos de ejemplo.
  /// 
  /// Retorna lista de áreas de limpieza cargadas
  Future<List<CleaningArea>> loadCleaningAreasFromAPI() async {
    try {
      // Obtener el calendario desde la API
      _calendarResponse = await _calendarService.getCleaningCalendar();
      
      if (_calendarResponse!.hasConfiguredZones && _calendarResponse!.zoneRotation.isNotEmpty) {
        // Convertir las zonas de la API a CleaningArea
        final apiAreas = _calendarService.convertZonesToCleaningAreas(_calendarResponse!.zoneRotation);
        _cleaningAreas = apiAreas.map((area) => area.toCleaningAreaImpl()).toList();
      } else {
        // Si no hay zonas configuradas, usar datos de ejemplo como fallback
        _initializeWithExampleData();
      }
      
      _lastUpdated = DateTime.now();
      return _cleaningAreas;
    } catch (e) {
      // En caso de error, usar datos de ejemplo
      _initializeWithExampleData();
      _calendarResponse = null;
      return _cleaningAreas;
    }
  }

  /// Verifica si el cache está expirado
  /// 
  /// Comprueba si han pasado más de [cacheDurationMinutes] desde
  /// la última actualización de los datos.
  bool get isCacheExpired {
    if (_lastUpdated == null) return true;
    return DateTime.now().difference(_lastUpdated!).inMinutes > cacheDurationMinutes;
  }

  /// Fuerza la actualización de áreas de limpieza
  /// 
  /// Recarga los datos desde la API, ignorando el cache.
  Future<void> refreshCleaningAreas() async {
    await loadCleaningAreasFromAPI();
  }

  /// Obtiene un área de limpieza por índice
  /// 
  /// [index] - Índice del área a obtener
  /// Retorna el área en el índice especificado o null si es inválido
  CleaningArea? getCleaningAreaByIndex(int index) {
    if (index >= 0 && index < _cleaningAreas.length) {
      return _cleaningAreas[index];
    }
    return null;
  }

  /// Obtiene un área de limpieza por ID
  /// 
  /// [id] - ID único del área a buscar
  /// Retorna el área con el ID especificado o null si no existe
  CleaningArea? getCleaningAreaById(String id) {
    try {
      return _cleaningAreas.firstWhere((area) => area.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene el número total de áreas de limpieza
  int getTotalAreas() {
    return _cleaningAreas.length;
  }

  /// Verifica si un índice es válido para las áreas de limpieza
  /// 
  /// [index] - Índice a validar
  /// Retorna true si el índice es válido, false en caso contrario
  bool isValidIndex(int index) {
    return index >= 0 && index < _cleaningAreas.length;
  }

  /// Obtiene el área de limpieza actual basada en el índice
  /// 
  /// [currentIndex] - Índice actual del área
  /// Retorna el área en el índice especificado o la primera como fallback
  CleaningArea getCurrentArea(int currentIndex) {
    if (isValidIndex(currentIndex)) {
      return _cleaningAreas[currentIndex];
    }
    return _cleaningAreas.first; // Fallback al primer área
  }

  /// Obtiene las áreas de limpieza que no están en el índice actual
  /// 
  /// [currentIndex] - Índice del área actual
  /// Retorna lista de todas las áreas excepto la actual
  List<CleaningArea> getOtherAreas(int currentIndex) {
    return _cleaningAreas
        .asMap()
        .entries
        .where((entry) => entry.key != currentIndex)
        .map((entry) => entry.value)
        .toList();
  }

  /// Obtiene el siguiente índice de área de limpieza (rotación circular)
  /// 
  /// [currentIndex] - Índice actual
  /// Retorna el siguiente índice en la secuencia circular
  int getNextAreaIndex(int currentIndex) {
    return (currentIndex + 1) % _cleaningAreas.length;
  }

  /// Obtiene el índice anterior de área de limpieza (rotación circular)
  /// 
  /// [currentIndex] - Índice actual
  /// Retorna el índice anterior en la secuencia circular
  int getPreviousAreaIndex(int currentIndex) {
    return (currentIndex - 1 + _cleaningAreas.length) % _cleaningAreas.length;
  }

  /// Inicializa el servicio cargando datos desde la API
  /// 
  /// Este método debe llamarse al inicializar la aplicación
  /// para cargar el calendario de limpieza actual.
  Future<void> initializeFromAPI() async {
    // Limpiar cache del memberId al inicializar
    clearMemberIdCache();
    // Inicializar el servicio de estado de zonas
    await _zonesStateService.initialize();
    await loadCleaningAreasFromAPI();
  }

  /// Verifica si las zonas han cambiado y actualiza el calendario si es necesario
  /// 
  /// Este método es optimizado y solo hace llamadas a la API cuando detecta cambios
  /// en las zonas de limpieza. Retorna true si se actualizó, false si no había cambios.
  Future<bool> checkAndUpdateIfNeeded() async {
    try {
      // Verificar si las zonas han cambiado
      final hasChanges = await _zonesStateService.checkForZonesChanges();
      
      if (hasChanges) {
        // Recargar el calendario desde la API
        await loadCleaningAreasFromAPI();
        
        // Marcar que las zonas han sido actualizadas
        await _zonesStateService.markZonesAsUpdated();
        
        return true; // Se actualizó
      } else {
        return false; // No se actualizó
      }
    } catch (e) {
      return false;
    }
  }

  /// Fuerza la actualización del calendario (ignora la detección de cambios)
  /// 
  /// Útil para casos donde se quiere forzar una actualización completa
  Future<void> forceUpdate() async {
    // Limpiar cache del memberId para forzar nueva consulta
    clearMemberIdCache();
    await loadCleaningAreasFromAPI();
    await _zonesStateService.markZonesAsUpdated();
  }

  /// Limpia el cache del memberId del usuario actual
  /// 
  /// Útil cuando cambia el usuario o se necesita forzar una nueva consulta
  void clearMemberIdCache() {
    _cachedMemberId = null;
    _memberIdCacheTime = null;
  }

  /// Obtiene la respuesta completa del calendario
  /// 
  /// Retorna la respuesta del calendario de la API o null si no está cargada
  CleaningCalendarResponse? getCalendarResponse() {
    return _calendarResponse;
  }

  /// Verifica si el servicio está usando datos de la API
  /// 
  /// Retorna true si los datos vienen de la API, false si son de ejemplo
  bool get isUsingAPIData {
    return _calendarResponse != null && _calendarResponse!.hasConfiguredZones;
  }

  /// Obtiene el memberId del usuario actual desde la API de miembros
  /// 
  /// Retorna el memberId del usuario actual o null si no se encuentra
  /// Usa cache para evitar llamadas repetidas a la API
  Future<String?> getCurrentMemberId() async {
    // Verificar cache
    if (_cachedMemberId != null && 
        _memberIdCacheTime != null &&
        DateTime.now().difference(_memberIdCacheTime!).inMinutes < memberIdCacheMinutes) {
      return _cachedMemberId;
    }

    try {
      // Usar el mismo servicio que ya funciona para asignaciones
      final members = await HouseMemberService.getHouseMembers();
      
      // Buscar el miembro que es el usuario actual
      final currentMember = members.firstWhere(
        (member) => member.isCurrentUser,
        orElse: () => throw StateError('Usuario actual no encontrado'),
      );
      
      // Cachear el resultado
      _cachedMemberId = currentMember.id;
      _memberIdCacheTime = DateTime.now();
      
      return _cachedMemberId;
    } catch (e) {
      return null;
    }
  }

  /// Filtra las zonas según las asignaciones y exclusiones del usuario actual
  /// 
  /// Retorna una lista de zonas que el usuario puede ver (no está excluido)
  /// y que están ordenadas según su asignación
  Future<List<CleaningArea>> getFilteredAndOrderedAreas() async {
    if (!isUsingAPIData || _calendarResponse == null) {
      // Si no hay datos de API, retornar todas las áreas sin filtro
      return _cleaningAreas;
    }

    final currentMemberId = await getCurrentMemberId();
    if (currentMemberId == null) {
      // Si no hay usuario autenticado, retornar todas las áreas
      return _cleaningAreas;
    }

    // Filtrar zonas donde el usuario NO está excluido
    final filteredZones = _calendarResponse!.zoneRotation.where((zone) {
      return !zone.excludeUsers.any((user) => user.memberId == currentMemberId);
    }).toList();

    // Ordenar por posición en la rotación
    filteredZones.sort((a, b) => a.positionInRotation.compareTo(b.positionInRotation));

    // Convertir a CleaningArea
    final apiAreas = _calendarService.convertZonesToCleaningAreas(filteredZones);
    return apiAreas.map((area) => area.toCleaningAreaImpl()).toList();
  }

  /// Obtiene el área actual asignada al usuario (si está asignado a alguna)
  /// 
  /// Retorna el área asignada al usuario o null si no está asignado a ninguna
  Future<CleaningArea?> getCurrentUserAssignedArea() async {
    if (!isUsingAPIData || _calendarResponse == null) {
      return null;
    }

    final currentMemberId = await getCurrentMemberId();
    if (currentMemberId == null) {
      return null;
    }

    // Buscar la zona donde el usuario está asignado
    final assignedZone = _calendarResponse!.zoneRotation.firstWhere(
      (zone) => zone.assignedUsers.any((user) => user.memberId == currentMemberId),
      orElse: () => throw StateError('No assigned zone found'),
    );

    // Convertir a CleaningArea
    final apiArea = _calendarService.convertZonesToCleaningAreas([assignedZone]).first;
    return apiArea.toCleaningAreaImpl();
  }

  /// Obtiene las áreas que NO están asignadas al usuario actual, ordenadas por prioridad
  /// 
  /// Retorna lista de áreas ordenadas según la secuencia de rotación desde la zona asignada
  Future<List<CleaningArea>> getOtherAreasForUser() async {
    if (!isUsingAPIData || _calendarResponse == null) {
      // Si no hay datos de API, usar la lógica original
      return _cleaningAreas.skip(1).toList();
    }

    final currentMemberId = await getCurrentMemberId();
    if (currentMemberId == null) {
      return _cleaningAreas.skip(1).toList();
    }

    // Obtener todas las zonas filtradas (sin exclusiones)
    final filteredZones = _calendarResponse!.zoneRotation.where((zone) {
      return !zone.excludeUsers.any((user) => user.memberId == currentMemberId);
    }).toList();

    // Ordenar todas las zonas por posición en la rotación
    filteredZones.sort((a, b) => a.positionInRotation.compareTo(b.positionInRotation));

    // Buscar la zona asignada al usuario
    final assignedZone = filteredZones.firstWhere(
      (zone) => zone.assignedUsers.any((user) => user.memberId == currentMemberId),
      orElse: () => throw StateError('No assigned zone found'),
    );

    // Crear la secuencia de rotación desde la zona asignada
    final otherZones = <CleaningZoneRotationResponse>[];
    
    // Encontrar el índice de la zona asignada en la lista ordenada
    final assignedIndex = filteredZones.indexOf(assignedZone);
    
    // Agregar las zonas que vienen después de la asignada
    for (int i = assignedIndex + 1; i < filteredZones.length; i++) {
      otherZones.add(filteredZones[i]);
    }
    
    // Agregar las zonas que vienen antes de la asignada (para completar el ciclo)
    for (int i = 0; i < assignedIndex; i++) {
      otherZones.add(filteredZones[i]);
    }

    // Convertir a CleaningArea
    final apiAreas = _calendarService.convertZonesToCleaningAreas(otherZones);
    return apiAreas.map((area) => area.toCleaningAreaImpl()).toList();
  }

  /// Obtiene el índice de la zona asignada al usuario actual
  /// 
  /// Retorna el índice de la zona asignada o 0 si no está asignado
  Future<int> getCurrentUserAssignedAreaIndex() async {
    if (!isUsingAPIData || _calendarResponse == null) {
      return 0;
    }

    final currentMemberId = await getCurrentMemberId();
    if (currentMemberId == null) {
      return 0;
    }

    // Buscar el índice de la zona asignada al usuario
    for (int i = 0; i < _calendarResponse!.zoneRotation.length; i++) {
      final zone = _calendarResponse!.zoneRotation[i];
      if (zone.assignedUsers.any((user) => user.memberId == currentMemberId)) {
        return i;
      }
    }

    return 0; // Fallback si no se encuentra
  }
}
