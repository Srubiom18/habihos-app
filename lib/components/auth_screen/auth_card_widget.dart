import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import 'auth_types.dart';

/// Widget que representa una card de autenticación
class AuthCardWidget extends StatelessWidget {
  final AuthType authType;
  final bool isExpanded;
  final VoidCallback onTap;
  final Widget? expandedContent;

  const AuthCardWidget({
    super.key,
    required this.authType,
    required this.isExpanded,
    required this.onTap,
    this.expandedContent,
  });

  @override
  Widget build(BuildContext context) {
    if (isExpanded) {
      return _buildExpandedCard();
    }
    
    return _buildCollapsedCard();
  }

  /// Construye la card colapsada
  Widget _buildCollapsedCard() {
    final cardData = _getCardData();
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(UIConstants.spacingSmall),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardData.color.withOpacity(0.8),
              cardData.color,
            ],
          ),
          borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
          boxShadow: [
            BoxShadow(
              color: cardData.color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(UIConstants.spacingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                cardData.icon,
                size: UIConstants.iconSizeLarge,
                color: Colors.white,
              ),
              const SizedBox(height: UIConstants.spacingMedium),
              Text(
                cardData.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: UIConstants.textSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: UIConstants.spacingSmall),
              Text(
                cardData.subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: UIConstants.textSizeMedium,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye la card expandida
  Widget _buildExpandedCard() {
    final cardData = _getCardData();
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardData.color.withOpacity(0.9),
            cardData.color,
          ],
        ),
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: cardData.color.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 15),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        child: Container(
          color: Colors.white.withOpacity(0.98),
          child: Column(
            children: [
              // Header de la card expandida con animación
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.all(UIConstants.spacingLarge),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cardData.color.withOpacity(0.8),
                      cardData.color,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedScale(
                      scale: 1.1,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        cardData.icon,
                        size: UIConstants.iconSizeLarge + 8,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: UIConstants.spacingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: UIConstants.textSizeXLarge,
                              fontWeight: FontWeight.bold,
                            ),
                            child: Text(cardData.title),
                          ),
                          const SizedBox(height: UIConstants.spacingSmall),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: UIConstants.textSizeMedium + 2,
                            ),
                            child: Text(cardData.subtitle),
                          ),
                        ],
                      ),
                    ),
                    AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: IconButton(
                        onPressed: onTap,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: UIConstants.iconSizeMedium + 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Contenido expandido con animación de entrada
              Expanded(
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedSlide(
                    offset: Offset.zero,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    child: expandedContent ?? Container(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Obtiene los datos específicos de cada tipo de card
  _CardData _getCardData() {
    switch (authType) {
      case AuthType.login:
        return _CardData(
          title: 'Iniciar Sesión',
          subtitle: 'Accede a tu cuenta',
          icon: Icons.login,
          color: Colors.blue[600]!,
        );
      case AuthType.register:
        return _CardData(
          title: 'Registrarse',
          subtitle: 'Crea una nueva cuenta',
          icon: Icons.person_add,
          color: Colors.green[600]!,
        );
      case AuthType.guest:
        return _CardData(
          title: 'Acceso Invitado',
          subtitle: 'Únete como invitado',
          icon: Icons.person_outline,
          color: Colors.orange[600]!,
        );
    }
  }
}

/// Clase para almacenar los datos de cada card
class _CardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  _CardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
