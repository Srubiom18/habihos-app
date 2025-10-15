import 'package:flutter/material.dart';
import '../../interfaces/home_screen/cleaning_area.dart';
import '../../constants/ui_constants.dart';

/// Widget que muestra el botón de acción inferior
class ActionButtonWidget extends StatefulWidget {
  final CleaningArea currentArea;
  final bool isCompleted;
  final bool isValidIndex;
  final VoidCallback? onPressed;

  const ActionButtonWidget({
    super.key,
    required this.currentArea,
    required this.isCompleted,
    required this.isValidIndex,
    this.onPressed,
  });

  @override
  State<ActionButtonWidget> createState() => _ActionButtonWidgetState();
}

class _ActionButtonWidgetState extends State<ActionButtonWidget> {
  double _dragPosition = 0.0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return _buildButton();
  }

  /// Construye el botón apropiado según el estado
  Widget _buildButton() {
    if (widget.isValidIndex && !widget.isCompleted) {
      return _buildActiveSlider();
    } else if (widget.isCompleted) {
      return _buildCompletedButton();
    } else {
      return const SizedBox.shrink();
    }
  }

  /// Construye el slider activo (para marcar como completado)
  Widget _buildActiveSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingMedium),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxDrag = constraints.maxWidth - UIConstants.actionButtonHeight;
          final progress = _dragPosition / maxDrag;
          
          return Container(
            height: UIConstants.actionButtonHeight,
            width: double.infinity,
            decoration: BoxDecoration(
            color: widget.currentArea.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
            border: Border.all(
              color: widget.currentArea.color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              // Barra de progreso
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: widget.currentArea.color.withOpacity(progress * 0.3),
                      borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius - 4),
                    ),
                  ),
                ),
              ),
              
              // Texto central
              Center(
                child: Opacity(
                  opacity: 1 - (progress * 1.5).clamp(0.0, 1.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swipe,
                        color: widget.currentArea.color,
                        size: UIConstants.iconSizeSmall,
                      ),
                      const SizedBox(width: UIConstants.spacingSmall),
                      Text(
                        'Desliza para confirmar',
                        style: TextStyle(
                          color: widget.currentArea.color,
                          fontSize: UIConstants.textSizeNormal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bola deslizante
              AnimatedPositioned(
                duration: _isDragging 
                    ? Duration.zero 
                    : const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                left: _dragPosition,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onHorizontalDragStart: (_) {
                    setState(() {
                      _isDragging = true;
                    });
                  },
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragPosition = (_dragPosition + details.delta.dx)
                          .clamp(0.0, maxDrag);
                    });
                  },
                  onHorizontalDragEnd: (_) {
                    setState(() {
                      _isDragging = false;
                      // Si llegó al final (90% o más), ejecutar la acción
                      if (_dragPosition >= maxDrag * 0.9) {
                        widget.onPressed?.call();
                      }
                      // Volver al inicio
                      _dragPosition = 0.0;
                    });
                  },
                  child: Container(
                    width: UIConstants.actionButtonHeight,
                    height: UIConstants.actionButtonHeight,
                    decoration: BoxDecoration(
                      color: widget.currentArea.color,
                      borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: widget.currentArea.color.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      progress > 0.9 ? Icons.check_circle : Icons.chevron_right,
                      color: Colors.white,
                      size: UIConstants.iconSizeMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        },
      ),
    );
  }

  /// Construye el botón de completado
  Widget _buildCompletedButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingMedium),
      child: Container(
        height: UIConstants.actionButtonHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: UIConstants.completedButtonBackground,
          borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
          border: Border.all(color: UIConstants.completedButtonBorder),
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: UIConstants.iconSizeMedium,
              ),
              SizedBox(width: UIConstants.spacingMedium),
              Text(
                '¡Área completada!',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: UIConstants.textSizeNormal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
