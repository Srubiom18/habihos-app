import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import '../../models/api_models.dart';
import '../../services/common/snackbar_service.dart';
import 'controllers/zonas_comunes_controller.dart';
import 'widgets/user_selection_dialog.dart';

/// Pantalla para crear o editar una zona de limpieza
class ZonasComunesEditScreen extends StatefulWidget {
  final CleaningAreaResponse? zonaComun; // null para crear nueva, con datos para editar
  final ZonasComunesController controller;

  const ZonasComunesEditScreen({
    super.key,
    this.zonaComun,
    required this.controller,
  });

  @override
  State<ZonasComunesEditScreen> createState() => _ZonasComunesEditScreenState();
}

class _ZonasComunesEditScreenState extends State<ZonasComunesEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colorController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSaving = false;
  String? _selectedColor;
  List<AssignedUserInfo> _assignedUsers = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadAssignedUsers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  /// Inicializa el formulario con los datos existentes si está editando
  void _initializeForm() {
    if (widget.zonaComun != null) {
      _nameController.text = widget.zonaComun!.name;
      _descriptionController.text = widget.zonaComun!.description;
      _colorController.text = widget.zonaComun!.color;
      _selectedColor = widget.zonaComun!.color;
    } else {
      _selectedColor = '#2196F3'; // Color azul por defecto
      _colorController.text = '#2196F3';
    }
  }

  /// Carga los usuarios asignados a la zona
  void _loadAssignedUsers() {
    if (widget.zonaComun != null) {
      // Buscar usuarios asignados en los datos del calendario
      final calendarData = widget.controller.calendarData;
      if (calendarData != null) {
        final zoneData = calendarData.zoneRotation
            .where((zone) => zone.cleaningAreaId == widget.zonaComun!.id)
            .toList();
        
        // Obtener todos los usuarios asignados de todas las zonas encontradas
        _assignedUsers = [];
        for (final zone in zoneData) {
          for (final user in zone.assignedUsers) {
            // Buscar el assignmentId para este usuario en esta zona
            final assignmentId = widget.controller.getAssignmentIdForUser(
              widget.zonaComun!.id, 
              user.memberId
            );
            
            // Crear un nuevo AssignedUserInfo con el assignmentId
            final userWithAssignmentId = AssignedUserInfo(
              memberId: user.memberId,
              memberName: user.memberName,
              memberEmail: user.memberEmail,
              userInitials: user.userInitials,
              hasRegisteredAccount: user.hasRegisteredAccount,
              assignmentId: assignmentId,
            );
            
            _assignedUsers.add(userWithAssignmentId);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.zonaComun != null ? 'Editar Zona' : 'Nueva Zona',
          style: const TextStyle(
            fontSize: UIConstants.textSizeLarge,
            fontWeight: FontWeight.w600,
            color: UIConstants.textColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: UIConstants.textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _isLoading ? null : _saveZone,
              child: Text(
                'Guardar',
                style: TextStyle(
                  color: _isLoading ? Colors.grey : UIConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(UIConstants.screenPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoSection(),
                    const SizedBox(height: UIConstants.spacingLarge),
                    _buildColorSelectionSection(),
                    const SizedBox(height: UIConstants.spacingLarge),
                    _buildUserAssignmentSection(),
                    const SizedBox(height: UIConstants.spacingLarge),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  /// Construye la sección de información básica
  Widget _buildBasicInfoSection() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: UIConstants.primaryColor,
                size: 20,
              ),
              const SizedBox(width: UIConstants.spacingSmall),
              Text(
                'Información Básica',
                style: TextStyle(
                  fontSize: UIConstants.textSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: UIConstants.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingLarge),
          
          // Campo de nombre
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la zona',
              hintText: 'Ej: Cocina, Baño, Sala...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.room),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es obligatorio';
              }
              if (value.trim().length < 2) {
                return 'El nombre debe tener al menos 2 caracteres';
              }
              return null;
            },
          ),
          
          const SizedBox(height: UIConstants.spacingLarge),
          
          // Campo de descripción
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción (opcional)',
              hintText: 'Describe qué incluye esta zona...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la sección de selección de color
  Widget _buildColorSelectionSection() {
    final colors = [
      '#2196F3', // Blue
      '#FF5722', // Red
      '#4CAF50', // Green
      '#FF9800', // Orange
      '#9C27B0', // Purple
      '#00BCD4', // Cyan
      '#E91E63', // Pink
      '#795548', // Brown
    ];

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                color: UIConstants.primaryColor,
                size: 20,
              ),
              const SizedBox(width: UIConstants.spacingSmall),
              Text(
                'Color de la Zona',
                style: TextStyle(
                  fontSize: UIConstants.textSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: UIConstants.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingLarge),
          
          // Colores disponibles
          Wrap(
            spacing: UIConstants.spacingMedium,
            runSpacing: UIConstants.spacingMedium,
            children: colors.map((color) {
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                    _colorController.text = color;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(int.parse(color.toString().replaceFirst('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected ? UIConstants.textColor : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Color(int.parse(color.toString().replaceFirst('#', '0xFF'))).withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Construye la sección de asignación de usuarios
  Widget _buildUserAssignmentSection() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people_outline,
                color: UIConstants.primaryColor,
                size: 20,
              ),
              const SizedBox(width: UIConstants.spacingSmall),
              Text(
                'Usuarios Asignados',
                style: TextStyle(
                  fontSize: UIConstants.textSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: UIConstants.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingLarge),
          
          // Lista de usuarios asignados
          if (_assignedUsers.isEmpty)
            Container(
              padding: const EdgeInsets.all(UIConstants.spacingLarge),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
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
            )
          else
            ..._assignedUsers.map((user) => _buildAssignedUserCard(user)),
          
          const SizedBox(height: UIConstants.spacingMedium),
          
          // Botón para asignar usuarios
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _assignUser,
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Asignar Usuario'),
              style: ElevatedButton.styleFrom(
                backgroundColor: UIConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                ),
                padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una card para un usuario asignado
  Widget _buildAssignedUserCard(AssignedUserInfo user) {
    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSmall),
      padding: const EdgeInsets.all(UIConstants.spacingMedium),
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
            radius: 20,
            backgroundColor: UIConstants.primaryColor,
            child: Text(
              user.userInitials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: UIConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.memberName,
                  style: const TextStyle(
                    fontSize: UIConstants.textSizeSmall,
                    fontWeight: FontWeight.w600,
                    color: UIConstants.textColor,
                  ),
                ),
                Text(
                  user.memberEmail,
                  style: TextStyle(
                    fontSize: UIConstants.textSizeSmall - 2,
                    color: UIConstants.textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: () => _removeUser(user),
            tooltip: 'Desasignar usuario',
          ),
        ],
      ),
    );
  }

  /// Construye los botones de acción
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
              ),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: UIConstants.spacingMedium),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveZone,
            style: ElevatedButton.styleFrom(
              backgroundColor: UIConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(widget.zonaComun != null ? 'Actualizar Zona' : 'Crear Zona'),
          ),
        ),
      ],
    );
  }

  /// Asigna un usuario a la zona
  void _assignUser() {
    // Solo permitir asignar usuarios si la zona ya existe
    if (widget.zonaComun == null) {
      SnackBarService().showError(context, 'Primero debe guardar la zona antes de asignar usuarios');
      return;
    }
    
    final areaId = widget.zonaComun!.id;
    
    showDialog(
      context: context,
      builder: (context) => UserSelectionDialog(
        areaId: areaId,
        controller: widget.controller,
        onUserSelected: (memberId) async {
          try {
            await widget.controller.assignUserToZone(areaId, memberId);
            // Recargar la lista de usuarios asignados
            _loadAssignedUsers();
            // Actualizar la UI
            if (mounted) {
              setState(() {});
              SnackBarService().showSuccess(context, 'Usuario asignado correctamente');
            }
          } catch (e) {
            if (mounted) {
              SnackBarService().showError(context, 'Error al asignar usuario: $e');
            }
          }
        },
      ),
    );
  }

  /// Remueve un usuario de la zona
  void _removeUser(AssignedUserInfo user) async {
    // Solo permitir desasignar usuarios si la zona ya existe
    if (widget.zonaComun == null) {
      SnackBarService().showError(context, 'No se puede desasignar usuarios de una zona que no existe');
      return;
    }
    
    // Verificar que tenemos el assignmentId
    if (user.assignmentId == null) {
      SnackBarService().showError(context, 'No se puede desasignar: ID de asignación no disponible');
      return;
    }
    
    try {
      await widget.controller.unassignUserFromZone(user.assignmentId!);
      // Recargar la lista de usuarios asignados
      _loadAssignedUsers();
      // Actualizar la UI
      if (mounted) {
        setState(() {});
        SnackBarService().showSuccess(context, 'Usuario desasignado correctamente');
      }
    } catch (e) {
      if (mounted) {
        SnackBarService().showError(context, 'Error al desasignar usuario: $e');
      }
    }
  }

  /// Guarda la zona
  Future<void> _saveZone() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.zonaComun != null) {
        // Actualizar zona existente
        await widget.controller.updateCleaningArea(
          widget.zonaComun!.id,
          CreateCleaningAreaRequest(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            color: _selectedColor!,
          ),
        );
      } else {
        // Crear nueva zona
        await widget.controller.createCleaningArea(
          CreateCleaningAreaRequest(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            color: _selectedColor!,
          ),
        );
      }

      // TODO: Guardar asignaciones de usuarios
      // for (final user in _assignedUsers) {
      //   await widget.controller.assignUserToZone(zoneId, user.memberId);
      // }

      if (mounted) {
        Navigator.of(context).pop(true); // Retornar true indica éxito
        SnackBarService().showSuccess(
          context,
          widget.zonaComun != null 
              ? 'Zona actualizada correctamente' 
              : 'Zona creada correctamente',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarService().showError(context, 'Error al guardar la zona: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
