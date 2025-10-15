import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';

/// Widget que muestra el header de bienvenida con icono y texto
class WelcomeHeaderWidget extends StatelessWidget {
  const WelcomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icono principal
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(60),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.home_outlined,
            size: 60,
            color: Colors.blue[600],
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Título
        Text(
          'Configura tu Casa',
          style: TextStyle(
            fontSize: UIConstants.textSizeLarge + 4,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: UIConstants.spacingLarge),
        
        // Subtítulo
        Text(
          'Parece que aún no tienes una casa configurada.\nVamos a crear una para ti.',
          style: TextStyle(
            fontSize: UIConstants.textSizeLarge - 8,
            color: Colors.grey[600],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
