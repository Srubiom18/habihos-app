import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import 'cleaning_area_form_widget.dart';

/// Widget que maneja la sección de áreas de limpieza
class CleaningAreasSectionWidget extends StatelessWidget {
  final List<CleaningAreaForm> cleaningAreas;
  final VoidCallback onAddArea;
  final Function(int) onRemoveArea;

  const CleaningAreasSectionWidget({
    super.key,
    required this.cleaningAreas,
    required this.onAddArea,
    required this.onRemoveArea,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de la sección
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Áreas de Limpieza',
                  style: TextStyle(
                    fontSize: UIConstants.textSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: UIConstants.spacingSmall),
                Text(
                  'Agrega las áreas que necesitan limpieza',
                  style: TextStyle(
                    fontSize: UIConstants.textSizeSmall,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (cleaningAreas.length < 5)
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: onAddArea,
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: UIConstants.iconSizeMedium,
                  ),
                  tooltip: 'Agregar área',
                ),
              ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingXLarge),
        
        // Lista de áreas de limpieza
        ...List.generate(cleaningAreas.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: UIConstants.spacingLarge),
            child: CleaningAreaFormWidget(
              cleaningArea: cleaningAreas[index],
              index: index,
              canRemove: cleaningAreas.length > 1,
              onRemove: () => onRemoveArea(index),
            ),
          );
        }),
      ],
    );
  }
}
