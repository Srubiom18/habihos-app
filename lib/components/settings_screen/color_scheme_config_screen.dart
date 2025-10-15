import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import '../../services/common/snackbar_service.dart';

/// Pantalla de configuración de esquema de colores
class ColorSchemeConfigScreen extends StatefulWidget {
  const ColorSchemeConfigScreen({super.key});

  @override
  State<ColorSchemeConfigScreen> createState() => _ColorSchemeConfigScreenState();
}

class _ColorSchemeConfigScreenState extends State<ColorSchemeConfigScreen> {
  // Esquemas de colores predefinidos
  final List<ColorScheme> _colorSchemes = [
    const ColorScheme(
      name: 'Azul Clásico',
      primary: UIConstants.primaryColor,
      secondary: Color(0xFF6C63FF),
      accent: Color(0xFF4FC3F7),
      description: 'El esquema original de la app',
      isDefault: true,
    ),
    const ColorScheme(
      name: 'Verde Naturaleza',
      primary: Color(0xFF2E7D32),
      secondary: Color(0xFF4CAF50),
      accent: Color(0xFF81C784),
      description: 'Perfecto para espacios tranquilos',
    ),
    const ColorScheme(
      name: 'Púrpura Elegante',
      primary: Color(0xFF673AB7),
      secondary: Color(0xFF9C27B0),
      accent: Color(0xFFBA68C8),
      description: 'Un toque de sofisticación',
    ),
    const ColorScheme(
      name: 'Naranja Energía',
      primary: Color(0xFFFF6F00),
      secondary: Color(0xFFFF9800),
      accent: Color(0xFFFFB74D),
      description: 'Lleno de vitalidad y dinamismo',
    ),
    const ColorScheme(
      name: 'Rosa Suave',
      primary: Color(0xFFE91E63),
      secondary: Color(0xFFF06292),
      accent: Color(0xFFF8BBD9),
      description: 'Dulce y acogedor',
    ),
    const ColorScheme(
      name: 'Azul Marino',
      primary: Color(0xFF1565C0),
      secondary: Color(0xFF1976D2),
      accent: Color(0xFF64B5F6),
      description: 'Profesional y confiable',
    ),
    const ColorScheme(
      name: 'Tierra Cálida',
      primary: Color(0xFF5D4037),
      secondary: Color(0xFF8D6E63),
      accent: Color(0xFFA1887F),
      description: 'Colores terrosos y naturales',
    ),
    const ColorScheme(
      name: 'Cian Moderno',
      primary: Color(0xFF0097A7),
      secondary: Color(0xFF00BCD4),
      accent: Color(0xFF4DD0E1),
      description: 'Frescura y modernidad',
    ),
  ];

  ColorScheme _selectedScheme = const ColorScheme(
    name: 'Azul Clásico',
    primary: UIConstants.primaryColor,
    secondary: Color(0xFF6C63FF),
    accent: Color(0xFF4FC3F7),
    description: 'El esquema original de la app',
    isDefault: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: UIConstants.textColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Esquema de Colores',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: UIConstants.textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Vista previa del esquema actual
          _buildPreviewSection(),
          
          // Lista de esquemas disponibles
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(UIConstants.screenPadding),
              itemCount: _colorSchemes.length,
              itemBuilder: (context, index) {
                final scheme = _colorSchemes[index];
                final isSelected = scheme.name == _selectedScheme.name;
                
                return _buildColorSchemeCard(scheme, isSelected);
              },
            ),
          ),
          
          // Botón de aplicar
          _buildApplyButton(),
        ],
      ),
    );
  }

  /// Construye la sección de vista previa
  Widget _buildPreviewSection() {
    return Container(
      margin: const EdgeInsets.all(UIConstants.screenPadding),
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vista Previa',
            style: TextStyle(
              fontSize: UIConstants.textSizeLarge,
              fontWeight: FontWeight.w600,
              color: UIConstants.textColor,
            ),
          ),
          const SizedBox(height: UIConstants.spacingLarge),
          
          // Paleta de colores
          Row(
            children: [
              _buildColorPreview('Primario', _selectedScheme.primary),
              const SizedBox(width: UIConstants.spacingMedium),
              _buildColorPreview('Secundario', _selectedScheme.secondary),
              const SizedBox(width: UIConstants.spacingMedium),
              _buildColorPreview('Acento', _selectedScheme.accent),
            ],
          ),
          
          const SizedBox(height: UIConstants.spacingLarge),
          
          // Ejemplo de componente
          _buildComponentPreview(),
        ],
      ),
    );
  }

  /// Construye una vista previa de color
  Widget _buildColorPreview(String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          const SizedBox(height: UIConstants.spacingSmall),
          Text(
            label,
            style: const TextStyle(
              fontSize: UIConstants.textSizeXSmall,
              color: UIConstants.textColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una vista previa de componente
  Widget _buildComponentPreview() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _selectedScheme.primary,
            _selectedScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
            ),
            child: const Icon(
              Icons.home_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: UIConstants.spacingLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ejemplo de Componente',
                  style: TextStyle(
                    fontSize: UIConstants.textSizeMedium,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Así se verán los elementos con este esquema',
                  style: TextStyle(
                    fontSize: UIConstants.textSizeSmall,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.spacingMedium,
              vertical: UIConstants.spacingSmall,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'ACTIVO',
              style: TextStyle(
                fontSize: UIConstants.textSizeXSmall,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta de esquema de color
  Widget _buildColorSchemeCard(ColorScheme scheme, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        border: Border.all(
          color: isSelected ? scheme.primary : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedScheme = scheme),
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Paleta de colores
                  Row(
                    children: [
                      _buildColorDot(scheme.primary),
                      const SizedBox(width: 8),
                      _buildColorDot(scheme.secondary),
                      const SizedBox(width: 8),
                      _buildColorDot(scheme.accent),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Indicador de selección
                  if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    )
                  else
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: UIConstants.spacingMedium),
              
              // Información del esquema
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              scheme.name,
                              style: const TextStyle(
                                fontSize: UIConstants.textSizeLarge,
                                fontWeight: FontWeight.w600,
                                color: UIConstants.textColor,
                              ),
                            ),
                            if (scheme.isDefault) ...[
                              const SizedBox(width: UIConstants.spacingSmall),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: UIConstants.spacingSmall,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: UIConstants.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'POR DEFECTO',
                                  style: TextStyle(
                                    fontSize: UIConstants.textSizeXSmall,
                                    fontWeight: FontWeight.w600,
                                    color: UIConstants.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          scheme.description,
                          style: TextStyle(
                            fontSize: UIConstants.textSizeSmall,
                            color: UIConstants.textColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye un punto de color
  Widget _buildColorDot(Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
    );
  }

  /// Construye el botón de aplicar
  Widget _buildApplyButton() {
    final isChanged = _selectedScheme.name != 'Azul Clásico';
    
    return Container(
      padding: const EdgeInsets.all(UIConstants.screenPadding),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isChanged ? _applyColorScheme : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isChanged ? _selectedScheme.primary : Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingLarge),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
            ),
          ),
          child: Text(
            isChanged ? 'Aplicar Esquema de Colores' : 'Esquema Actual Activo',
            style: const TextStyle(
              fontSize: UIConstants.textSizeMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Aplica el esquema de colores seleccionado
  void _applyColorScheme() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aplicar Esquema de Colores'),
        content: Text(
          '¿Estás seguro de que quieres cambiar el esquema de colores a "${_selectedScheme.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              SnackBarService().showSuccess(
                context,
                'Esquema de colores "${_selectedScheme.name}" aplicado correctamente',
              );
              // Aquí se implementaría la lógica para cambiar el tema global de la app
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}

/// Modelo de datos para un esquema de colores
class ColorScheme {
  final String name;
  final Color primary;
  final Color secondary;
  final Color accent;
  final String description;
  final bool isDefault;

  const ColorScheme({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.description,
    this.isDefault = false,
  });
}
