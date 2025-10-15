import 'package:flutter/material.dart';

/// Servicio para mostrar mensajes SnackBar de forma consistente en toda la aplicación
class SnackBarService {
  static final SnackBarService _instance = SnackBarService._internal();
  factory SnackBarService() => _instance;
  SnackBarService._internal();

  /// Muestra un mensaje de éxito
  void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  /// Muestra un mensaje de error
  void showError(BuildContext context, String message) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }

  /// Muestra un mensaje de información
  void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
    );
  }

  /// Muestra un mensaje de advertencia
  void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
    );
  }

  /// Muestra un mensaje personalizado
  void showCustom(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      duration: duration,
    );
  }

  /// Método privado para mostrar el SnackBar
  void _showSnackBar({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
