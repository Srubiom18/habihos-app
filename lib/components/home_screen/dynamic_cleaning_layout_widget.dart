import 'package:flutter/material.dart';
import '../../interfaces/home_screen/cleaning_area.dart';
import '../../constants/ui_constants.dart';
import 'active_cleaning_area_widget.dart';

/// Widget que maneja dinámicamente el layout de las áreas de limpieza
/// según el número de zonas disponibles
class DynamicCleaningLayoutWidget extends StatelessWidget {
  final CleaningArea currentArea;
  final List<CleaningArea> otherAreas;
  final bool isCompleted;

  const DynamicCleaningLayoutWidget({
    super.key,
    required this.currentArea,
    required this.otherAreas,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final totalAreas = 1 + otherAreas.length; // +1 por el área activa
    return _buildAreasLayout(totalAreas);
  }

  /// Construye el layout de áreas según la cantidad
  Widget _buildAreasLayout(int totalAreas) {
    switch (totalAreas) {
      case 1:
        return _buildSingleAreaWithArrowLayout();
      case 2:
        return _buildScrollableLayout();
      case 3:
        return _buildScrollableLayout();
      default:
        return _buildScrollableLayout();
    }
  }

  /// Layout para 1 zona: Área activa + flecha hacia arriba (sin scroll)
  Widget _buildSingleAreaWithArrowLayout() {
    return Column(
      children: [
        // Área activa arriba
        ActiveCleaningAreaWidget(
          currentArea: currentArea,
          isCompleted: isCompleted,
        ),
        const SizedBox(height: UIConstants.spacingMedium),
        // Flecha hacia arriba sin scroll
        Row(
          children: [
            Container(
              width: 40, // Ancho fijo para la flecha
              child: _buildUpArrow(),
            ),
          ],
        ),
      ],
    );
  }

  /// Layout para 2+ zonas: Scroll horizontal
  Widget _buildScrollableLayout() {
    return Column(
      children: [
        // Área activa arriba
        ActiveCleaningAreaWidget(
          currentArea: currentArea,
          isCompleted: isCompleted,
        ),
        const SizedBox(height: UIConstants.spacingMedium),
        // Scroll horizontal para las otras áreas con flechas indicadoras
        SizedBox(
          height: UIConstants.otherAreaHeight,
          child: otherAreas.length == 1 
              ? _buildSingleAreaInScroll()
              : _buildMultipleAreasInScroll(),
        ),
      ],
    );
  }

  /// Construye el layout cuando solo hay una área en el scroll (ocupa todo el ancho)
  Widget _buildSingleAreaInScroll() {
    return Row(
      children: [
        // Flecha hacia arriba
        Container(
          width: 40,
          margin: const EdgeInsets.only(right: UIConstants.spacingSmall),
          child: _buildUpArrow(),
        ),
        // Área ocupando el resto del ancho
        Expanded(
          child: _buildOtherAreaCard(otherAreas.first),
        ),
      ],
    );
  }

  /// Construye el layout cuando hay múltiples áreas en el scroll
  Widget _buildMultipleAreasInScroll() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: otherAreas.length * 2, // Áreas + flechas entre ellas + flecha inicial
      itemBuilder: (context, index) {
        // Si es índice 0, mostrar flecha hacia arriba
        if (index == 0) {
          return Container(
            width: 40, // Ancho fijo para la flecha
            margin: const EdgeInsets.only(right: UIConstants.spacingSmall),
            child: _buildUpArrow(),
          );
        }
        // Si es índice par (después de la flecha inicial), mostrar área
        else if ((index - 1).isEven) {
          final areaIndex = (index - 1) ~/ 2;
          return Container(
            width: MediaQuery.of(context).size.width * 0.4, // 40% del ancho de pantalla
            margin: const EdgeInsets.only(right: UIConstants.spacingSmall),
            child: _buildOtherAreaCard(otherAreas[areaIndex]),
          );
        } 
        // Si es índice impar (después de la flecha inicial), mostrar flecha
        else {
          return Container(
            width: 40, // Ancho fijo para la flecha
            margin: const EdgeInsets.only(right: UIConstants.spacingSmall),
            child: _buildRotationArrow(),
          );
        }
      },
    );
  }

  /// Construye una tarjeta para área no activa
  Widget _buildOtherAreaCard(CleaningArea area) {
    return Container(
      height: UIConstants.otherAreaHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        color: area.color.withOpacity(0.1), // Fondo con color de la zona
        border: Border.all(
          color: area.color.withOpacity(0.3), // Borde con color de la zona
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAreaIcon(area),
          const SizedBox(height: UIConstants.spacingSmall),
          _buildAreaName(area),
        ],
      ),
    );
  }

  /// Construye el icono del área
  Widget _buildAreaIcon(CleaningArea area) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingMedium),
      decoration: BoxDecoration(
        color: area.color.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: Icon(
        area.icon,
        size: UIConstants.iconSizeSmall,
        color: Colors.white,
      ),
    );
  }

  /// Construye el nombre del área
  Widget _buildAreaName(CleaningArea area) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingSmall),
      child: Text(
        area.name,
        style: TextStyle(
          fontSize: UIConstants.textSizeXXSmall,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Construye una flecha indicadora de rotación
  Widget _buildRotationArrow() {
    return Container(
      height: UIConstants.otherAreaHeight,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.grey[500],
          size: 16,
        ),
      ),
    );
  }

  /// Construye una flecha hacia arriba indicando que la zona pasará arriba
  Widget _buildUpArrow() {
    return Container(
      height: UIConstants.otherAreaHeight,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        border: Border.all(
          color: Colors.blue[200]!,
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.keyboard_arrow_up_rounded,
          color: Colors.blue[600],
          size: 20,
        ),
      ),
    );
  }
}
