import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import '../../services/common/snackbar_service.dart';

/// Pantalla de configuración de avatar
class AvatarConfigScreen extends StatefulWidget {
  const AvatarConfigScreen({super.key});

  @override
  State<AvatarConfigScreen> createState() => _AvatarConfigScreenState();
}

class _AvatarConfigScreenState extends State<AvatarConfigScreen> {
  // Opciones de avatar disponibles
  final List<AvatarOption> _avatarOptions = [
    const AvatarOption(
      type: AvatarType.icon,
      name: 'Icono Predeterminado',
      icon: Icons.person_rounded,
      color: UIConstants.primaryColor,
      isDefault: true,
    ),
    const AvatarOption(
      type: AvatarType.icon,
      name: 'Casa',
      icon: Icons.home_rounded,
      color: Colors.brown,
    ),
    const AvatarOption(
      type: AvatarType.icon,
      name: 'Usuario',
      icon: Icons.account_circle_rounded,
      color: Colors.blue,
    ),
    const AvatarOption(
      type: AvatarType.icon,
      name: 'Estrella',
      icon: Icons.star_rounded,
      color: Colors.amber,
    ),
    const AvatarOption(
      type: AvatarType.icon,
      name: 'Corazón',
      icon: Icons.favorite_rounded,
      color: Colors.red,
    ),
    const AvatarOption(
      type: AvatarType.icon,
      name: 'Sol',
      icon: Icons.wb_sunny_rounded,
      color: Colors.orange,
    ),
    const AvatarOption(
      type: AvatarType.icon,
      name: 'Luna',
      icon: Icons.nightlight_round,
      color: Colors.indigo,
    ),
    const AvatarOption(
      type: AvatarType.icon,
      name: 'Rayo',
      icon: Icons.flash_on_rounded,
      color: Colors.yellow,
    ),
  ];

  AvatarOption _selectedAvatar = const AvatarOption(
    type: AvatarType.icon,
    name: 'Icono Predeterminado',
    icon: Icons.person_rounded,
    color: UIConstants.primaryColor,
    isDefault: true,
  );

  Color _selectedColor = UIConstants.primaryColor;
  bool _isLoading = false;

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
          'Configurar Avatar',
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
          // Vista previa del avatar
          _buildPreviewSection(),
          
          // Lista de opciones de avatar
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(UIConstants.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de iconos
                  _buildSectionHeader('Iconos Disponibles'),
                  _buildIconGrid(),
                  
                  const SizedBox(height: UIConstants.spacingLarge),
                  
                  // Sección de colores
                  _buildSectionHeader('Colores'),
                  _buildColorGrid(),
                  
                  const SizedBox(height: UIConstants.spacingLarge),
                  
                  // Sección de foto personalizada
                  _buildSectionHeader('Foto Personalizada'),
                  _buildCustomPhotoSection(),
                  
                  const SizedBox(height: UIConstants.spacingXLarge),
                ],
              ),
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
          
          // Avatar grande
          _buildLargeAvatar(),
          
          const SizedBox(height: UIConstants.spacingLarge),
          
          // Avatar mediano (como aparece en el header)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'En el header: ',
                style: TextStyle(
                  fontSize: UIConstants.textSizeSmall,
                  color: UIConstants.textColor,
                ),
              ),
              _buildMediumAvatar(),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye un avatar grande para vista previa
  Widget _buildLargeAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _selectedColor,
            _selectedColor.withOpacity(0.8),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _selectedColor.withOpacity(0.4),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        _selectedAvatar.icon,
        color: Colors.white,
        size: 60,
      ),
    );
  }

  /// Construye un avatar mediano (como en el header)
  Widget _buildMediumAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _selectedColor,
            _selectedColor.withOpacity(0.8),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _selectedColor.withOpacity(0.4),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        _selectedAvatar.icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  /// Construye el encabezado de una sección
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingMedium),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: UIConstants.textSizeMedium,
          fontWeight: FontWeight.w600,
          color: UIConstants.textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Construye la cuadrícula de iconos
  Widget _buildIconGrid() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingMedium),
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
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: UIConstants.spacingMedium,
          mainAxisSpacing: UIConstants.spacingMedium,
          childAspectRatio: 1,
        ),
        itemCount: _avatarOptions.length,
        itemBuilder: (context, index) {
          final option = _avatarOptions[index];
          final isSelected = option.name == _selectedAvatar.name;
          
          return _buildIconOption(option, isSelected);
        },
      ),
    );
  }

  /// Construye una opción de icono
  Widget _buildIconOption(AvatarOption option, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _selectedAvatar = option),
      borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? _selectedColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
          border: Border.all(
            color: isSelected ? _selectedColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              option.icon,
              color: isSelected ? _selectedColor : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              option.name,
              style: TextStyle(
                fontSize: UIConstants.textSizeXSmall,
                color: isSelected ? _selectedColor : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la cuadrícula de colores
  Widget _buildColorGrid() {
    final colors = [
      UIConstants.primaryColor,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
      Colors.amber,
      Colors.cyan,
    ];

    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingMedium),
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
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: UIConstants.spacingMedium,
          mainAxisSpacing: UIConstants.spacingMedium,
          childAspectRatio: 1,
        ),
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = color.value == _selectedColor.value;
          
          return InkWell(
            onTap: () => setState(() => _selectedColor = color),
            borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 3,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  /// Construye la sección de foto personalizada
  Widget _buildCustomPhotoSection() {
    return Container(
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
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: UIConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  color: UIConstants.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: UIConstants.spacingLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Foto Personalizada',
                      style: TextStyle(
                        fontSize: UIConstants.textSizeMedium,
                        fontWeight: FontWeight.w500,
                        color: UIConstants.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Usar una foto de tu galería como avatar',
                      style: TextStyle(
                        fontSize: UIConstants.textSizeSmall,
                        color: UIConstants.textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _selectCustomPhoto,
                icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                label: const Text('Seleccionar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.spacingMedium,
                    vertical: UIConstants.spacingSmall,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye el botón de aplicar
  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.screenPadding),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _applyAvatar,
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingLarge),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Aplicar Avatar',
                  style: TextStyle(
                    fontSize: UIConstants.textSizeMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  /// Selecciona una foto personalizada
  void _selectCustomPhoto() {
    SnackBarService().showInfo(
      context,
      'Función de foto personalizada próximamente disponible',
    );
  }

  /// Aplica el avatar seleccionado
  void _applyAvatar() {
    setState(() => _isLoading = true);

    // Simular guardado
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackBarService().showSuccess(
          context,
          'Avatar "${_selectedAvatar.name}" aplicado correctamente',
        );
        // Aquí se implementaría la lógica para guardar el avatar en la base de datos
      }
    });
  }
}

/// Modelo de datos para una opción de avatar
class AvatarOption {
  final AvatarType type;
  final String name;
  final IconData icon;
  final Color color;
  final bool isDefault;

  const AvatarOption({
    required this.type,
    required this.name,
    required this.icon,
    required this.color,
    this.isDefault = false,
  });
}

/// Enum para tipos de avatar
enum AvatarType {
  icon,
  photo,
}
