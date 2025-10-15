import 'package:flutter/material.dart';
import '../settings_screen_components.dart';
import '../widgets/settings_dialogs.dart' as dialogs;

/// Controlador para manejar la lógica de navegación y acciones de la pantalla de settings
class SettingsController {
  /// Navega a la configuración de participantes
  void navigateToParticipantsConfig(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ParticipantsConfigScreen(),
      ),
    );
  }

  /// Navega a la configuración de zonas comunes
  void navigateToZonasComunesConfig(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ZonasComunesConfigScreen(),
      ),
    );
  }

  /// Navega a la configuración de suscripción
  void navigateToSubscriptionConfig(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SubscriptionConfigScreen(),
      ),
    );
  }

  /// Navega a la configuración de esquema de colores
  void navigateToColorSchemeConfig(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ColorSchemeConfigScreen(),
      ),
    );
  }

  /// Navega a la configuración de avatar
  void navigateToAvatarConfig(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AvatarConfigScreen(),
      ),
    );
  }

  /// Muestra el diálogo "Acerca de"
  void showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const dialogs.AboutDialog(),
    );
  }

  /// Muestra el diálogo de ayuda
  void showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const dialogs.HelpDialog(),
    );
  }
}
