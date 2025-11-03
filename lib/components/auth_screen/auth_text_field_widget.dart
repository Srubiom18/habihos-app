import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import 'auth_types.dart';

/// Widget personalizado para campos de texto en autenticación
class AuthTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final AuthType authType;

  const AuthTextFieldWidget({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.authType,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: UIConstants.textSizeSmall,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: UIConstants.spacingSmall),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: UIConstants.textSizeNormal,
              color: Colors.grey[500],
            ),
            prefixIcon: Icon(
              icon,
              color: Colors.grey[600],
              size: UIConstants.iconSizeMedium,
            ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
              borderSide: BorderSide(color: _getAuthTypeColor(), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: UIConstants.containerBackgroundColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: UIConstants.spacingLarge - 4,
              vertical: UIConstants.spacingMedium + 2,
            ),
          ),
        ),
      ],
    );
  }

  /// Obtiene el color según el tipo de autenticación
  Color _getAuthTypeColor() {
    switch (authType) {
      case AuthType.login:
        return Colors.blue[600]!;
      case AuthType.register:
        return Colors.green[600]!;
      case AuthType.guest:
        return Colors.orange[600]!;
    }
  }
}
