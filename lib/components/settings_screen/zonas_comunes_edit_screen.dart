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
  List<AssignedUserInfo> _excludedUsers = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadAssignedUsers();
    _loadExcludedUsers();
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
        
        // Obtener todos los usuarios asignados directamente del backend
        _assignedUsers = [];
        for (final zone in zoneData) {
          for (final user in zone.assignedUsers) {
            // Usar directamente los datos del backend que ya incluyen assignmentId
            final assignedUser = AssignedUserInfo(
              memberId: user.memberId,
              memberName: user.memberName,
              memberEmail: user.memberEmail,
              userInitials: user.userInitials,
              hasRegisteredAccount: user.hasRegisteredAccount,
              assignmentId: user.assignmentId, // ✅ Viene directamente del backend
              exclusionId: user.exclusionId, // ✅ Viene directamente del backend
            );
            
            _assignedUsers.add(assignedUser);
          }
        }
      }
    }
  }

  void _loadExcludedUsers() {
    if (widget.zonaComun != null) {
      // Buscar usuarios excluidos en los datos del calendario
      final calendarData = widget.controller.calendarData;
      if (calendarData != null) {
        final zoneData = calendarData.zoneRotation
            .where((zone) => zone.cleaningAreaId == widget.zonaComun!.id)
            .toList();
        
        // Obtener todos los usuarios excluidos directamente del backend
        _excludedUsers = [];
        for (final zone in zoneData) {
          for (final user in zone.excludeUsers) {
            // Usar directamente los datos del backend que ya incluyen exclusionId
            final excludedUser = AssignedUserInfo(
              memberId: user.memberId,
              memberName: user.memberName,
              memberEmail: user.memberEmail,
              userInitials: user.userInitials,
              hasRegisteredAccount: user.hasRegisteredAccount,
              assignmentId: user.assignmentId, // ✅ Viene directamente del backend
              exclusionId: user.exclusionId, // ✅ Viene directamente del backend
            );
            
            _excludedUsers.add(excludedUser);
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
        backgroundColor: Colors.transparent,
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
                  color: _isLoading ? Colors.grey : Colors.grey[700],
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
                    // Solo mostrar secciones de usuarios si estamos editando una zona existente
                    if (widget.zonaComun != null) ...[
                      const SizedBox(height: UIConstants.spacingLarge),
                      _buildUserAssignmentSection(),
                      const SizedBox(height: UIConstants.spacingLarge),
                      _buildUserExclusionSection(),
                    ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de nombre
        _buildStyledTextField(
          controller: _nameController,
          labelText: 'Nombre de la zona',
          hintText: 'Ej: Cocina, Baño, Sala...',
          icon: Icons.room_rounded,
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
        _buildStyledTextField(
          controller: _descriptionController,
          labelText: 'Descripción (opcional)',
          hintText: 'Describe qué incluye esta zona...',
          icon: Icons.description_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  /// Construye la sección de selección de color
  Widget _buildColorSelectionSection() {

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        color: Colors.grey.withOpacity(0.15),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(UIConstants.spacingLarge),
            child: Row(
            children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.palette_rounded,
                color: Colors.grey[700],
                size: 20,
              ),
                ),
                const SizedBox(width: UIConstants.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              Text(
                        'Color de la Zona',
                style: TextStyle(
                  fontSize: UIConstants.textSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: UIConstants.textColor,
                ),
              ),
                      const SizedBox(height: 2),
                      Text(
                        'Elige un color predefinido o personaliza el tuyo',
                        style: TextStyle(
                          fontSize: UIConstants.textSizeSmall - 1,
                          color: UIConstants.textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(UIConstants.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Acordeón con selector de color personalizado
                _buildColorPickerAccordion(),
              ],
            ),
          ),
        ],
      ),
    );
  }


  /// Construye la sección de selección de color simple
  Widget _buildColorPickerAccordion() {
    return _buildSimpleColorPicker();
  }

  /// Construye el selector de color simple con colores predefinidos
  Widget _buildSimpleColorPicker() {
    // 20 colores bonitos y variados
    final colors = [
      '#FF6B6B', // Rojo coral
      '#4ECDC4', // Turquesa
      '#45B7D1', // Azul cielo
      '#96CEB4', // Verde menta
      '#FFEAA7', // Amarillo suave
      '#DDA0DD', // Violeta
      '#98D8C8', // Verde agua
      '#F7DC6F', // Amarillo dorado
      '#BB8FCE', // Púrpura suave
      '#85C1E9', // Azul claro
      '#F8C471', // Naranja suave
      '#82E0AA', // Verde claro
      '#F1948A', // Rosa coral
      '#D7BDE2', // Lavanda
      '#A9DFBF', // Verde esmeralda
      '#F9E79F', // Amarillo crema
      '#D5A6BD', // Rosa polvoriento
      '#AED6F1', // Azul polvo
      '#A3E4D7', // Verde agua claro
      '#FADBD8', // Rosa melocotón
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lista horizontal de colores con scroll
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              final isSelected = _selectedColor == color;
              
              return Container(
                width: 50,
                margin: const EdgeInsets.only(right: UIConstants.spacingMedium),
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      _selectedColor = color;
                      _colorController.text = color;
                    });
                    
                    // Guardar automáticamente si es una zona existente
                    if (widget.zonaComun != null) {
                      await _updateZoneColor(color);
                    }
                    
                    // Mostrar confirmación
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: UIConstants.spacingSmall),
                            Text(
                              widget.zonaComun != null 
                                ? 'Color actualizado' 
                                : 'Color $color seleccionado',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.grey[700],
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? Colors.grey.withOpacity(0.7) : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 4 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(int.parse(color.replaceFirst('#', '0xFF'))).withOpacity(0.3),
                          spreadRadius: isSelected ? 3 : 1,
                          blurRadius: isSelected ? 10 : 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 24,
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }




  /// Construye la sección de asignación de usuarios
  Widget _buildUserAssignmentSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        color: Colors.grey.withOpacity(0.15),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con detalle azul
          Container(
            padding: const EdgeInsets.all(UIConstants.spacingLarge),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: UIConstants.primaryColor, // Detalle azul
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.people_rounded,
                    color: UIConstants.primaryColor, // Detalle azul
                    size: 20,
                  ),
                ),
                const SizedBox(width: UIConstants.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usuarios Asignados',
                        style: TextStyle(
                          fontSize: UIConstants.textSizeMedium,
                          fontWeight: FontWeight.w600,
                          color: UIConstants.textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Gestiona quién limpia esta zona',
                        style: TextStyle(
                          fontSize: UIConstants.textSizeSmall - 1,
                          color: UIConstants.textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(UIConstants.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      foregroundColor: Colors.grey[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                        side: BorderSide(
                          color: Colors.grey.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingMedium),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la sección de exclusión de usuarios
  Widget _buildUserExclusionSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        color: Colors.grey.withOpacity(0.15),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con detalle rojo
          Container(
            padding: const EdgeInsets.all(UIConstants.spacingLarge),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red, // Detalle rojo
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person_off_rounded,
                    color: Colors.red, // Detalle rojo
                    size: 20,
                  ),
                ),
                const SizedBox(width: UIConstants.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usuarios Excluidos',
                        style: TextStyle(
                          fontSize: UIConstants.textSizeMedium,
                          fontWeight: FontWeight.w600,
                          color: UIConstants.textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Usuarios que no rotarán a esta zona',
                        style: TextStyle(
                          fontSize: UIConstants.textSizeSmall - 1,
                          color: UIConstants.textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(UIConstants.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lista de usuarios excluidos
                if (_excludedUsers.isEmpty)
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
                          Icons.person_off_outlined,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: UIConstants.spacingSmall),
                        Text(
                          'Ningún usuario excluido',
                          style: TextStyle(
                            fontSize: UIConstants.textSizeSmall,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._excludedUsers.map((user) => _buildExcludedUserCard(user)),
                
                const SizedBox(height: UIConstants.spacingMedium),
                
                // Botón para excluir usuarios
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _excludeUser,
                    icon: const Icon(Icons.person_remove, size: 18),
                    label: const Text('Excluir Usuario'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      foregroundColor: Colors.grey[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                        side: BorderSide(
                          color: Colors.grey.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingMedium),
                    ),
                  ),
                ),
              ],
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
        color: Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[700],
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
            icon: Icon(Icons.remove_circle_outline, color: Colors.grey[700]),
            onPressed: () => _removeUser(user),
            tooltip: 'Desasignar usuario',
          ),
        ],
      ),
    );
  }

  /// Construye una card para un usuario excluido
  Widget _buildExcludedUserCard(AssignedUserInfo user) {
    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSmall),
      padding: const EdgeInsets.all(UIConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[700],
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
            icon: Icon(Icons.remove_circle_outline, color: Colors.grey[700]),
            onPressed: () => _removeExcludedUser(user),
            tooltip: 'Quitar exclusión',
          ),
        ],
      ),
    );
  }

  /// Construye los botones de acción
  Widget _buildActionButtons() {
    // Si estamos editando, solo mostrar botón de cerrar
    if (widget.zonaComun != null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingMedium),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
            ),
          ),
          child: const Text('Cerrar'),
        ),
      );
    }
    
    // Si estamos creando, mostrar botones de crear y cancelar
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
              backgroundColor: Colors.grey.withOpacity(0.2),
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                side: BorderSide(
                  color: Colors.grey.withOpacity(0.5),
                  width: 2,
                ),
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
                : const Text('Crear Zona'),
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

  /// Excluye un usuario de la zona
  void _excludeUser() {
    // Solo permitir excluir usuarios si la zona ya existe
    if (widget.zonaComun == null) {
      SnackBarService().showError(context, 'Primero debe guardar la zona antes de excluir usuarios');
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
            await widget.controller.createRotationExclusion(memberId, areaId);
            // Esperar un frame para asegurar que el controller haya actualizado _calendarData y notifyListeners() haya terminado
            await Future.delayed(const Duration(milliseconds: 50));
            // Recargar la lista de usuarios excluidos desde el calendario actualizado
            if (mounted) {
              _loadExcludedUsers();
              setState(() {});
              SnackBarService().showSuccess(context, 'Usuario excluido correctamente');
            }
          } catch (e) {
            if (mounted) {
              SnackBarService().showError(context, 'Error al excluir usuario: $e');
            }
          }
        },
      ),
    );
  }

  /// Remueve la exclusión de un usuario
  void _removeExcludedUser(AssignedUserInfo user) async {
    // Solo permitir quitar exclusiones si la zona ya existe
    if (widget.zonaComun == null) {
      SnackBarService().showError(context, 'No se puede quitar exclusiones de una zona que no existe');
      return;
    }
    
    // Verificar que tenemos el exclusionId
    if (user.exclusionId == null) {
      SnackBarService().showError(context, 'No se puede quitar la exclusión: ID no disponible');
      return;
    }
    
    try {
      await widget.controller.removeRotationExclusion(user.exclusionId!);
      // Recargar la lista de usuarios excluidos desde el calendario actualizado
      _loadExcludedUsers();
      // Actualizar la UI
      if (mounted) {
        setState(() {});
        SnackBarService().showSuccess(context, 'Exclusión eliminada correctamente');
      }
    } catch (e) {
      if (mounted) {
        SnackBarService().showError(context, 'Error al quitar exclusión: $e');
      }
    }
  }

  /// Actualiza el color de la zona automáticamente
  Future<void> _updateZoneColor(String color) async {
    if (widget.zonaComun == null) return;
    
    try {
      final request = CreateCleaningAreaRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        color: color,
      );
      
      await widget.controller.updateCleaningArea(widget.zonaComun!.id, request);
      if (mounted) {
        SnackBarService().showSuccess(context, 'Color actualizado correctamente');
      }
    } catch (e) {
      if (mounted) {
        SnackBarService().showError(context, 'Error al actualizar color: $e');
      }
    }
  }

  /// Guarda automáticamente los campos de texto
  Future<void> _autoSaveField() async {
    if (widget.zonaComun == null) return;
    
    // Validar el formulario antes de guardar
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    try {
      final request = CreateCleaningAreaRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        color: _selectedColor ?? widget.zonaComun!.color,
      );
      
      await widget.controller.updateCleaningArea(widget.zonaComun!.id, request);
      if (mounted) {
        SnackBarService().showSuccess(context, 'Zona actualizada correctamente');
      }
    } catch (e) {
      if (mounted) {
        SnackBarService().showError(context, 'Error al actualizar zona: $e');
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

  /// Construye un campo de texto estilizado
  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label independiente
        Text(
          labelText,
          style: TextStyle(
            fontSize: UIConstants.textSizeLarge,
            fontWeight: FontWeight.w700,
            color: UIConstants.textColor,
          ),
        ),
        const SizedBox(height: UIConstants.spacingSmall),
        
        // Input sin label
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                spreadRadius: 0,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
                    child: TextFormField(
                      controller: controller,
                      maxLines: maxLines,
                      validator: validator,
                      onFieldSubmitted: (value) => _autoSaveField(),
                      onEditingComplete: () => _autoSaveField(),
                      style: TextStyle(
                        fontSize: UIConstants.textSizeMedium,
                        color: UIConstants.textColor,
                      ),
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: Icon(
                icon,
                color: Colors.grey[700],
                size: 20,
              ),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.5),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.5),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.7),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              hintStyle: TextStyle(
                color: UIConstants.textColor.withOpacity(0.5),
                fontSize: UIConstants.textSizeSmall,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingMedium,
                vertical: UIConstants.spacingMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
