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

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  AuthType _selectedAuthType = AuthType.login;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Controllers para los formularios
  final _formKey = GlobalKey<FormState>();
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
    _setupAnimations();
  }

  /// Configura las animaciones de la pantalla
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    _housePinController.dispose();
    _userPinController.dispose();
    super.dispose();
  }

  /// Cambia el tipo de autenticación seleccionado
  void _selectAuthType(AuthType type) {
    if (_selectedAuthType != type) {
      setState(() {
        _selectedAuthType = type;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  /// Realiza el proceso de autenticación según el tipo seleccionado
  Future<void> _performAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authLogicService = AuthLogicService();
      
      switch (_selectedAuthType) {
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
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.screenPadding),
          child: Column(
            children: [
              const SizedBox(height: UIConstants.spacingMedium),
              
              // Selector de tipo de autenticación
              AuthTypeSelectorWidget(
                selectedAuthType: _selectedAuthType,
                onAuthTypeChanged: _selectAuthType,
              ),
              const SizedBox(height: UIConstants.spacingXLarge),
              
              // Header compacto
              AuthHeaderWidget(selectedAuthType: _selectedAuthType),
              const SizedBox(height: UIConstants.spacingXLarge),
              
              // Formulario dinámico
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildDynamicForm(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el formulario dinámico según el tipo de autenticación
  Widget _buildDynamicForm() {
    return Column(
      children: [
        Expanded(
          child: AuthFormWidget(
            selectedAuthType: _selectedAuthType,
            formKey: _formKey,
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
        const SizedBox(height: UIConstants.spacingLarge),
        _buildSubmitButton(),
        const SizedBox(height: UIConstants.spacingMedium + 2),
        _buildBackButton(),
      ],
    );
  }

  /// Construye el botón de envío
  Widget _buildSubmitButton() {
    final isEnabled = _selectedAuthType != AuthType.register || _acceptTerms;
    
    return AuthSubmitButtonWidget(
      selectedAuthType: _selectedAuthType,
      isLoading: _isLoading,
      isEnabled: isEnabled,
      onPressed: _performAuth,
    );
  }

  /// Construye el botón de volver
  Widget _buildBackButton() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(
        'Volver',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: UIConstants.textSizeLarge - 8,
        ),
      ),
    );
  }

}
