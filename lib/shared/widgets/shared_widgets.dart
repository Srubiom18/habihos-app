/// Widgets reutilizables compartidos en toda la aplicación
/// 
/// Este archivo contiene widgets comunes que pueden ser utilizados
/// en múltiples features para mantener consistencia y reutilización.

import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';

/// Botón primario estándar reutilizable
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: UIConstants.actionButtonHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
        boxShadow: UIConstants.buttonShadow,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? UIConstants.primaryColor,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: UIConstants.textSizeMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Botón secundario estándar reutilizable
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? borderColor;
  final Color? textColor;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: UIConstants.actionButtonHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
        border: Border.all(
          color: borderColor ?? UIConstants.primaryColor,
          width: 1.5,
        ),
      ),
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? UIConstants.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
          ),
          side: BorderSide.none,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? UIConstants.primaryColor,
                  ),
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: UIConstants.textSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? UIConstants.primaryColor,
                ),
              ),
      ),
    );
  }
}

/// Card estándar reutilizable
class StandardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const StandardCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: UIConstants.containerBackgroundColor,
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        boxShadow: UIConstants.defaultShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(UIConstants.spacingLarge),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Loading indicator estándar
class StandardLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const StandardLoadingIndicator({
    super.key,
    this.message,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(UIConstants.primaryColor),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: UIConstants.spacingLarge),
            Text(
              message!,
              style: const TextStyle(
                fontSize: UIConstants.textSizeMedium,
                color: UIConstants.textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Error widget estándar
class StandardErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const StandardErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Reintentar',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: UIConstants.iconSizeLarge,
              color: Colors.red[400],
            ),
            const SizedBox(height: UIConstants.spacingLarge),
            Text(
              message,
              style: const TextStyle(
                fontSize: UIConstants.textSizeMedium,
                color: UIConstants.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: UIConstants.spacingXLarge),
              SecondaryButton(
                label: retryLabel!,
                onPressed: onRetry!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
