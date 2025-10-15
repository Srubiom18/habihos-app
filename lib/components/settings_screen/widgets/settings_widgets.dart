import 'package:flutter/material.dart';
import '../../../constants/ui_constants.dart';

/// Widget que construye el encabezado de una sección
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: UIConstants.screenPadding,
        bottom: UIConstants.spacingMedium,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: UIConstants.textSizeMedium,
          fontWeight: FontWeight.w600,
          color: UIConstants.textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Widget que construye una tarjeta contenedora para las opciones de configuración
class SectionCard extends StatelessWidget {
  final List<Widget> children;

  const SectionCard({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

/// Widget que construye un elemento individual de configuración
class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingLarge),
        child: Row(
          children: [
            // Icono
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? UIConstants.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
              ),
              child: Icon(
                icon,
                color: iconColor ?? UIConstants.primaryColor,
                size: 20,
              ),
            ),
            
            const SizedBox(width: UIConstants.spacingLarge),
            
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: UIConstants.textSizeMedium,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? UIConstants.textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: UIConstants.textSizeSmall,
                      color: UIConstants.textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            
            // Flecha de navegación
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: UIConstants.textColor.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget que construye un divisor entre elementos
class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingLarge),
      child: Divider(
        height: 1,
        color: UIConstants.textColor.withOpacity(0.1),
      ),
    );
  }
}

/// Widget que construye una sección completa de configuración
class SettingsSection extends StatelessWidget {
  final String title;
  final List<SettingsItemData> items;

  const SettingsSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        SectionCard(
          children: _buildSectionItems(),
        ),
      ],
    );
  }

  List<Widget> _buildSectionItems() {
    final List<Widget> widgets = [];
    
    for (int i = 0; i < items.length; i++) {
      widgets.add(SettingsItem(
        icon: items[i].icon,
        title: items[i].title,
        subtitle: items[i].subtitle,
        onTap: items[i].onTap,
        iconColor: items[i].iconColor,
        textColor: items[i].textColor,
      ));
      
      // Agregar divisor si no es el último elemento
      if (i < items.length - 1) {
        widgets.add(const SettingsDivider());
      }
    }
    
    return widgets;
  }
}

/// Clase de datos para representar un elemento de configuración
class SettingsItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const SettingsItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });
}
