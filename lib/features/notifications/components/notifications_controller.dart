/// Controlador de la feature de notificaciones
/// 
/// Orquesta la navegación, acciones de UI y manejo de estado
/// para la funcionalidad de notificaciones.

import 'package:flutter/material.dart';
import '../interfaces/notifications_interfaces.dart';
import '../../../exports.dart';

/// Controlador principal de notificaciones
class NotificationsController {
  final INotificationsService _service;
  NotificationsState _state = NotificationsState.idle;
  List<NotificationEntity> _notifications = [];
  String? _error;

  NotificationsController({required INotificationsService service}) 
      : _service = service;

  /// Estado actual del controlador
  NotificationsState get state => _state;

  /// Lista de notificaciones actual
  List<NotificationEntity> get notifications => List.unmodifiable(_notifications);

  /// Mensaje de error actual
  String? get error => _error;

  /// Número de notificaciones no leídas
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Número total de notificaciones
  int get totalCount => _notifications.length;

  /// Carga inicial de notificaciones
  Future<void> loadNotifications() async {
    _setState(NotificationsState.loading);
    
    try {
      final notifications = await _service.getNotifications();
      _notifications = notifications;
      _error = null;
      _setState(NotificationsState.loaded);
    } catch (e) {
      _error = e.toString();
      _setState(NotificationsState.error);
    }
  }

  /// Marca una notificación como leída
  Future<void> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);
      
      // Actualizar estado local
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }
    } catch (e) {
      _error = e.toString();
      _setState(NotificationsState.error);
    }
  }

  /// Marca todas las notificaciones como leídas
  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      
      // Actualizar estado local
      _notifications = _notifications.map((notification) {
        return notification.copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      _error = e.toString();
      _setState(NotificationsState.error);
    }
  }

  /// Elimina una notificación
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _service.deleteNotification(notificationId);
      
      // Actualizar estado local
      _notifications.removeWhere((n) => n.id == notificationId);
    } catch (e) {
      _error = e.toString();
      _setState(NotificationsState.error);
    }
  }

  /// Elimina todas las notificaciones
  Future<void> deleteAllNotifications() async {
    try {
      await _service.deleteAllNotifications();
      
      // Limpiar estado local
      _notifications.clear();
    } catch (e) {
      _error = e.toString();
      _setState(NotificationsState.error);
    }
  }

  /// Refresca las notificaciones
  Future<void> refreshNotifications() async {
    _setState(NotificationsState.updating);
    
    try {
      final notifications = await _service.getNotifications();
      _notifications = notifications;
      _error = null;
      _setState(NotificationsState.loaded);
    } catch (e) {
      _error = e.toString();
      _setState(NotificationsState.error);
    }
  }

  /// Navega a la configuración de notificaciones
  void navigateToNotificationsConfig(BuildContext context) {
    // TODO: Implementar navegación a configuración
    context.showInfoSnackBar('Configuración de notificaciones - Próximamente');
  }

  /// Muestra diálogo de confirmación para eliminar todas las notificaciones
  Future<bool> showDeleteAllConfirmDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar todas las notificaciones'),
          content: const Text(
            '¿Estás seguro de que quieres eliminar todas las notificaciones? '
            'Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Muestra diálogo de confirmación para marcar todas como leídas
  Future<bool> showMarkAllReadConfirmDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Marcar todas como leídas'),
          content: const Text(
            '¿Quieres marcar todas las notificaciones como leídas?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Marcar'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Obtiene notificaciones por tipo
  List<NotificationEntity> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Obtiene notificaciones no leídas
  List<NotificationEntity> get unreadNotifications {
    return _notifications.where((n) => !n.isRead).toList();
  }

  /// Obtiene notificaciones leídas
  List<NotificationEntity> get readNotifications {
    return _notifications.where((n) => n.isRead).toList();
  }

  /// Verifica si hay notificaciones
  bool get hasNotifications => _notifications.isNotEmpty;

  /// Verifica si hay notificaciones no leídas
  bool get hasUnreadNotifications => unreadCount > 0;

  /// Obtiene la notificación más reciente
  NotificationEntity? get latestNotification {
    if (_notifications.isEmpty) return null;
    
    _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _notifications.first;
  }

  /// Obtiene notificaciones importantes
  List<NotificationEntity> get importantNotifications {
    return _notifications.where((n) => n.isImportant).toList();
  }

  /// Actualiza el estado interno
  void _setState(NotificationsState newState) {
    _state = newState;
  }

  /// Limpia el estado del controlador
  void dispose() {
    _notifications.clear();
    _error = null;
    _state = NotificationsState.idle;
  }
}

/// Widget que construye la UI basada en el estado del controlador
class NotificationsView extends StatelessWidget {
  final NotificationsController controller;

  const NotificationsView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    switch (controller.state) {
      case NotificationsState.idle:
        return const StandardLoadingIndicator(
          message: 'Preparando notificaciones...',
        );
        
      case NotificationsState.loading:
        return const StandardLoadingIndicator(
          message: 'Cargando notificaciones...',
        );
        
      case NotificationsState.loaded:
        return _buildLoadedView(context);
        
      case NotificationsState.error:
        return StandardErrorWidget(
          message: controller.error ?? 'Error desconocido',
          onRetry: () => controller.loadNotifications(),
        );
        
      case NotificationsState.updating:
        return _buildLoadedView(context, isUpdating: true);
    }
  }

  /// Construye la vista cuando las notificaciones están cargadas
  Widget _buildLoadedView(BuildContext context, {bool isUpdating = false}) {
    if (controller.notifications.isEmpty) {
      return _buildEmptyView(context);
    }

    return Stack(
      children: [
        ListView.builder(
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return _buildNotificationItem(context, notification);
          },
        ),
        if (isUpdating)
          const Positioned(
            top: 16,
            right: 16,
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  /// Construye la vista cuando no hay notificaciones
  Widget _buildEmptyView(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No tienes notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Te notificaremos cuando tengas algo nuevo',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Construye un elemento de notificación
  Widget _buildNotificationItem(BuildContext context, NotificationEntity notification) {
    return StandardCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () => _onNotificationTap(context, notification),
      child: Row(
        children: [
          // Icono de tipo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getTypeColor(notification.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getTypeIcon(notification.type),
              color: _getTypeColor(notification.type),
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
                    color: notification.isRead ? Colors.grey[600] : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  notification.createdAt.formattedDateTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          // Indicador de no leída
          if (!notification.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  /// Maneja el tap en una notificación
  void _onNotificationTap(BuildContext context, NotificationEntity notification) {
    if (!notification.isRead) {
      controller.markAsRead(notification.id);
    }
    
    // TODO: Implementar navegación específica según el tipo de notificación
    context.showInfoSnackBar('Notificación: ${notification.title}');
  }

  /// Obtiene el color del tipo de notificación
  Color _getTypeColor(String type) {
    switch (type) {
      case 'important':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      case 'system':
        return Colors.purple;
      case 'cleaning':
        return Colors.green;
      case 'chat':
        return Colors.cyan;
      default:
        return Colors.blue;
    }
  }

  /// Obtiene el icono del tipo de notificación
  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'important':
        return Icons.warning_rounded;
      case 'urgent':
        return Icons.error_rounded;
      case 'system':
        return Icons.settings_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'chat':
        return Icons.chat_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}
