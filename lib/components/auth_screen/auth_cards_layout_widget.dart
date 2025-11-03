import 'package:flutter/material.dart';
import 'auth_card_widget.dart';
import 'auth_types.dart';

/// Widget que maneja el layout de las cards de autenticación
class AuthCardsLayoutWidget extends StatelessWidget {
  final AuthType? selectedAuthType;
  final Function(AuthType) onCardSelected;
  final Widget? expandedContent;

  const AuthCardsLayoutWidget({
    super.key,
    this.selectedAuthType,
    required this.onCardSelected,
    this.expandedContent,
  });

  @override
  Widget build(BuildContext context) {
    // Si hay una card seleccionada, mostrar solo esa card expandida
    if (selectedAuthType != null) {
      return AuthCardWidget(
        authType: selectedAuthType!,
        isExpanded: true,
        onTap: () => onCardSelected(selectedAuthType!),
        expandedContent: expandedContent,
      );
    }

    // Si no hay card seleccionada, mostrar el layout de 3 cards ocupando toda la pantalla
    return _buildFullscreenCardsLayout();
  }

  /// Construye el layout de las 3 cards en columna vertical ocupando toda la pantalla
  Widget _buildFullscreenCardsLayout() {
    return Column(
      children: [
        // Card de Login
        Expanded(
          child: AuthCardWidget(
            authType: AuthType.login,
            isExpanded: false,
            onTap: () => onCardSelected(AuthType.login),
          ),
        ),
        // Card de Registro
        Expanded(
          child: AuthCardWidget(
            authType: AuthType.register,
            isExpanded: false,
            onTap: () => onCardSelected(AuthType.register),
          ),
        ),
        // Card de Invitado
        Expanded(
          child: AuthCardWidget(
            authType: AuthType.guest,
            isExpanded: false,
            onTap: () => onCardSelected(AuthType.guest),
          ),
        ),
      ],
    );
  }
}
