import 'package:flutter/material.dart';
import '../../../constants/ui_constants.dart';
import '../../../models/api_models.dart';
import '../controllers/zonas_comunes_controller.dart';
export 'rotation_duration_widget.dart';
export 'user_assignment_dialog.dart';

/// Widget que muestra la información del calendario de limpieza
class CalendarInfoWidget extends StatelessWidget {
  final ZonasComunesController controller;

  const CalendarInfoWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final zonasActivas = controller.zonasActivas;
    final proximaLimpieza = controller.getProximaLimpieza();
    
    return Container(
      margin: const EdgeInsets.all(UIConstants.screenPadding),
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [UIConstants.primaryColor, UIConstants.primaryColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                ),
                child: const Icon(
                  Icons.cleaning_services_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: UIConstants.spacingLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calendario de Limpieza',
                      style: TextStyle(
                        fontSize: UIConstants.textSizeLarge,
                        fontWeight: FontWeight.w600,
                        color: UIConstants.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$zonasActivas zonas activas • Próxima: $proximaLimpieza',
                      style: TextStyle(
                        fontSize: UIConstants.textSizeSmall,
                        color: UIConstants.textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingMedium),
          Container(
            padding: const EdgeInsets.all(UIConstants.spacingMedium),
            decoration: BoxDecoration(
              color: UIConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
            ),
            child: Text(
              'Una vez que crees una zona común, podrás asignar usuarios específicos a cada zona para organizar las tareas de limpieza.',
              style: TextStyle(
                fontSize: UIConstants.textSizeSmall,
                color: UIConstants.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget que muestra una tarjeta de zona común (versión simplificada)
class ZonaComunCard extends StatelessWidget {
  final CleaningAreaResponse? zonaComun;
  final CleaningZoneRotationResponse? calendarZone;
  final List<AssignedUserInfo> assignedUsers;
  final List<AssignedUserInfo> excludeUsers; // ✅ NUEVO: Usuarios excluidos
  final bool isCurrent;
  final ZonasComunesController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ZonaComunCard({
    super.key,
    this.zonaComun,
    this.calendarZone,
    this.assignedUsers = const [],
    this.excludeUsers = const [], // ✅ NUEVO: Usuarios excluidos
    this.isCurrent = false,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isUsingCalendar = calendarZone != null;
    final name = isUsingCalendar ? calendarZone!.cleaningAreaName : zonaComun!.name;
    final description = isUsingCalendar ? calendarZone!.cleaningAreaDescription : zonaComun!.description;
    final color = isUsingCalendar ? calendarZone!.cleaningAreaColor : zonaComun!.color;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        // Destacar si es la zona actual
        border: isCurrent ? Border.all(
          color: UIConstants.primaryColor,
          width: 2,
        ) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con icono, nombre y botones
            Row(
              children: [
                // Icono de la zona
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: controller.parseColor(color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                    border: Border.all(
                      color: controller.parseColor(color).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    controller.getZonaIcon(name),
                    color: controller.parseColor(color),
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: UIConstants.spacingLarge),
                
                // Nombre de la zona
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: UIConstants.textSizeMedium,
                          fontWeight: FontWeight.w600,
                          color: UIConstants.textColor,
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: UIConstants.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ACTUAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: UIConstants.primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Botones de acción
                Row(
                  children: [
                    // Botón de editar
                    Container(
                      decoration: BoxDecoration(
                        color: UIConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: UIConstants.primaryColor,
                          size: 20,
                        ),
                        onPressed: onEdit,
                        tooltip: 'Editar zona',
                      ),
                    ),
                    
                    const SizedBox(width: UIConstants.spacingSmall),
                    
                    // Botón de eliminar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: onDelete,
                        tooltip: 'Eliminar zona',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: UIConstants.spacingMedium),
            
            // ✅ NUEVO: Avatares de usuarios asignados y excluidos lado a lado
            _buildUserAvatarsSection(),
            
            const SizedBox(height: UIConstants.spacingLarge),
            
            // ✅ NUEVO: Sección separada para la descripción
            _buildDescriptionSection(description),
          ],
        ),
      ),
    );
  }

  /// ✅ NUEVO: Construye la sección de avatares con usuarios asignados y excluidos
  Widget _buildUserAvatarsSection() {
    return Row(
      children: [
        // Usuarios asignados (lado izquierdo) - con margen
        Expanded(
          child: _buildAssignedUsersAvatars(),
        ),
        
        // Margen antes de la línea divisoria
        const SizedBox(width: UIConstants.spacingMedium),
        
        // Separador siempre visible
        Container(
          width: 1,
          height: 60, // Altura fija para mantener consistencia
          color: Colors.grey[300],
        ),
        
        // Margen después de la línea divisoria
        const SizedBox(width: UIConstants.spacingMedium),
        
        // Usuarios excluidos (lado derecho) - siempre visible
        Expanded(
          child: _buildExcludedUsersAvatars(),
        ),
      ],
    );
  }

  /// Construye los avatares de usuarios asignados
  Widget _buildAssignedUsersAvatars() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: UIConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: UIConstants.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'Asignados',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: UIConstants.primaryColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          
          // Avatares
          assignedUsers.isNotEmpty
              ? _buildAvatarRow(assignedUsers, UIConstants.primaryColor, false)
              : _buildEmptyAvatar(),
        ],
      ),
    );
  }

  /// Construye los avatares de usuarios excluidos
  Widget _buildExcludedUsersAvatars() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end, // Alineado a la derecha
        children: [
          // Título
          Text(
            'Excluidos',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.red.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          
          // Avatares
          excludeUsers.isNotEmpty
              ? _buildAvatarRow(excludeUsers, Colors.red, true)
              : _buildExampleExcludedAvatar(), // Avatar de ejemplo
        ],
      ),
    );
  }

  /// Construye una fila de avatares
  Widget _buildAvatarRow(List<AssignedUserInfo> users, Color color, bool isExcluded) {
    final avatarWidgets = <Widget>[];
    
    // Agregar avatares de usuarios (máximo 3 para excluidos, 5 para asignados)
    final maxUsers = isExcluded ? 3 : 5;
    for (var user in users.take(maxUsers)) {
      avatarWidgets.add(
        Tooltip(
          message: user.memberName,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                user.userInitials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    // Agregar indicador de más usuarios si hay más del máximo
    if (users.length > maxUsers) {
      avatarWidgets.add(
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '+${users.length - maxUsers}',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
    
    // Alinear los avatares según el tipo
    if (isExcluded) {
      return Align(
        alignment: Alignment.centerRight, // Alineado a la derecha
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: avatarWidgets,
        ),
      );
    }
    
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: avatarWidgets,
    );
  }

  /// Construye un avatar de ejemplo para usuarios excluidos
  Widget _buildExampleExcludedAvatar() {
    return Align(
      alignment: Alignment.centerRight, // Alineado a la derecha
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[400],
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: Icon(
          Icons.person_off_outlined,
          size: 14,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  /// Construye un avatar vacío cuando no hay usuarios
  Widget _buildEmptyAvatar() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Icon(
        Icons.person_outline,
        size: 14,
        color: Colors.grey[600],
      ),
    );
  }

  /// ✅ NUEVO: Construye la sección de descripción con su propio espacio
  Widget _buildDescriptionSection(String description) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingMedium,
        vertical: UIConstants.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icono de descripción
          Icon(
            Icons.description_outlined,
            size: 16,
            color: UIConstants.textColor.withOpacity(0.5),
          ),
          const SizedBox(width: UIConstants.spacingSmall),
          
          // Texto de descripción
          Expanded(
            child: Text(
              description.isNotEmpty ? description : 'Sin descripción',
              style: TextStyle(
                fontSize: UIConstants.textSizeSmall,
                color: UIConstants.textColor.withOpacity(0.7),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de carga
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

/// Widget de error para zonas comunes
class ZonasComunesErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ZonasComunesErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.6),
          ),
          const SizedBox(height: UIConstants.spacingLarge),
          Text(
            'Error',
            style: TextStyle(
              fontSize: UIConstants.textSizeLarge,
              fontWeight: FontWeight.w600,
              color: UIConstants.textColor,
            ),
          ),
          const SizedBox(height: UIConstants.spacingSmall),
          Text(
            message,
            style: TextStyle(
              fontSize: UIConstants.textSizeSmall,
              color: UIConstants.textColor.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: UIConstants.spacingLarge),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget para seleccionar duración de rotación
class RotationDurationWidget extends StatelessWidget {
  final RotationDurationType selectedType;
  final int customDays;
  final Function(RotationDurationType) onTypeChanged;
  final Function(int) onCustomDaysChanged;

  const RotationDurationWidget({
    super.key,
    required this.selectedType,
    required this.customDays,
    required this.onTypeChanged,
    required this.onCustomDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duración de la rotación',
          style: TextStyle(
            fontSize: UIConstants.textSizeMedium,
            fontWeight: FontWeight.w600,
            color: UIConstants.textColor,
          ),
        ),
        const SizedBox(height: UIConstants.spacingMedium),
        ...RotationDurationType.values.map((type) {
          return RadioListTile<RotationDurationType>(
            title: Text(_getTypeLabel(type)),
            subtitle: type == RotationDurationType.custom 
                ? Text('Cada $customDays días')
                : null,
            value: type,
            groupValue: selectedType,
            onChanged: (value) {
              if (value != null) {
                onTypeChanged(value);
              }
            },
          );
        }).toList(),
        if (selectedType == RotationDurationType.custom) ...[
          const SizedBox(height: UIConstants.spacingMedium),
          TextFormField(
            initialValue: customDays.toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Días personalizados',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final days = int.tryParse(value);
              if (days != null && days > 0) {
                onCustomDaysChanged(days);
              }
            },
          ),
        ],
      ],
    );
  }

  String _getTypeLabel(RotationDurationType type) {
    switch (type) {
      case RotationDurationType.daily:
        return 'Diaria';
      case RotationDurationType.weekly:
        return 'Semanal';
      case RotationDurationType.monthly:
        return 'Mensual';
      case RotationDurationType.custom:
        return 'Personalizada';
    }
  }
}

/// Enum para tipos de duración de rotación
enum RotationDurationType {
  daily,
  weekly,
  monthly,
  custom,
}
