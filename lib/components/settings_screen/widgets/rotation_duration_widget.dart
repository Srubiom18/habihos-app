import 'package:flutter/material.dart';
import '../../../constants/ui_constants.dart';

/// Enum para los tipos de duración de rotación predefinidos
enum RotationDurationType {
  daily('Diario', 1),
  weekly('Semanal', 7),
  monthly('Mensual', 30),
  custom('Personalizado', 0);

  const RotationDurationType(this.label, this.days);
  final String label;
  final int days;
}

/// Widget para configurar la duración de rotación de zonas comunes
class RotationDurationWidget extends StatefulWidget {
  final ValueChanged<RotationDurationType> onDurationTypeChanged;
  final ValueChanged<int> onCustomDaysChanged;
  final RotationDurationType initialDurationType;
  final int initialCustomDays;

  const RotationDurationWidget({
    super.key,
    required this.onDurationTypeChanged,
    required this.onCustomDaysChanged,
    this.initialDurationType = RotationDurationType.weekly,
    this.initialCustomDays = 7,
  });

  @override
  State<RotationDurationWidget> createState() => _RotationDurationWidgetState();
}

class _RotationDurationWidgetState extends State<RotationDurationWidget> {
  late RotationDurationType _selectedDurationType;
  late int _customDays;
  final TextEditingController _customDaysController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDurationType = widget.initialDurationType;
    _customDays = widget.initialCustomDays;
    _customDaysController.text = _customDays.toString();
  }

  @override
  void dispose() {
    _customDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Text(
          'Duración de Rotación',
          style: TextStyle(
            fontSize: UIConstants.textSizeMedium,
            fontWeight: FontWeight.w600,
            color: UIConstants.textColor,
          ),
        ),
        
        const SizedBox(height: UIConstants.spacingSmall),
        
        // Descripción
        Text(
          'Selecciona con qué frecuencia se rotarán las zonas comunes entre los usuarios.',
          style: TextStyle(
            fontSize: UIConstants.textSizeSmall,
            color: UIConstants.textColor.withOpacity(0.6),
          ),
        ),
        
        const SizedBox(height: UIConstants.spacingMedium),
        
        // Opciones de duración predefinidas
        _buildDurationOptions(),
        
        const SizedBox(height: UIConstants.spacingMedium),
        
        // Campo personalizado (solo visible si se selecciona personalizado)
        if (_selectedDurationType == RotationDurationType.custom)
          _buildCustomDurationInput(),
      ],
    );
  }

  /// Construye las opciones de duración predefinidas
  Widget _buildDurationOptions() {
    return Column(
      children: [
        // Primera fila: Diario, Semanal, Mensual
        Row(
          children: [
            Expanded(
              child: _buildDurationChip(RotationDurationType.daily),
            ),
            const SizedBox(width: UIConstants.spacingSmall),
            Expanded(
              child: _buildDurationChip(RotationDurationType.weekly),
            ),
            const SizedBox(width: UIConstants.spacingSmall),
            Expanded(
              child: _buildDurationChip(RotationDurationType.monthly),
            ),
          ],
        ),
        
        const SizedBox(height: UIConstants.spacingSmall),
        
        // Segunda fila: Personalizado (ancho completo)
        _buildDurationChip(RotationDurationType.custom),
      ],
    );
  }

  /// Construye un chip de opción de duración
  Widget _buildDurationChip(RotationDurationType type) {
    final isSelected = _selectedDurationType == type;
    final isCustom = type == RotationDurationType.custom;
    
    return GestureDetector(
      onTap: () => _selectDurationType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isCustom ? double.infinity : null, // Ancho completo para personalizado
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingMedium,
          vertical: UIConstants.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? UIConstants.primaryColor 
              : UIConstants.backgroundColor,
          borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
          border: Border.all(
            color: isSelected 
                ? UIConstants.primaryColor 
                : UIConstants.primaryColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: UIConstants.primaryColor.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: isCustom ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: isCustom ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              _getDurationIcon(type),
              size: 16,
              color: isSelected ? Colors.white : UIConstants.primaryColor,
            ),
            const SizedBox(width: UIConstants.spacingSmall),
            Text(
              type.label,
              style: TextStyle(
                fontSize: UIConstants.textSizeSmall,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : UIConstants.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el campo de entrada para duración personalizada
  Widget _buildCustomDurationInput() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(UIConstants.spacingMedium),
      decoration: BoxDecoration(
        color: UIConstants.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        border: Border.all(
          color: UIConstants.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 18,
                color: UIConstants.primaryColor,
              ),
              const SizedBox(width: UIConstants.spacingSmall),
              Text(
                'Duración Personalizada',
                style: TextStyle(
                  fontSize: UIConstants.textSizeSmall,
                  fontWeight: FontWeight.w600,
                  color: UIConstants.textColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: UIConstants.spacingSmall),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _customDaysController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Número de días',
                    hintText: 'Ej: 14',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                      borderSide: BorderSide(
                        color: UIConstants.primaryColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.spacingMedium,
                      vertical: UIConstants.spacingSmall,
                    ),
                  ),
                  onChanged: (value) {
                    final days = int.tryParse(value) ?? 0;
                    if (days > 0) {
                      setState(() {
                        _customDays = days;
                      });
                      widget.onCustomDaysChanged(days);
                    }
                  },
                ),
              ),
              
              const SizedBox(width: UIConstants.spacingMedium),
              
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.spacingMedium,
                  vertical: UIConstants.spacingSmall,
                ),
                decoration: BoxDecoration(
                  color: UIConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                ),
                child: Text(
                  'días',
                  style: TextStyle(
                    fontSize: UIConstants.textSizeSmall,
                    fontWeight: FontWeight.w500,
                    color: UIConstants.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: UIConstants.spacingSmall),
          
          Text(
            'La rotación se realizará cada $_customDays ${_customDays == 1 ? 'día' : 'días'}.',
            style: TextStyle(
              fontSize: UIConstants.textSizeXSmall,
              color: UIConstants.textColor.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene el icono correspondiente al tipo de duración
  IconData _getDurationIcon(RotationDurationType type) {
    switch (type) {
      case RotationDurationType.daily:
        return Icons.today_rounded;
      case RotationDurationType.weekly:
        return Icons.date_range_rounded;
      case RotationDurationType.monthly:
        return Icons.calendar_month_rounded;
      case RotationDurationType.custom:
        return Icons.tune_rounded;
    }
  }

  /// Selecciona un tipo de duración
  void _selectDurationType(RotationDurationType type) {
    setState(() {
      _selectedDurationType = type;
    });
    
    widget.onDurationTypeChanged(type);
    
    // Si no es personalizado, actualizar los días automáticamente
    if (type != RotationDurationType.custom) {
      setState(() {
        _customDays = type.days;
        _customDaysController.text = type.days.toString();
      });
      widget.onCustomDaysChanged(type.days);
    }
  }
}
