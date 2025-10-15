import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';

/// Clase que representa un formulario de área de limpieza
class CleaningAreaForm {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
}

/// Widget que representa un formulario individual de área de limpieza
class CleaningAreaFormWidget extends StatelessWidget {
  final CleaningAreaForm cleaningArea;
  final int index;
  final bool canRemove;
  final VoidCallback? onRemove;

  const CleaningAreaFormWidget({
    super.key,
    required this.cleaningArea,
    required this.index,
    this.canRemove = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        boxShadow: UIConstants.defaultShadow,
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header del área con número y botón de eliminar
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: UIConstants.textSizeNormal,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: UIConstants.spacingMedium),
              Expanded(
                child: Text(
                  'Área de Limpieza ${index + 1}',
                  style: TextStyle(
                    fontSize: UIConstants.textSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              if (canRemove)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                  ),
                  child: IconButton(
                    onPressed: onRemove,
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red[600],
                      size: UIConstants.iconSizeMedium,
                    ),
                    tooltip: 'Eliminar área',
                  ),
                ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingLarge),
          
          // Campo de nombre
          _buildNameField(),
          const SizedBox(height: UIConstants.spacingLarge),
          
          // Campo de descripción
          _buildDescriptionField(),
        ],
      ),
    );
  }

  /// Construye el campo de nombre
  Widget _buildNameField() {
    return TextFormField(
      controller: cleaningArea.nameController,
      style: const TextStyle(
        fontSize: UIConstants.textSizeMedium,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'Nombre del área (ej: Cocina, Baño, Sala...)',
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: UIConstants.textSizeMedium,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          Icons.room_preferences_outlined,
          color: Colors.blue[600],
          size: UIConstants.iconSizeMedium + 2,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingLarge,
          vertical: UIConstants.spacingMedium + 2,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El nombre es obligatorio';
        }
        return null;
      },
    );
  }

  /// Construye el campo de descripción
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: cleaningArea.descriptionController,
      maxLines: 2,
      style: const TextStyle(
        fontSize: UIConstants.textSizeMedium,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'Descripción opcional (ej: Incluye estufa y refrigerador)',
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: UIConstants.textSizeMedium,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          Icons.description_outlined,
          color: Colors.grey[600],
          size: UIConstants.iconSizeMedium + 2,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingLarge,
          vertical: UIConstants.spacingMedium + 2,
        ),
      ),
    );
  }
}
