import 'package:flutter/material.dart';
import '../components/auth_screen/auth_screen_components.dart';
import '../services/auth/auth_logic_service.dart';
import '../constants/ui_constants.dart';

/// Pantalla de autenticación que permite login, registro y acceso como invitado
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late PageController _pageController;
  AuthType? _selectedAuthType;
  
  // Controllers para los formularios
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _guestFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(text: 'juan@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _housePinController = TextEditingController();
  final _userPinController = TextEditingController();
  
  // Estados de los formularios
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isUserPinVisible = false;
  bool _acceptTerms = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    _housePinController.dispose();
    _userPinController.dispose();
    super.dispose();
  }

  /// Navega al formulario correspondiente
  void _navigateToForm(AuthType type) {
    setState(() {
      _selectedAuthType = type;
    });
    _pageController.animateToPage(
      1, // Siempre va a la página 1 (formulario)
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Realiza el proceso de autenticación según el tipo seleccionado
  Future<void> _performAuth(AuthType authType) async {
    GlobalKey<FormState> formKey;
    switch (authType) {
      case AuthType.login:
        formKey = _loginFormKey;
        break;
      case AuthType.register:
        formKey = _registerFormKey;
        break;
      case AuthType.guest:
        formKey = _guestFormKey;
        break;
    }
    
    if (!formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authLogicService = AuthLogicService();
      
      switch (authType) {
        case AuthType.login:
          await authLogicService.performLogin(
            context,
            _emailController.text.trim(),
            _passwordController.text,
          );
          break;
        case AuthType.register:
          await authLogicService.performRegister(context);
          break;
        case AuthType.guest:
          await authLogicService.performGuestAccess(
            context,
            _nicknameController.text.trim(),
            _housePinController.text.trim(),
            _userPinController.text.trim(),
          );
          break;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Maneja el cambio de visibilidad de la contraseña
  void _onPasswordVisibilityChanged(bool isVisible) {
    setState(() {
      _isPasswordVisible = isVisible;
    });
  }

  /// Maneja el cambio de visibilidad de la confirmación de contraseña
  void _onConfirmPasswordVisibilityChanged(bool isVisible) {
    setState(() {
      _isConfirmPasswordVisible = isVisible;
    });
  }

  /// Maneja el cambio de visibilidad del PIN de usuario
  void _onUserPinVisibilityChanged(bool isVisible) {
    setState(() {
      _isUserPinVisible = isVisible;
    });
  }

  /// Maneja el cambio de aceptación de términos
  void _onAcceptTermsChanged(bool accept) {
    setState(() {
      _acceptTerms = accept;
    });
  }

  /// Maneja el cambio de recordarme
  void _onRememberMeChanged(bool remember) {
    setState(() {
      _rememberMe = remember;
    });
  }

  /// Maneja el proceso de "olvidé mi contraseña"
  void _onForgotPassword() {
    AuthLogicService().handleForgotPassword(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Deshabilitar scroll manual
          children: [
            // Página 0: Selección de opciones
            _buildSelectionPage(),
            // Página 1: Formulario dinámico
            _buildFormPage(),
          ],
        ),
      ),
    );
  }

  /// Construye la página de selección con 3 contenedores
  Widget _buildSelectionPage() {
    return Column(
      children: [
        // Contenedor 1: Login
        Expanded(
          child: _buildAuthCard(
            title: 'Iniciar Sesión',
            description: 'Accede a tu cuenta existente',
            icon: Icons.login,
            color: Colors.blue[100]!,
            onTap: () => _navigateToForm(AuthType.login),
          ),
        ),
        // Contenedor 2: Registro
        Expanded(
          child: _buildAuthCard(
            title: 'Registrarse',
            description: 'Crea una nueva cuenta',
            icon: Icons.person_add,
            color: Colors.green[100]!,
            onTap: () => _navigateToForm(AuthType.register),
          ),
        ),
        // Contenedor 3: Invitado
        Expanded(
          child: _buildAuthCard(
            title: 'Acceso Invitado',
            description: 'Únete temporalmente',
            icon: Icons.person_outline,
            color: Colors.orange[100]!,
            onTap: () => _navigateToForm(AuthType.guest),
          ),
        ),
      ],
    );
  }

  /// Construye una card de autenticación
  Widget _buildAuthCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              // Contenido de texto a la izquierda
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Icono a la derecha
              Expanded(
                flex: 1,
                child: Center(
                  child: Icon(
                    icon,
                    size: 64,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye la página de formulario dinámico
  Widget _buildFormPage() {
    if (_selectedAuthType == null) {
      return const Center(
        child: Text('Error: No se ha seleccionado ningún tipo de autenticación'),
      );
    }
    
    GlobalKey<FormState> formKey;
    switch (_selectedAuthType!) {
      case AuthType.login:
        formKey = _loginFormKey;
        break;
      case AuthType.register:
        formKey = _registerFormKey;
        break;
      case AuthType.guest:
        formKey = _guestFormKey;
        break;
    }
    
    return Padding(
      padding: const EdgeInsets.all(UIConstants.screenPadding),
      child: Column(
        children: [
          // Header con botón de volver
          _buildFormHeader(_selectedAuthType!),
          const SizedBox(height: UIConstants.spacingLarge),
          // Formulario
          Expanded(
            child: SingleChildScrollView(
              child: AuthFormWidget(
                selectedAuthType: _selectedAuthType!,
                formKey: formKey,
                nameController: _nameController,
                emailController: _emailController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                nicknameController: _nicknameController,
                housePinController: _housePinController,
                userPinController: _userPinController,
                isPasswordVisible: _isPasswordVisible,
                isConfirmPasswordVisible: _isConfirmPasswordVisible,
                isUserPinVisible: _isUserPinVisible,
                acceptTerms: _acceptTerms,
                rememberMe: _rememberMe,
                onPasswordVisibilityChanged: _onPasswordVisibilityChanged,
                onConfirmPasswordVisibilityChanged: _onConfirmPasswordVisibilityChanged,
                onUserPinVisibilityChanged: _onUserPinVisibilityChanged,
                onAcceptTermsChanged: _onAcceptTermsChanged,
                onRememberMeChanged: _onRememberMeChanged,
                onForgotPassword: _onForgotPassword,
              ),
            ),
          ),
          const SizedBox(height: UIConstants.spacingLarge),
          // Botones
          _buildSubmitButton(_selectedAuthType!),
          const SizedBox(height: UIConstants.spacingMedium),
          _buildBackButton(),
        ],
      ),
    );
  }

  /// Construye el header del formulario
  Widget _buildFormHeader(AuthType authType) {
    final cardData = _getCardData(authType);
    
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        color: cardData.color,
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black87,
              size: UIConstants.iconSizeMedium,
            ),
          ),
          const SizedBox(width: UIConstants.spacingMedium),
          Icon(
            cardData.icon,
            size: UIConstants.iconSizeLarge,
            color: Colors.black87,
          ),
          const SizedBox(width: UIConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardData.title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: UIConstants.textSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  cardData.subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: UIConstants.textSizeMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene los datos de la card para el header
  _CardData _getCardData(AuthType authType) {
    switch (authType) {
      case AuthType.login:
        return _CardData(
          title: 'Iniciar Sesión',
          subtitle: 'Accede a tu cuenta',
          icon: Icons.login,
          color: Colors.blue[100]!,
        );
      case AuthType.register:
        return _CardData(
          title: 'Registrarse',
          subtitle: 'Crea una nueva cuenta',
          icon: Icons.person_add,
          color: Colors.green[100]!,
        );
      case AuthType.guest:
        return _CardData(
          title: 'Acceso Invitado',
          subtitle: 'Únete como invitado',
          icon: Icons.person_outline,
          color: Colors.orange[100]!,
        );
    }
  }

  /// Construye el botón de envío
  Widget _buildSubmitButton(AuthType authType) {
    final isEnabled = authType != AuthType.register || _acceptTerms;
    
    return AuthSubmitButtonWidget(
      selectedAuthType: authType,
      isLoading: _isLoading,
      isEnabled: isEnabled,
      onPressed: () => _performAuth(authType),
    );
  }

  /// Construye el botón de volver
  Widget _buildBackButton() {
    return TextButton(
      onPressed: () {
        // Volver a la página de selección
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Text(
        'Volver a las opciones',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: UIConstants.textSizeLarge - 8,
        ),
      ),
    );
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
