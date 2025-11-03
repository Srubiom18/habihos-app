import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../interfaces/home_screen/cleaning_area.dart';
import '../../constants/ui_constants.dart';

/// Widget que maneja dinámicamente el layout de las áreas de limpieza
/// según el número de zonas disponibles
class DynamicCleaningLayoutWidget extends StatefulWidget {
  final CleaningArea currentArea;
  final List<CleaningArea> otherAreas;
  final bool isCompleted;
  final VoidCallback? onMarkAsCompleted;

  const DynamicCleaningLayoutWidget({
    super.key,
    required this.currentArea,
    required this.otherAreas,
    required this.isCompleted,
    this.onMarkAsCompleted,
  });

  @override
  State<DynamicCleaningLayoutWidget> createState() => _DynamicCleaningLayoutWidgetState();
}

class _DynamicCleaningLayoutWidgetState extends State<DynamicCleaningLayoutWidget> {

  @override
  Widget build(BuildContext context) {
    // Crear una lista con todas las áreas (activa + otras)
    final allAreas = [widget.currentArea, ...widget.otherAreas];
    
    return Column(
      children: [
        // Scroll horizontal con todas las áreas como cards elegantes
        _buildElegantScrollLayout(allAreas),
        
        const SizedBox(height: UIConstants.spacingLarge),
        
        // Información de rotación
        _buildRotationInfo(),
        
        const SizedBox(height: 50),
        
        // Botón de acción
        _buildActionButton(),
      ],
    );
  }

  /// Construye el layout elegante con scroll horizontal
  Widget _buildElegantScrollLayout(List<CleaningArea> allAreas) {
    // Si solo hay 1 área, ocupar todo el ancho disponible
    final bool isSingleCard = allAreas.length == 1;
    
    return SizedBox(
      height: 200, // Altura fija para las cards elegantes
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allAreas.length * 2 - 1, // Cards + flechas entre ellas
        itemBuilder: (context, index) {
          // Si es índice par, mostrar card
          if (index.isEven) {
            final areaIndex = index ~/ 2;
            final area = allAreas[areaIndex];
            final isCurrentArea = area.id == widget.currentArea.id;
            
            // Si solo hay 1 card, ocupar todo el ancho menos los paddings laterales
            final double cardWidth = isSingleCard 
                ? MediaQuery.of(context).size.width - (UIConstants.screenPadding * 2)
                : MediaQuery.of(context).size.width * 0.75;
            
            return Container(
              width: cardWidth,
              margin: EdgeInsets.only(
                left: areaIndex == 0 ? UIConstants.spacingMedium : UIConstants.spacingMedium / 2,
                right: areaIndex == allAreas.length - 1 ? UIConstants.spacingMedium : UIConstants.spacingMedium / 2,
              ),
              child: _buildElegantAreaCard(area, isCurrentArea, areaIndex, allAreas),
            );
          } 
          // Si es índice impar, mostrar flecha
          else {
            return Container(
              width: 40,
              margin: const EdgeInsets.symmetric(horizontal: UIConstants.spacingMedium / 2),
              child: _buildRotationArrow(),
            );
          }
        },
      ),
    );
  }

  /// Construye una card elegante para el área
  Widget _buildElegantAreaCard(CleaningArea area, bool isCurrentArea, int index, List<CleaningArea> allAreas) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        color: area.color.withOpacity(0.15), // Color de fondo suave
        border: Border.all(
          color: isCurrentArea 
              ? area.color 
              : area.color.withOpacity(0.5),
          width: 3, // Mismo grosor para todas las cards
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                // Header con icono y nombre
                Row(
                  children: [
                    _buildElegantAreaIcon(area, isCurrentArea),
                    const SizedBox(width: UIConstants.spacingMedium),
                    Expanded(
                      child: Text(
                        area.name,
                        style: const TextStyle(
                          fontSize: UIConstants.textSizeLarge,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
            
                const SizedBox(height: UIConstants.spacingMedium),
                
                // Información detallada del área
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Descripción
                    Text(
                      area.description.isNotEmpty 
                          ? area.description 
                          : 'Sin descripción',
                      style: TextStyle(
                        fontSize: UIConstants.textSizeSmall,
                        color: area.description.isNotEmpty 
                            ? Colors.black54 
                            : Colors.black38,
                        height: 1.3,
                        fontStyle: area.description.isEmpty 
                            ? FontStyle.italic 
                            : FontStyle.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Tags según la posición en la rotación
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildRotationTag(index, allAreas, isCurrentArea, area),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  /// Construye el tag según la posición en la rotación
  Widget _buildRotationTag(int index, List<CleaningArea> allAreas, bool isCurrentArea, CleaningArea area) {
    // Si es la zona actual, mostrar dos tags
    if (isCurrentArea) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildCurrentZoneTag(area),
          const SizedBox(height: UIConstants.spacingSmall),
          _buildStatusTag(widget.isCompleted, area),
        ],
      );
    }
    
    // Si es la siguiente zona (índice 1)
    if (index == 1) {
      return _buildNextTag(area);
    }
    
    // Si está más adelante en la rotación, mostrar después de qué zona
    if (index > 1) {
      final previousArea = allAreas[index - 1];
      return _buildAfterTag(previousArea.name, area);
    }
    
    // Default (no debería ocurrir)
    return const SizedBox.shrink();
  }

  /// Construye el tag de estado elegante
  Widget _buildStatusTag(bool isCompleted, CleaningArea area) {
    // Si está completada, usar color dorado, sino usar el color del área más oscuro
    final tagColor = isCompleted ? Colors.amber : _darkenColor(area.color);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingMedium,
        vertical: UIConstants.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        boxShadow: [
          BoxShadow(
            color: tagColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.hourglass_empty,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: UIConstants.spacingSmall),
          Text(
            isCompleted ? 'Completada' : 'En progreso',
            style: const TextStyle(
              fontSize: UIConstants.textSizeSmall,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el tag para la siguiente zona
  Widget _buildNextTag(CleaningArea area) {
    // Usar el color del área más oscuro para el tag
    final tagColor = _darkenColor(area.color);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingMedium,
        vertical: UIConstants.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        boxShadow: [
          BoxShadow(
            color: tagColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.arrow_forward,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: UIConstants.spacingSmall),
          const Text(
            'Siguiente zona para limpiar',
            style: TextStyle(
              fontSize: UIConstants.textSizeSmall,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el tag "Después de {zona}"
  Widget _buildAfterTag(String previousAreaName, CleaningArea area) {
    // Usar el color del área más oscuro para el tag
    final tagColor = _darkenColor(area.color);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingMedium,
        vertical: UIConstants.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        boxShadow: [
          BoxShadow(
            color: tagColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: UIConstants.spacingSmall),
          Flexible(
            child: Text(
              'Después de $previousAreaName',
              style: const TextStyle(
                fontSize: UIConstants.textSizeSmall,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el tag para la zona actual
  Widget _buildCurrentZoneTag(CleaningArea area) {
    // Usar el color del área más oscuro para el tag
    final tagColor = _darkenColor(area.color);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingMedium,
        vertical: UIConstants.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        boxShadow: [
          BoxShadow(
            color: tagColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.home,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: UIConstants.spacingSmall),
          const Text(
            'Zona actual que limpiar',
            style: TextStyle(
              fontSize: UIConstants.textSizeSmall,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Oscurece un color para crear variación
  Color _darkenColor(Color color) {
    // Reducir la luminosidad del color para oscurecerlo
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness * 0.6).clamp(0.0, 1.0)).toColor();
  }

  /// Construye el icono elegante del área
  Widget _buildElegantAreaIcon(CleaningArea area, bool isCurrentArea) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingMedium),
      decoration: BoxDecoration(
        color: area.color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: area.color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        area.icon,
        size: UIConstants.iconSizeMedium,
        color: Colors.white,
      ),
    );
  }

  /// Construye la información de rotación
  Widget _buildRotationInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.15), // Mismo estilo que los separadores
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 3, // Mismo grosor que las cards y separadores
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.rotate_right,
            color: Colors.grey[700],
            size: UIConstants.iconSizeMedium,
          ),
          const SizedBox(width: UIConstants.spacingMedium),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Las zonas rotan automáticamente ',
                style: TextStyle(
                  fontSize: UIConstants.textSizeNormal,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: 'cada semana',
                    style: TextStyle(
                      fontSize: UIConstants.textSizeNormal,
                      color: Colors.grey[900],
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  TextSpan(
                    text: ' para mantener una distribución equitativa.',
                    style: TextStyle(
                      fontSize: UIConstants.textSizeNormal,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el botón de acción
  Widget _buildActionButton() {
    if (widget.isCompleted) {
      return _buildCompletedButton();
    } else {
      return _buildActiveSlider();
    }
  }

  /// Construye el botón activo (para marcar como completado)
  Widget _buildActiveSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingMedium),
      child: SizedBox(
        height: UIConstants.actionButtonHeight,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: widget.onMarkAsCompleted,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.currentArea.color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
            ),
            elevation: 4,
            shadowColor: widget.currentArea.color.withOpacity(0.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: UIConstants.iconSizeMedium,
              ),
              const SizedBox(width: UIConstants.spacingSmall),
              Text(
                'Confirmar tarea',
                style: TextStyle(
                  fontSize: UIConstants.textSizeNormal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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
          borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
          border: Border.all(color: UIConstants.completedButtonBorder),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.amber[700],
                size: UIConstants.iconSizeMedium,
              ),
              const SizedBox(width: UIConstants.spacingMedium),
              Text(
                '¡Área completada!',
                style: TextStyle(
                  color: Colors.amber[700],
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

  /// Construye una flecha indicadora de rotación
  Widget _buildRotationArrow() {
    return Container(
      height: 200, // Misma altura que las cards
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.15), // Mismo estilo que las cards
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 3, // Mismo grosor que las cards
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.grey[700],
          size: 20,
        ),
      ),
    );
  }
}
