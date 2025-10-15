import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import '../../services/common/logout_service.dart';

/// Widget que contiene los botones de acción principales
class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onCreateHouse;
  final VoidCallback onJoinHouse;

  const ActionButtonsWidget({
    super.key,
    required this.onCreateHouse,
    required this.onJoinHouse,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botón principal
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onCreateHouse,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingLarge),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius + 2),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Configurar Casa',
              style: TextStyle(
                fontSize: UIConstants.textSizeLarge - 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: UIConstants.spacingLarge),
        
        // Botón secundario
        TextButton(
          onPressed: onJoinHouse,
          child: Text(
            'Unirse a Casa Existente',
            style: TextStyle(
              color: Colors.blue[600],
              fontSize: UIConstants.textSizeLarge - 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        const SizedBox(height: UIConstants.spacingLarge * 2),
        
        // Botón de cerrar sesión
        TextButton.icon(
          onPressed: () => _showLogoutDialog(context),
          icon: Icon(
            Icons.logout,
            color: Colors.red[600],
            size: 20,
          ),
          label: Text(
            'Cerrar Sesión',
            style: TextStyle(
              color: Colors.red[600],
              fontSize: UIConstants.textSizeLarge - 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Muestra el diálogo de confirmación para cerrar sesión
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                LogoutService().performLogout(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[600],
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}
