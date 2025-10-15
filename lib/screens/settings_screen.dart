import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';
import '../components/settings_screen/widgets/settings_widgets.dart';
import '../components/settings_screen/controllers/settings_controller.dart';

/// Pantalla principal de configuración de la aplicación
/// Diseñada con un estilo similar a los ajustes de Android
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SettingsController();
    
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: UIConstants.textColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Configuración',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: UIConstants.textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección: Casa y Participantes
              SettingsSection(
                title: 'Casa y Participantes',
                items: [
                  SettingsItemData(
                    icon: Icons.group_outlined,
                    title: 'Participantes de la Casa',
                    subtitle: 'Gestionar miembros y permisos',
                    onTap: () => controller.navigateToParticipantsConfig(context),
                  ),
                  SettingsItemData(
                    icon: Icons.cleaning_services_outlined,
                    title: 'Zonas Comunes',
                    subtitle: 'Configurar calendario de limpieza',
                    onTap: () => controller.navigateToZonasComunesConfig(context),
                  ),
                  SettingsItemData(
                    icon: Icons.cancel_outlined,
                    title: 'Cancelar Suscripción',
                    subtitle: 'Finalizar suscripción de la casa',
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    onTap: () => controller.navigateToSubscriptionConfig(context),
                  ),
                ],
              ),
              
              const SizedBox(height: UIConstants.spacingLarge),
              
              // Sección: Personalización
              SettingsSection(
                title: 'Personalización',
                items: [
                  SettingsItemData(
                    icon: Icons.palette_outlined,
                    title: 'Esquema de Colores',
                    subtitle: 'Cambiar tema y colores de la app',
                    onTap: () => controller.navigateToColorSchemeConfig(context),
                  ),
                  SettingsItemData(
                    icon: Icons.account_circle_outlined,
                    title: 'Configurar Avatar',
                    subtitle: 'Personalizar foto de perfil',
                    onTap: () => controller.navigateToAvatarConfig(context),
                  ),
                ],
              ),
              
              const SizedBox(height: UIConstants.spacingLarge),
              
              // Sección: Información
              SettingsSection(
                title: 'Información',
                items: [
                  SettingsItemData(
                    icon: Icons.info_outline,
                    title: 'Acerca de la App',
                    subtitle: 'Versión y información',
                    onTap: () => controller.showAboutDialog(context),
                  ),
                  SettingsItemData(
                    icon: Icons.help_outline,
                    title: 'Ayuda y Soporte',
                    subtitle: 'Centro de ayuda y contacto',
                    onTap: () => controller.showHelpDialog(context),
                  ),
                ],
              ),
              
              const SizedBox(height: UIConstants.spacingXLarge),
            ],
          ),
        ),
      ),
    );
  }

}
