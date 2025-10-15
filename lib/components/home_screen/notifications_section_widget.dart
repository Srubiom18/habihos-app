import 'package:flutter/material.dart';
import '../../interfaces/home_screen/notification.dart' as app_notification;
import '../../constants/ui_constants.dart';

/// Widget que muestra la sección completa de notificaciones
class NotificationsSectionWidget extends StatelessWidget {
  final List<app_notification.NotificationImpl> notifications;

  const NotificationsSectionWidget({
    super.key,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: UIConstants.spacingLarge),
        _buildNotificationsList(),
      ],
    );
  }

  /// Construye el encabezado de la sección
  Widget _buildSectionHeader() {
    return Row(
      children: [
        Icon(Icons.notifications_active, color: Colors.blue[600], size: 18),
        const SizedBox(width: UIConstants.spacingMedium),
        Text(
          'Notificaciones',
          style: TextStyle(
            fontSize: UIConstants.textSizeMedium,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const Spacer(),
        _buildNotificationCount(),
      ],
    );
  }

  /// Construye el contador de notificaciones
  Widget _buildNotificationCount() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingMedium,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
      ),
      child: Text(
        '${notifications.length} mensajes',
        style: TextStyle(
          fontSize: UIConstants.textSizeXXSmall,
          color: Colors.blue[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Construye la lista de notificaciones
  Widget _buildNotificationsList() {
    return Column(
      children: notifications
          .map((notification) => Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.spacingMedium),
                child: NotificationCardWidget(notification: notification),
              ))
          .toList(),
    );
  }
}

/// Widget individual para cada tarjeta de notificación
class NotificationCardWidget extends StatelessWidget {
  final app_notification.NotificationImpl notification;

  const NotificationCardWidget({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: UIConstants.notificationContainerPadding,
      decoration: BoxDecoration(
        color: notification.displayColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        border: Border.all(
          color: notification.displayColor.withOpacity(0.3),
          width: notification.priority.value == 4 ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          _buildNotificationIcon(),
          const SizedBox(width: UIConstants.spacingLarge),
          Expanded(
            child: _buildNotificationContent(),
          ),
        ],
      ),
    );
  }

  /// Construye el icono de la notificación
  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(UIConstants.spacingMedium),
          decoration: BoxDecoration(
            color: notification.displayColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            notification.displayIcon,
            color: Colors.white,
            size: UIConstants.iconSizeMedium,
          ),
        ),
        if (notification.priority.value == 4) _buildUrgentIndicator(),
      ],
    );
  }

  /// Construye el indicador de urgencia
  Widget _buildUrgentIndicator() {
    return Positioned(
      right: 0,
      top: 0,
      child: Container(
        width: UIConstants.indicatorIconSize,
        height: UIConstants.indicatorIconSize,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.priority_high,
          size: UIConstants.priorityIconSize,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Construye el contenido de la notificación
  Widget _buildNotificationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNotificationHeader(),
        const SizedBox(height: UIConstants.spacingSmall),
        _buildNotificationMessage(),
      ],
    );
  }

  /// Construye el encabezado de la notificación
  Widget _buildNotificationHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            notification.title,
            style: TextStyle(
              fontSize: UIConstants.textSizeNormal,
              fontWeight: FontWeight.bold,
              color: notification.displayColor,
            ),
          ),
        ),
        if (notification.priority.value == 4) _buildUrgentLabel(),
        const SizedBox(width: UIConstants.spacingMedium),
        _buildNotificationTime(),
      ],
    );
  }

  /// Construye la etiqueta de urgente
  Widget _buildUrgentLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(UIConstants.spacingMedium),
      ),
      child: const Text(
        'URGENTE',
        style: TextStyle(
          fontSize: UIConstants.textSizeLabel,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Construye el tiempo de la notificación
  Widget _buildNotificationTime() {
    return Text(
      notification.timeAgo,
      style: TextStyle(
        fontSize: UIConstants.textSizeXXSmall,
        color: Colors.grey[500],
      ),
    );
  }

  /// Construye el mensaje de la notificación
  Widget _buildNotificationMessage() {
    return Text(
      notification.message,
      style: TextStyle(
        fontSize: UIConstants.textSizeSmall,
        color: Colors.grey[700],
        height: 1.3,
      ),
    );
  }
}
