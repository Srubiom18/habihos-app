import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';

/// Widget que muestra el botón para crear la casa
class CreateHouseButtonWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const CreateHouseButtonWidget({
    super.key,
    required this.isLoading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: UIConstants.actionButtonHeight + 8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue[600]!,
            Colors.blue[700]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: UIConstants.iconSizeMedium,
                width: UIConstants.iconSizeMedium,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.home,
                    color: Colors.white,
                    size: UIConstants.iconSizeMedium + 2,
                  ),
                  const SizedBox(width: UIConstants.spacingMedium),
                  const Text(
                    'Crear Casa',
                    style: TextStyle(
                      fontSize: UIConstants.textSizeMedium,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
