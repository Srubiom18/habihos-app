import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import '../../services/common/logout_service.dart';
import '../../screens/settings_screen.dart';
import '../../screens/user_profile_screen.dart';

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
      margin: const EdgeInsets.only(
        left: UIConstants.screenPadding,
        right: UIConstants.screenPadding,
        top: UIConstants.screenPadding,
      ),
      child: Row(
        children: [
          // Contenedor con el nombre de la casa
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
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
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  houseName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: UIConstants.textColor,
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16), // Espacio entre contenedor y avatar
          
          // Avatar del usuario con menú desplegable (fuera del contenedor)
          _buildAvatar(context),
        ],
      ),
    );
  }

  /// Construye el avatar del usuario con menú desplegable
  Widget _buildAvatar(BuildContext context) {
    // Calcular la altura del contenedor basándose en el padding y tamaño de fuente
    // Padding: 16 * 2 = 32, Altura de texto aproximada: 28 * 1.2 = 33.6
    // Total aproximado: 32 + 33.6 = 65.6, redondeamos a 66
    const double containerHeight = 66;
    
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: containerHeight,
        height: containerHeight,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.withOpacity(0.5),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.person_rounded,
          color: Colors.grey[700],
          size: 32, // Aumentar el tamaño del icono proporcionalmente
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
                    color: Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: Colors.black87,
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
                    color: Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: Colors.black87,
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
                    color: Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Cerrar Sesión',
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
      ],
      onSelected: (String value) {
        switch (value) {
          case 'profile':
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const UserProfileScreen(),
              ),
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
