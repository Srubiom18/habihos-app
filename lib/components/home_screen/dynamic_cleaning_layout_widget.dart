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
        return _buildSingleAreaLayout();
      case 2:
        return _buildTwoAreasLayout();
      case 3:
        return _buildThreeAreasLayout();
      default:
        return _buildScrollableLayout();
    }
  }

  /// Layout para 1 zona: Solo el área activa
  Widget _buildSingleAreaLayout() {
    return ActiveCleaningAreaWidget(
      currentArea: currentArea,
      isCompleted: isCompleted,
    );
  }

  /// Layout para 2 zonas: Una debajo de la otra
  Widget _buildTwoAreasLayout() {
    return Column(
      children: [
        // Área activa arriba
        ActiveCleaningAreaWidget(
          currentArea: currentArea,
          isCompleted: isCompleted,
        ),
        const SizedBox(height: UIConstants.spacingMedium),
        // Otra área abajo ocupando todo el ancho
        SizedBox(
          width: double.infinity,
          child: _buildOtherAreaCard(otherAreas.first),
        ),
      ],
    );
  }

  /// Layout para 3 zonas: Principal arriba, 2 abajo con espacio entre ellas
  Widget _buildThreeAreasLayout() {
    return Column(
      children: [
        // Área activa arriba
        ActiveCleaningAreaWidget(
          currentArea: currentArea,
          isCompleted: isCompleted,
        ),
        const SizedBox(height: UIConstants.spacingMedium),
        // Dos áreas abajo con espacio entre ellas
        Row(
          children: [
            Expanded(
              child: _buildOtherAreaCard(otherAreas[0]),
            ),
            const SizedBox(width: UIConstants.spacingMedium),
            Expanded(
              child: _buildOtherAreaCard(otherAreas[1]),
            ),
          ],
        ),
      ],
    );
  }

  /// Layout para 4+ zonas: Scroll horizontal
  Widget _buildScrollableLayout() {
    return Column(
      children: [
        // Área activa arriba
        ActiveCleaningAreaWidget(
          currentArea: currentArea,
          isCompleted: isCompleted,
        ),
        const SizedBox(height: UIConstants.spacingMedium),
        // Scroll horizontal para las otras áreas
        SizedBox(
          height: UIConstants.otherAreaHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: otherAreas.length,
            itemBuilder: (context, index) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.4, // 40% del ancho de pantalla
                margin: EdgeInsets.only(
                  right: index < otherAreas.length - 1 ? UIConstants.spacingMedium : 0,
                ),
                child: _buildOtherAreaCard(otherAreas[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Construye una tarjeta para área no activa
  Widget _buildOtherAreaCard(CleaningArea area) {
    return Container(
      height: UIConstants.otherAreaHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        color: UIConstants.containerBackgroundColor,
        border: Border.all(
          color: UIConstants.defaultBorderColor,
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
}
