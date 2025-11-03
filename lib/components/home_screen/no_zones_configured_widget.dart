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
        color: Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 3),
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
        children: [
          // Icono principal
          Container(
            padding: const EdgeInsets.all(UIConstants.spacingLarge),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.withOpacity(0.5),
                width: 3,
              ),
            ),
            child: Icon(
              Icons.cleaning_services,
              size: UIConstants.iconSizeLarge,
              color: Colors.grey[700],
            ),
          ),
          
          const SizedBox(height: UIConstants.spacingLarge),
          
          // Título
          Text(
            'No hay zonas configuradas',
            style: TextStyle(
              fontSize: UIConstants.textSizeLarge,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: UIConstants.spacingMedium),
          
          // Mensaje de la API
          Text(
            message,
            style: TextStyle(
              fontSize: UIConstants.textSizeNormal,
              color: Colors.black87,
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
                backgroundColor: Colors.grey[700],
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
