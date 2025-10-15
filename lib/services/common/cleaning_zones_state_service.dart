import 'package:shared_preferences/shared_preferences.dart';
import '../cleaning_area_service.dart';
import '../../models/api_models.dart';

/// Servicio para gestionar el estado de las zonas de limpieza
/// 
/// Detecta cambios en las zonas de limpieza y optimiza las actualizaciones
/// del calendario para evitar llamadas innecesarias a la API.
class CleaningZonesStateService {
  static final CleaningZonesStateService _instance = CleaningZonesStateService._internal();
  factory CleaningZonesStateService() => _instance;
  CleaningZonesStateService._internal();

  static const String _zonesHashKey = 'cleaning_zones_hash';
  static const String _lastUpdateKey = 'cleaning_zones_last_update';

  /// Hash de las zonas actuales para detectar cambios
  String? _currentZonesHash;

  /// Timestamp de la última actualización
  DateTime? _lastUpdate;

  /// Indica si las zonas han cambiado desde la última verificación
  bool _hasZonesChanged = false;

  /// Obtiene el estado de si las zonas han cambiado
  bool get hasZonesChanged => _hasZonesChanged;

  /// Obtiene el timestamp de la última actualización
  DateTime? get lastUpdate => _lastUpdate;

  /// Inicializa el servicio cargando el estado guardado
  Future<void> initialize() async {
    await _loadSavedState();
  }

  /// Carga el estado guardado desde SharedPreferences
  Future<void> _loadSavedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentZonesHash = prefs.getString(_zonesHashKey);
      
      final lastUpdateString = prefs.getString(_lastUpdateKey);
      if (lastUpdateString != null) {
        _lastUpdate = DateTime.parse(lastUpdateString);
      }
    } catch (e) {
      // Error silencioso
    }
  }

  /// Guarda el estado actual en SharedPreferences
  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_currentZonesHash != null) {
        await prefs.setString(_zonesHashKey, _currentZonesHash!);
      }
      
      if (_lastUpdate != null) {
        await prefs.setString(_lastUpdateKey, _lastUpdate!.toIso8601String());
      }
    } catch (e) {
      // Error silencioso
    }
  }

  /// Genera un hash único basado en las zonas de limpieza
  String _generateZonesHash(List<CleaningAreaResponse> zones) {
    // Crear una representación string de las zonas para el hash
    final zonesData = zones.map((zone) => '${zone.id}:${zone.name}:${zone.updatedAt.millisecondsSinceEpoch}').join('|');
    
    // Generar un hash simple basado en el contenido
    return zonesData.hashCode.toString();
  }

  /// Verifica si las zonas han cambiado comparando con el estado guardado
  /// 
  /// Retorna true si hay cambios, false si no hay cambios
  Future<bool> checkForZonesChanges() async {
    try {
      // Obtener las zonas actuales desde la API
      final currentZones = await CleaningAreaService.getCleaningAreas();
      
      // Generar hash de las zonas actuales
      final newHash = _generateZonesHash(currentZones);
      
      // Comparar con el hash guardado
      if (_currentZonesHash == null || _currentZonesHash != newHash) {
        // Hay cambios
        _currentZonesHash = newHash;
        _lastUpdate = DateTime.now();
        _hasZonesChanged = true;
        
        // Guardar el nuevo estado
        await _saveState();
        
        return true;
      } else {
        // No hay cambios
        _hasZonesChanged = false;
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Marca que las zonas han sido actualizadas (después de actualizar el calendario)
  Future<void> markZonesAsUpdated() async {
    _hasZonesChanged = false;
    _lastUpdate = DateTime.now();
    await _saveState();
  }

  /// Fuerza la verificación de cambios (útil para testing o casos especiales)
  Future<void> forceCheckForChanges() async {
    _currentZonesHash = null;
    await checkForZonesChanges();
  }

  /// Obtiene información del estado actual para debugging
  Map<String, dynamic> getStateInfo() {
    return {
      'currentHash': _currentZonesHash,
      'lastUpdate': _lastUpdate?.toIso8601String(),
      'hasZonesChanged': _hasZonesChanged,
    };
  }

  /// Limpia el estado guardado (útil para logout o reset)
  Future<void> clearState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_zonesHashKey);
      await prefs.remove(_lastUpdateKey);
      
      _currentZonesHash = null;
      _lastUpdate = null;
      _hasZonesChanged = false;
    } catch (e) {
      // Error silencioso
    }
  }
}
