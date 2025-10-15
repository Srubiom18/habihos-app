import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/jwt_service.dart';
import '../../services/common/snackbar_service.dart';

/// Servicio que maneja la lógica de autenticación
class AuthLogicService {
  static final AuthLogicService _instance = AuthLogicService._internal();
  factory AuthLogicService() => _instance;
  AuthLogicService._internal();

  /// Realiza el proceso de login
  Future<void> performLogin(
    BuildContext context,
    String email,
    String password,
  ) async {
    final result = await AuthService.login(email, password);

    if (result.success) {
      if (context.mounted) {
        // Verificar si el usuario tiene una casa activa desde el token
        final hasActiveHouse = await AuthService.hasActiveHouse();
        
        if (hasActiveHouse) {
          // Casa activa - ir directamente a home
          Navigator.pushReplacementNamed(context, '/home');
          SnackBarService().showSuccess(
            context,
            '¡Bienvenido ${result.userInfo?.nickname ?? ''}!',
          );
        } else {
          // No hay casa activa - ir a home selector
          Navigator.pushReplacementNamed(context, '/home-selector');
          SnackBarService().showInfo(
            context,
            '¡Bienvenido ${result.userInfo?.nickname ?? ''}! Configura tu casa.',
          );
        }
      }
    } else {
      if (context.mounted) {
        SnackBarService().showError(
          context,
          result.error ?? 'Error desconocido',
        );
      }
    }
  }

  /// Realiza el proceso de registro
  Future<void> performRegister(BuildContext context) async {
    // Simular registro exitoso
    SnackBarService().showSuccess(
      context,
      '¡Registro exitoso! Revisa tu email para confirmar tu cuenta.',
    );
    
    // Volver a la pantalla de bienvenida después de un breve delay
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    });
  }

  /// Realiza el proceso de acceso como invitado
  Future<void> performGuestAccess(
    BuildContext context,
    String nickname,
    String houseCode,
    String userPin,
  ) async {
    final result = await AuthService.guestLogin(nickname, houseCode, userPin);

    if (result.success) {
      if (context.mounted) {
        // Verificar si el usuario tiene una casa activa desde el token
        final hasActiveHouse = await AuthService.hasActiveHouse();
        
        if (hasActiveHouse) {
          // Casa activa - ir directamente a home
          Navigator.pushReplacementNamed(context, '/home');
          SnackBarService().showCustom(
            context,
            message: '¡Bienvenido $nickname! Acceso como invitado exitoso.',
            backgroundColor: Colors.orange[600]!,
          );
        } else {
          // No hay casa activa - ir a home selector
          Navigator.pushReplacementNamed(context, '/home-selector');
          SnackBarService().showCustom(
            context,
            message: '¡Bienvenido $nickname! Configura tu casa.',
            backgroundColor: Colors.orange[600]!,
          );
        }
      }
    } else {
      if (context.mounted) {
        SnackBarService().showError(
          context,
          result.error ?? 'Error desconocido',
        );
      }
    }
  }

  /// Realiza el proceso de unirse a una casa existente
  Future<void> performJoinHouse(
    BuildContext context,
    String houseCode,
  ) async {
    final result = await AuthService.joinHouse(houseCode);

    if (result.success) {
      if (context.mounted) {
        // Verificar si el token actualizado tiene casa activa
        final hasActiveHouse = JwtService.hasActiveHouse(result.token!);
        
        if (hasActiveHouse) {
          // Casa activa - ir directamente a home
          Navigator.pushReplacementNamed(context, '/home');
          SnackBarService().showSuccess(
            context,
            '¡Te has unido exitosamente a la casa!',
          );
        } else {
          // No hay casa activa - ir a home selector
          Navigator.pushReplacementNamed(context, '/home-selector');
          SnackBarService().showInfo(
            context,
            '¡Te has unido a la casa! Configura tu casa.',
          );
        }
      }
    } else {
      if (context.mounted) {
        SnackBarService().showError(
          context,
          result.error ?? 'Error desconocido',
        );
      }
    }
  }

  /// Maneja el proceso de "olvidé mi contraseña"
  void handleForgotPassword(BuildContext context) {
    SnackBarService().showInfo(
      context,
      'Función de recuperar contraseña próximamente',
    );
  }
}
