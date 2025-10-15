import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import '../../services/common/logout_service.dart';
import '../../services/common/snackbar_service.dart';
import '../../screens/settings_screen.dart';

/// Widget que muestra el header del home con nombre de casa y avatar
class HomeHeaderWidget extends StatelessWidget {
  final String houseName;

  const HomeHeaderWidget({
    super.key,
    required this.houseName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: UIConstants.screenPadding,
      ),
      child: Row(
        children: [
          // Nombre de la casa pegado al margen izquierdo
          Padding(
            padding: const EdgeInsets.only(left: UIConstants.screenPadding),
            child: Text(
              houseName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: UIConstants.textColor,
                letterSpacing: -0.5,
                height: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Espacio flexible para empujar el avatar a la derecha
          const Spacer(),
          
          // Avatar del usuario con menú desplegable pegado al margen derecho
          Padding(
            padding: const EdgeInsets.only(right: UIConstants.screenPadding),
            child: _buildAvatar(context),
          ),
        ],
      ),
    );
  }

  /// Construye el avatar del usuario con menú desplegable
  Widget _buildAvatar(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              UIConstants.primaryColor,
              UIConstants.primaryColor.withOpacity(0.8),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: UIConstants.primaryColor.withOpacity(0.4),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.person_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'profile',
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Administrar Perfil',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: UIConstants.textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'settings',
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Configuración',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: UIConstants.textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      onSelected: (String value) {
        switch (value) {
          case 'profile':
            SnackBarService().showInfo(
              context,
              '👤 Administrando perfil...',
            );
            break;
          case 'settings':
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
            break;
          case 'logout':
            _showLogoutDialog(context);
            break;
        }
      },
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
                _performLogout(context);
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  /// Realiza el proceso de cerrar sesión usando el servicio dedicado
  void _performLogout(BuildContext context) {
    LogoutService().performLogout(context);
  }
}
