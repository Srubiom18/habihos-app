import 'package:flutter/material.dart';

/// Constantes para colores, dimensiones y estilos de la UI
class UIConstants {
  // Constructor privado para evitar instanciación
  UIConstants._();

  // ========== COLORES ==========
  
  /// Color de fondo principal
  static const Color backgroundColor = Color(0xFFF5F5F5); // Colors.grey[100]
  
  /// Color de fondo de contenedores
  static const Color containerBackgroundColor = Colors.white;
  
  /// Color de borde por defecto
  static const Color defaultBorderColor = Color(0xFFE0E0E0); // Colors.grey[300]
  
  /// Color de borde de notificaciones
  static const Color notificationBorderColor = Color(0xFFE0E0E0); // Colors.grey[200]
  
  /// Color de fondo de gradiente de desvanecimiento
  static const Color fadeGradientColor = Color(0xFFF5F5F5); // Colors.grey[100]
  
  /// Color de fondo de botón completado
  static const Color completedButtonBackground = Color(0xFFE8F5E8); // Colors.green[100]
  
  /// Color de borde de botón completado
  static const Color completedButtonBorder = Color(0xFF81C784); // Colors.green[300]
  
  /// Color primario de la aplicación
  static const Color primaryColor = Color(0xFF2196F3); // Colors.blue[500]
  
  /// Color del texto principal
  static const Color textColor = Color(0xFF212121); // Colors.grey[900]
  
  /// Radio de borde por defecto (alias para borderRadius)
  static const double borderRadius = defaultBorderRadius;

  // ========== DIMENSIONES ==========
  
  /// Padding general de la pantalla
  static const double screenPadding = 20.0;
  
  /// Altura del área de limpieza activa
  static const double activeAreaHeight = 120.0;
  
  /// Altura de las otras áreas de limpieza
  static const double otherAreaHeight = 80.0;
  
  /// Altura del botón de acción
  static const double actionButtonHeight = 50.0;
  
  /// Radio de borde por defecto
  static const double defaultBorderRadius = 12.0;
  
  /// Radio de borde pequeño
  static const double smallBorderRadius = 10.0;
  
  /// Radio de borde del botón
  static const double buttonBorderRadius = 25.0;
  
  /// Radio de borde del SnackBar
  static const double snackBarBorderRadius = 8.0;

  // ========== ESPACIADOS ==========
  
  /// Espaciado pequeño
  static const double spacingSmall = 6.0;
  
  /// Espaciado mediano
  static const double spacingMedium = 10.0;
  
  /// Espaciado grande
  static const double spacingLarge = 15.0;
  
  /// Espaciado extra grande
  static const double spacingXLarge = 20.0;
  
  /// Espaciado superior de la pantalla
  static const double topSpacing = 20.0;
  
  /// Espaciado inferior para el botón
  static const double bottomSpacing = 60.0;
  
  /// Altura del gradiente de desvanecimiento
  static const double fadeGradientHeight = 30.0;

  // ========== TAMAÑOS DE ICONOS ==========
  
  /// Tamaño de icono grande
  static const double iconSizeLarge = 40.0;
  
  /// Tamaño de icono mediano
  static const double iconSizeMedium = 20.0;
  
  /// Tamaño de icono pequeño
  static const double iconSizeSmall = 16.0;
  
  /// Tamaño de icono extra pequeño
  static const double iconSizeXSmall = 14.0;
  
  /// Tamaño de icono de prioridad
  static const double priorityIconSize = 8.0;
  
  /// Tamaño de icono de indicador
  static const double indicatorIconSize = 12.0;

  // ========== TAMAÑOS DE TEXTO ==========
  
  /// Tamaño de texto grande
  static const double textSizeLarge = 24.0;
  
  /// Tamaño de texto mediano
  static const double textSizeMedium = 16.0;
  
  /// Tamaño de texto normal
  static const double textSizeNormal = 14.0;
  
  /// Tamaño de texto pequeño
  static const double textSizeSmall = 13.0;
  
  /// Tamaño de texto extra pequeño
  static const double textSizeXSmall = 11.0;
  
  /// Tamaño de texto muy pequeño
  static const double textSizeXXSmall = 10.0;
  
  /// Tamaño de texto extra grande
  static const double textSizeXLarge = 28.0;
  
  /// Tamaño de texto de etiqueta
  static const double textSizeLabel = 8.0;

  // ========== SOMBRAS ==========
  
  /// Sombra por defecto
  static const List<BoxShadow> defaultShadow = [
    BoxShadow(
      color: Color(0x1A000000), // Colors.grey.withOpacity(0.1)
      blurRadius: 8.0,
      offset: Offset(0, 2),
    ),
  ];
  
  /// Sombra del botón
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x4D000000), // withOpacity(0.3)
      blurRadius: 8.0,
      offset: Offset(0, 3),
    ),
  ];
  
  /// Sombra del área activa
  static const List<BoxShadow> activeAreaShadow = [
    BoxShadow(
      color: Color(0x4D000000), // withOpacity(0.3)
      blurRadius: 8.0,
      offset: Offset(0, 4),
    ),
  ];

  // ========== DURACIONES ==========
  
  /// Duración del SnackBar
  static const Duration snackBarDuration = Duration(seconds: 2);
  
  /// Duración de rotación de tareas
  static const Duration taskRotationDuration = Duration(days: 7);

  // ========== MÁRGENES ==========
  
  /// Margen del SnackBar
  static const EdgeInsets snackBarMargin = EdgeInsets.all(16.0);
  
  /// Padding del botón de acción
  static const EdgeInsets actionButtonPadding = EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: 10.0,
  );
  
  /// Padding del contenedor de notificaciones
  static const EdgeInsets notificationContainerPadding = EdgeInsets.all(15.0);
  
  /// Padding del área activa
  static const EdgeInsets activeAreaPadding = EdgeInsets.all(20.0);
}
