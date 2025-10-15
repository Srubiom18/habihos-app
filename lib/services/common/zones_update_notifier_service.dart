import 'dart:async';

/// Servicio para notificar cuando las zonas de limpieza han sido modificadas
/// 
/// Proporciona un mecanismo simple y confiable para que la pantalla home
/// sepa cuándo debe actualizar el calendario después de cambios en las zonas.
class ZonesUpdateNotifierService {
  static final ZonesUpdateNotifierService _instance = ZonesUpdateNotifierService._internal();
  factory ZonesUpdateNotifierService() => _instance;
  ZonesUpdateNotifierService._internal();

  /// Stream controller para notificar cambios
  final StreamController<bool> _updateController = StreamController<bool>.broadcast();

  /// Stream que emite cuando hay cambios en las zonas
  Stream<bool> get onZonesUpdated => _updateController.stream;

  /// Indica si hay cambios pendientes de procesar
  bool _hasPendingUpdates = false;

  /// Obtiene si hay actualizaciones pendientes
  bool get hasPendingUpdates => _hasPendingUpdates;

  /// Notifica que las zonas han sido modificadas
  /// 
  /// Este método debe llamarse cuando se crea, modifica o elimina una zona
  void notifyZonesChanged() {
    _hasPendingUpdates = true;
    _updateController.add(true);
  }

  /// Marca que las actualizaciones han sido procesadas
  /// 
  /// Este método debe llamarse después de que la home haya actualizado el calendario
  void markUpdatesAsProcessed() {
    _hasPendingUpdates = false;
  }

  /// Fuerza una verificación (útil para casos especiales)
  void forceCheck() {
    if (_hasPendingUpdates) {
      _updateController.add(true);
    }
  }

  /// Limpia el estado (útil para logout o reset)
  void clear() {
    _hasPendingUpdates = false;
    _updateController.add(false);
  }

  /// Libera los recursos del servicio
  void dispose() {
    _updateController.close();
  }
}
