import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';

/// Enum para los tipos de autenticación
enum AuthType { login, register, guest }

/// Widget que muestra el selector de tipo de autenticación
class AuthTypeSelectorWidget extends StatelessWidget {
  final AuthType selectedAuthType;
  final Function(AuthType) onAuthTypeChanged;

  const AuthTypeSelectorWidget({
    super.key,
    required this.selectedAuthType,
    required this.onAuthTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingSmall),
      decoration: BoxDecoration(
        color: UIConstants.containerBackgroundColor,
        borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
        boxShadow: UIConstants.defaultShadow,
      ),
      child: Row(
        children: [
          _buildAuthTypeButton(
            type: AuthType.login,
            title: 'Login',
            icon: Icons.login,
            color: Colors.blue[600]!,
          ),
          _buildAuthTypeButton(
            type: AuthType.register,
            title: 'Registro',
            icon: Icons.person_add,
            color: Colors.green[600]!,
          ),
          _buildAuthTypeButton(
            type: AuthType.guest,
            title: 'Invitado',
            icon: Icons.person_outline,
            color: Colors.orange[600]!,
          ),
        ],
      ),
    );
  }

  /// Construye un botón de tipo de autenticación
  Widget _buildAuthTypeButton({
    required AuthType type,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = selectedAuthType == type;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onAuthTypeChanged(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: UIConstants.spacingLarge,
            horizontal: UIConstants.spacingSmall,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: UIConstants.iconSizeMedium + 2,
              ),
              const SizedBox(height: UIConstants.spacingSmall),
              Text(
                title,
                style: TextStyle(
                  fontSize: UIConstants.textSizeSmall,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
