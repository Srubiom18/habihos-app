import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';

/// Widget que muestra información adicional sobre las funcionalidades
class InfoCardWidget extends StatelessWidget {
  const InfoCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius + 2),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue[600],
            size: UIConstants.iconSizeMedium,
          ),
          const SizedBox(width: UIConstants.spacingMedium + 2),
          Expanded(
            child: Text(
              'Una vez configurada, podrás gestionar tareas, chat y lista de compras.',
              style: TextStyle(
                fontSize: UIConstants.textSizeNormal,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
