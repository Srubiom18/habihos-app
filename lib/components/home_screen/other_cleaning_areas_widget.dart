import 'package:flutter/material.dart';
import '../../interfaces/home_screen/cleaning_area.dart';
import '../../constants/ui_constants.dart';

/// Widget que muestra las otras áreas de limpieza (las zonas no activas)
class OtherCleaningAreasWidget extends StatelessWidget {
  final List<CleaningArea> otherAreas;

  const OtherCleaningAreasWidget({
    super.key,
    required this.otherAreas,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: otherAreas.map((area) => _buildAreaCard(area)).toList(),
    );
  }

  /// Construye una tarjeta individual para un área
  Widget _buildAreaCard(CleaningArea area) {
    return Expanded(
      child: Container(
        height: UIConstants.otherAreaHeight,
        margin: const EdgeInsets.only(right: UIConstants.spacingMedium),
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
      ),
    );
  }

  /// Construye el icono del área
  Widget _buildAreaIcon(CleaningArea area) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.grey[400],
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
    return Text(
      area.name,
      style: TextStyle(
        fontSize: UIConstants.textSizeXXSmall,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
      ),
    );
  }
}
