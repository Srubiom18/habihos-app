import 'package:flutter/material.dart';
import '../../interfaces/home_screen/cleaning_area.dart';
import '../../constants/ui_constants.dart';

/// Widget que muestra el área de limpieza activa (la zona principal)
class ActiveCleaningAreaWidget extends StatelessWidget {
  final CleaningArea currentArea;
  final bool isCompleted;

  const ActiveCleaningAreaWidget({
    super.key,
    required this.currentArea,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: UIConstants.activeAreaHeight,
      margin: const EdgeInsets.only(bottom: UIConstants.spacingMedium),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        color: currentArea.color.withOpacity(0.1),
        border: Border.all(
          color: isCompleted ? Colors.green : currentArea.color,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: currentArea.color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: UIConstants.spacingXLarge),
          // Icono grande con indicador de estado
          _buildIconWithIndicator(),
          const SizedBox(width: UIConstants.spacingXLarge),
          // Información de la zona activa
          Expanded(
            child: _buildAreaInfo(),
          ),
          const SizedBox(width: UIConstants.spacingXLarge),
        ],
      ),
    );
  }

  /// Construye el icono con el indicador de estado
  Widget _buildIconWithIndicator() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(UIConstants.spacingXLarge),
          decoration: BoxDecoration(
            color: isCompleted ? Colors.green : currentArea.color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            currentArea.icon,
            size: UIConstants.iconSizeLarge,
            color: Colors.white,
          ),
        ),
        // Indicador de estado
        if (!isCompleted)
          _buildPendingIndicator()
        else
          _buildCompletedIndicator(),
      ],
    );
  }

  /// Construye el indicador de tarea pendiente
  Widget _buildPendingIndicator() {
    return Positioned(
      right: 0,
      top: 0,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(
          Icons.star,
          size: UIConstants.iconSizeXSmall,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Construye el indicador de tarea completada
  Widget _buildCompletedIndicator() {
    return Positioned(
      right: 0,
      top: 0,
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          size: UIConstants.iconSizeXSmall,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Construye la información del área
  Widget _buildAreaInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentArea.name,
          style: TextStyle(
            fontSize: UIConstants.textSizeLarge,
            fontWeight: FontWeight.bold,
            color: isCompleted ? Colors.green[800] : currentArea.color,
          ),
        ),
        const SizedBox(height: UIConstants.spacingMedium),
        Text(
          currentArea.description,
          style: TextStyle(
            fontSize: UIConstants.textSizeNormal,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
