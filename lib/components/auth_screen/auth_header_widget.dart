import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import 'auth_type_selector_widget.dart';

/// Widget que muestra el header compacto de autenticación
class AuthHeaderWidget extends StatelessWidget {
  final AuthType selectedAuthType;

  const AuthHeaderWidget({
    super.key,
    required this.selectedAuthType,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getAuthTypeColor(),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _getAuthTypeColor().withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            _getAuthTypeIcon(),
            size: UIConstants.iconSizeMedium,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: UIConstants.spacingMedium + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getAuthTypeTitle(),
                style: const TextStyle(
                  fontSize: UIConstants.textSizeLarge - 6,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                _getAuthTypeSubtitle(),
                style: TextStyle(
                  fontSize: UIConstants.textSizeXSmall + 1,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Obtiene el color según el tipo de autenticación
  Color _getAuthTypeColor() {
    switch (selectedAuthType) {
      case AuthType.login:
        return Colors.blue[600]!;
      case AuthType.register:
        return Colors.green[600]!;
      case AuthType.guest:
        return Colors.orange[600]!;
    }
  }

  /// Obtiene el icono según el tipo de autenticación
  IconData _getAuthTypeIcon() {
    switch (selectedAuthType) {
      case AuthType.login:
        return Icons.login;
      case AuthType.register:
        return Icons.person_add;
      case AuthType.guest:
        return Icons.person_outline;
    }
  }

  /// Obtiene el título según el tipo de autenticación
  String _getAuthTypeTitle() {
    switch (selectedAuthType) {
      case AuthType.login:
        return 'Iniciar Sesión';
      case AuthType.register:
        return 'Crear Cuenta';
      case AuthType.guest:
        return 'Acceso de Invitado';
    }
  }

  /// Obtiene el subtítulo según el tipo de autenticación
  String _getAuthTypeSubtitle() {
    switch (selectedAuthType) {
      case AuthType.login:
        return 'Ingresa tus credenciales para acceder';
      case AuthType.register:
        return 'Regístrate para gestionar tu hogar';
      case AuthType.guest:
        return 'Accede temporalmente con PINs';
    }
  }
}
