import 'package:flutter/material.dart';

/// Diálogo "Acerca de" para mostrar información de la aplicación
class AboutDialog extends StatelessWidget {
  const AboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Acerca de la App'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gestión de Casa Compartida'),
          SizedBox(height: 8),
          Text('Versión: 1.0.0'),
          SizedBox(height: 8),
          Text('Una aplicación para gestionar tareas y comunicación en casas compartidas.'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

/// Diálogo de ayuda y soporte
class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ayuda y Soporte'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('¿Necesitas ayuda?'),
          SizedBox(height: 8),
          Text('• Contacto: soporte@micasaapp.com'),
          Text('• Teléfono: +1 (555) 123-4567'),
          Text('• Horario: Lunes a Viernes 9:00 - 18:00'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
