import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';

/// Widget que muestra un mensaje cuando no hay zonas de limpieza configuradas
/// 
/// Se muestra cuando la API retorna que no hay zonas configuradas
/// y proporciona información al usuario sobre cómo proceder.
class NoZonesConfiguredWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onConfigureZones;

  const NoZonesConfiguredWidget({
    super.key,
    required this.message,
    this.onConfigureZones,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: UIConstants.spacingMedium),
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        border: Border.all(color: Colors.blue[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icono principal
          Container(
            padding: const EdgeInsets.all(UIConstants.spacingLarge),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cleaning_services,
              size: UIConstants.iconSizeLarge,
              color: Colors.blue[700],
            ),
          ),
          
          const SizedBox(height: UIConstants.spacingLarge),
          
          // Título
          Text(
            'No hay zonas configuradas',
            style: TextStyle(
              fontSize: UIConstants.textSizeLarge,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: UIConstants.spacingMedium),
          
          // Mensaje de la API
          Text(
            message,
            style: TextStyle(
              fontSize: UIConstants.textSizeNormal,
              color: Colors.blue[700],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: UIConstants.spacingLarge),
          
          // Botón de acción (opcional)
          if (onConfigureZones != null)
            ElevatedButton.icon(
              onPressed: onConfigureZones,
              icon: const Icon(Icons.settings),
              label: const Text('Configurar Zonas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.spacingLarge,
                  vertical: UIConstants.spacingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
