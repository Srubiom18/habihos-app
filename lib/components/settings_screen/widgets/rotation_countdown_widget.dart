import 'package:flutter/material.dart';
import '../../../constants/ui_constants.dart';
import '../controllers/zonas_comunes_controller.dart';

/// Widget que muestra el cronómetro de rotación
class RotationCountdownWidget extends StatelessWidget {
  final ZonasComunesController controller;

  const RotationCountdownWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        // Mostrar siempre que la rotación esté activa
        if (!controller.isRotationActive) {
          return const SizedBox.shrink();
        }

        // Mostrar texto de carga si el cronómetro no está activo aún
        final countdownText = controller.isRotationCountdownActive 
            ? controller.rotationCountdownText 
            : 'Calculando...';

        return Container(
          margin: const EdgeInsets.symmetric(vertical: UIConstants.spacingSmall),
          padding: const EdgeInsets.all(UIConstants.spacingMedium),
          decoration: BoxDecoration(
            color: UIConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
            border: Border.all(
              color: UIConstants.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icono de reloj
              Container(
                padding: const EdgeInsets.all(UIConstants.spacingSmall),
                decoration: BoxDecoration(
                  color: UIConstants.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
                ),
                child: Icon(
                  controller.isRotationCountdownActive ? Icons.timer : Icons.hourglass_empty,
                  color: UIConstants.primaryColor,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: UIConstants.spacingMedium),
              
              // Información del cronómetro
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Próxima Rotación',
                      style: TextStyle(
                        fontSize: UIConstants.textSizeSmall,
                        fontWeight: FontWeight.w500,
                        color: UIConstants.textColor.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingSmall),
                    Text(
                      countdownText,
                      style: TextStyle(
                        fontSize: UIConstants.textSizeLarge,
                        fontWeight: FontWeight.w600,
                        color: UIConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Indicador de estado
              if (controller.isRotationCountdownActive)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getCountdownColor(),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Obtiene el color del indicador según el tiempo restante
  Color _getCountdownColor() {
    final duration = controller.timeUntilNextRotation;
    
    if (duration.inMinutes < 1) {
      return Colors.red; // Menos de 1 minuto - rojo
    } else if (duration.inMinutes < 5) {
      return Colors.orange; // Menos de 5 minutos - naranja
    } else {
      return Colors.green; // Más de 5 minutos - verde
    }
  }
}
