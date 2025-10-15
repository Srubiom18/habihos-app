import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'snackbar_service.dart';

/// Servicio para manejar el proceso de logout de la aplicación
/// 
/// Centraliza toda la lógica relacionada con el cierre de sesión,
/// incluyendo la limpieza de datos, navegación y notificaciones.
class LogoutService {
  static final LogoutService _instance = LogoutService._internal();
  factory LogoutService() => _instance;
  LogoutService._internal();

  /// Realiza el proceso completo de logout
  /// 
  /// [context] - Contexto de la aplicación para navegación
  /// [showSuccessMessage] - Si se debe mostrar mensaje de éxito (default: true)
  /// 
  /// Retorna true si el logout fue exitoso, false en caso contrario
  Future<bool> performLogout(
    BuildContext context, {
    bool showSuccessMessage = true,
  }) async {
    try {
      // Limpiar datos de sesión
      await AuthService.logout();

      // Navegar a la pantalla de autenticación
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/auth',
          (route) => false,
        );

        // Mostrar mensaje de confirmación si se solicita
        if (showSuccessMessage) {
          SnackBarService().showSuccess(
            context,
            '👋 Sesión cerrada correctamente',
          );
        }

        return true;
      }
      return false;
    } catch (e) {
      // En caso de error, intentar navegar de todas formas
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/auth',
          (route) => false,
        );

        // Mostrar mensaje de error
        SnackBarService().showError(
          context,
          'Error al cerrar sesión: ${e.toString()}',
        );
      }
      return false;
    }
  }

  /// Muestra el diálogo de confirmación para cerrar sesión
  /// 
  /// [context] - Contexto de la aplicación
  /// [onConfirmed] - Callback que se ejecuta cuando se confirma el logout
  void showLogoutDialog(
    BuildContext context, {
    VoidCallback? onConfirmed,
  }) {
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
                onConfirmed?.call();
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}
