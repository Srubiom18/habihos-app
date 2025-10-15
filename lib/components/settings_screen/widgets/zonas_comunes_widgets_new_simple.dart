import 'package:flutter/material.dart';
import '../../../constants/ui_constants.dart';
import '../../../models/api_models.dart';
import '../controllers/zonas_comunes_controller.dart';
import 'user_assignment_dialog.dart';

/// Widget que muestra una tarjeta de zona común
class ZonaComunCard extends StatefulWidget {
  final CleaningAreaResponse? zonaComun;
  final CleaningZoneRotationResponse? calendarZone;
  final List<AssignedUserInfo> assignedUsers;
  final bool isCurrent;
  final ZonasComunesController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ZonaComunCard({
    super.key,
    this.zonaComun,
    this.calendarZone,
    this.assignedUsers = const [],
    this.isCurrent = false,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ZonaComunCard> createState() => _ZonaComunCardState();
}

class _ZonaComunCardState extends State<ZonaComunCard> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _isEditing ? null : 200, // Altura fija solo cuando no está editando
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
        border: widget.isCurrent ? Border.all(
          color: UIConstants.primaryColor,
          width: 2,
        ) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingLarge),
        child: _isEditing ? _buildEditingContent() : _buildBasicContent(),
      ),
    );
  }

  /// Construye el contenido básico de la card (solo información esencial)
  Widget _buildBasicContent() {
    final isUsingCalendar = widget.calendarZone != null;
    final name = isUsingCalendar ? widget.calendarZone!.cleaningAreaName : widget.zonaComun!.name;
    final description = isUsingCalendar ? widget.calendarZone!.cleaningAreaDescription : widget.zonaComun!.description;
    final color = isUsingCalendar ? widget.calendarZone!.cleaningAreaColor : widget.zonaComun!.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con icono, nombre y botones
        Row(
          children: [
            // Icono de la zona
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.controller.parseColor(color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                border: Border.all(
                  color: widget.controller.parseColor(color).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                widget.controller.getZonaIcon(name),
                color: widget.controller.parseColor(color),
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
                  if (widget.isCurrent)
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
                    onPressed: () => setState(() => _isEditing = true),
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
                    onPressed: widget.onDelete,
                    tooltip: 'Eliminar zona',
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: UIConstants.spacingMedium),
        
        // Avatares compactos de usuarios asignados
        _buildCompactUserAvatars(),
        
        const SizedBox(height: UIConstants.spacingSmall),
        
        // Descripción con degradado condicional
        LayoutBuilder(
          builder: (context, constraints) {
            final textSpan = TextSpan(
              text: description.isNotEmpty ? description : 'Sin descripción',
              style: TextStyle(
                fontSize: UIConstants.textSizeSmall,
                color: UIConstants.textColor.withOpacity(0.6),
              ),
            );
            final textPainter = TextPainter(
              text: textSpan,
              maxLines: 1,
              textDirection: TextDirection.ltr,
            );
            textPainter.layout(maxWidth: double.infinity);
            
            // Verificar si el texto es más ancho que el contenedor
            final needsGradient = textPainter.width > constraints.maxWidth;
            
            return SizedBox(
              height: 20,
              child: Stack(
                children: [
                  // Texto de descripción
                  Text(
                    description.isNotEmpty ? description : 'Sin descripción',
                    style: TextStyle(
                      fontSize: UIConstants.textSizeSmall,
                      color: UIConstants.textColor.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                  // Degradado solo si el texto es largo
                  if (needsGradient)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white,
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Construye los avatares compactos de usuarios asignados
  Widget _buildCompactUserAvatars() {
    // Si hay usuarios asignados, mostrar sus avatares
    if (widget.assignedUsers.isNotEmpty) {
      final avatarWidgets = <Widget>[];
      
      // Agregar avatares de usuarios (máximo 5)
      for (var user in widget.assignedUsers.take(5)) {
        avatarWidgets.add(
          Tooltip(
            message: user.memberName,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: UIConstants.primaryColor,
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
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }
      
      // Agregar indicador de más usuarios si hay más de 5
      if (widget.assignedUsers.length > 5) {
        avatarWidgets.add(
          Container(
            width: 32,
            height: 32,
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
                '+${widget.assignedUsers.length - 5}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }
      
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: avatarWidgets,
      );
    }
    
    // Si no hay usuarios asignados, mostrar un avatar vacío gris
    return Container(
      width: 32,
      height: 32,
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
        size: 16,
        color: Colors.grey[600],
      ),
    );
  }

  /// Construye el contenido de edición (con opciones de asignación)
  Widget _buildEditingContent() {
    final isUsingCalendar = widget.calendarZone != null;
    final name = isUsingCalendar ? widget.calendarZone!.cleaningAreaName : widget.zonaComun!.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con botones de cancelar/guardar
        Row(
          children: [
            Expanded(
              child: Text(
                'Editando: $name',
                style: const TextStyle(
                  fontSize: UIConstants.textSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: UIConstants.textColor,
                ),
              ),
            ),
            Row(
              children: [
                // Botón de cancelar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    onPressed: () => setState(() => _isEditing = false),
                    tooltip: 'Cancelar',
                  ),
                ),
                
                const SizedBox(width: UIConstants.spacingSmall),
                
                // Botón de guardar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 20,
                    ),
                    onPressed: () {
                      // TODO: Implementar guardado
                      setState(() => _isEditing = false);
                    },
                    tooltip: 'Guardar',
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: UIConstants.spacingLarge),
        
        // Sección de asignación de usuarios
        Container(
          padding: const EdgeInsets.all(UIConstants.spacingMedium),
          decoration: BoxDecoration(
            color: UIConstants.backgroundColor,
            borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
            border: Border.all(
              color: UIConstants.primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: UIConstants.primaryColor,
                  ),
                  const SizedBox(width: UIConstants.spacingSmall),
                  Text(
                    'Usuarios Asignados',
                    style: TextStyle(
                      fontSize: UIConstants.textSizeSmall,
                      fontWeight: FontWeight.w600,
                      color: UIConstants.primaryColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: UIConstants.spacingMedium),
              
              // Usuarios asignados
              if (widget.assignedUsers.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(UIConstants.spacingSmall),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                    border: Border.all(
                      color: UIConstants.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: UIConstants.primaryColor,
                        child: Text(
                          widget.assignedUsers.first.userInitials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: UIConstants.spacingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.assignedUsers.first.memberName,
                              style: const TextStyle(
                                fontSize: UIConstants.textSizeSmall,
                                fontWeight: FontWeight.w600,
                                color: UIConstants.textColor,
                              ),
                            ),
                            Text(
                              widget.assignedUsers.first.memberEmail,
                              style: TextStyle(
                                fontSize: UIConstants.textSizeSmall - 2,
                                color: UIConstants.textColor.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () {
                          // TODO: Implementar desasignación
                        },
                        tooltip: 'Desasignar',
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(UIConstants.spacingMedium),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_add_outlined,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: UIConstants.spacingSmall),
                      Text(
                        'Ningún usuario asignado',
                        style: TextStyle(
                          fontSize: UIConstants.textSizeSmall,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: UIConstants.spacingMedium),
              
              // Botón para asignar nuevo usuario
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showUserAssignmentDialog(context, isUsingCalendar ? widget.calendarZone!.cleaningAreaId : widget.zonaComun!.id);
                  },
                  icon: Icon(
                    Icons.person_add,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Asignar Usuario',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingMedium),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Muestra el diálogo de asignación de usuario
  void _showUserAssignmentDialog(BuildContext context, String areaId) {
    // Crear un CleaningAreaResponse temporal para el diálogo
    final isUsingCalendar = widget.calendarZone != null;
    final cleaningArea = CleaningAreaResponse(
      id: areaId,
      name: isUsingCalendar ? widget.calendarZone!.cleaningAreaName : widget.zonaComun!.name,
      description: isUsingCalendar ? widget.calendarZone!.cleaningAreaDescription : widget.zonaComun!.description,
      color: isUsingCalendar ? widget.calendarZone!.cleaningAreaColor : widget.zonaComun!.color,
      houseId: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    showDialog(
      context: context,
      builder: (context) => UserAssignmentDialog(
        cleaningArea: cleaningArea,
        onAssignmentSuccess: () {
          // Recargar datos después de asignar
          widget.controller.loadCleaningCalendar();
        },
      ),
    );
  }
}
