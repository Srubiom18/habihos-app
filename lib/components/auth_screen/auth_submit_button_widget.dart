import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import 'auth_type_selector_widget.dart';

/// Widget que muestra el botón de envío de autenticación
class AuthSubmitButtonWidget extends StatelessWidget {
  final AuthType selectedAuthType;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPressed;

  const AuthSubmitButtonWidget({
    super.key,
    required this.selectedAuthType,
    required this.isLoading,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading || !isEnabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getAuthTypeColor(),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingLarge),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius + 2),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                height: UIConstants.iconSizeMedium,
                width: UIConstants.iconSizeMedium,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _getSubmitButtonText(),
                style: const TextStyle(
                  fontSize: UIConstants.textSizeLarge - 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
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

  /// Obtiene el texto del botón según el tipo de autenticación
  String _getSubmitButtonText() {
    switch (selectedAuthType) {
      case AuthType.login:
        return 'Iniciar Sesión';
      case AuthType.register:
        return 'Crear Cuenta';
      case AuthType.guest:
        return 'Acceder como Invitado';
    }
  }
}
