import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import 'auth_types.dart';

/// Widget que contiene los formularios de autenticación
class AuthFormWidget extends StatelessWidget {
  final AuthType selectedAuthType;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController nicknameController;
  final TextEditingController housePinController;
  final TextEditingController userPinController;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool isUserPinVisible;
  final bool acceptTerms;
  final bool rememberMe;
  final Function(bool) onPasswordVisibilityChanged;
  final Function(bool) onConfirmPasswordVisibilityChanged;
  final Function(bool) onUserPinVisibilityChanged;
  final Function(bool) onAcceptTermsChanged;
  final Function(bool) onRememberMeChanged;
  final VoidCallback onForgotPassword;

  const AuthFormWidget({
    super.key,
    required this.selectedAuthType,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.nicknameController,
    required this.housePinController,
    required this.userPinController,
    required this.isPasswordVisible,
    required this.isConfirmPasswordVisible,
    required this.isUserPinVisible,
    required this.acceptTerms,
    required this.rememberMe,
    required this.onPasswordVisibilityChanged,
    required this.onConfirmPasswordVisibilityChanged,
    required this.onUserPinVisibilityChanged,
    required this.onAcceptTermsChanged,
    required this.onRememberMeChanged,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Expanded(
        child: switch (selectedAuthType) {
          AuthType.login => _buildLoginForm(),
          AuthType.register => _buildRegisterForm(),
          AuthType.guest => _buildGuestForm(),
        },
      ),
    );
  }

  /// Construye un campo de texto elegante
  Widget _buildElegantTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    Color? backgroundColor,
  }) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              validator: validator,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  icon,
                  color: Colors.grey[600],
                  size: 24,
                ),
                suffixIcon: suffixIcon,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el formulario de login
  Widget _buildLoginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Campo de email
        _buildElegantTextField(
          controller: emailController,
          label: 'Correo electrónico',
          hint: 'tu@email.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu email';
            }
            if (!value.contains('@')) {
              return 'Ingresa un email válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),
        // Campo de contraseña
        _buildElegantTextField(
          controller: passwordController,
          label: 'Contraseña',
          hint: 'Tu contraseña',
          icon: Icons.lock_outline,
          obscureText: !isPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey[600],
            ),
            onPressed: () => onPasswordVisibilityChanged(!isPasswordVisible),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu contraseña';
            }
            if (value.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        // Opciones adicionales
        Row(
            children: [
              Checkbox(
                value: rememberMe,
                onChanged: (value) => onRememberMeChanged(value ?? false),
                activeColor: Colors.blue[600],
              ),
              const Text(
                'Recordarme',
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              TextButton(
                onPressed: onForgotPassword,
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
        ),
      ],
    );
  }

  /// Construye el formulario de registro
  Widget _buildRegisterForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Campo de nombre
        _buildElegantTextField(
          controller: nameController,
          label: 'Nombre completo',
          hint: 'Tu nombre completo',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu nombre';
            }
            if (value.length < 2) {
              return 'El nombre debe tener al menos 2 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        // Campo de email
        _buildElegantTextField(
          controller: emailController,
          label: 'Correo electrónico',
          hint: 'tu@email.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu email';
            }
            if (!value.contains('@')) {
              return 'Ingresa un email válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        // Campo de contraseña
        _buildElegantTextField(
          controller: passwordController,
          label: 'Contraseña',
          hint: 'Mínimo 6 caracteres',
          icon: Icons.lock_outline,
          obscureText: !isPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey[600],
            ),
            onPressed: () => onPasswordVisibilityChanged(!isPasswordVisible),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa una contraseña';
            }
            if (value.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        // Campo de confirmar contraseña
        _buildElegantTextField(
          controller: confirmPasswordController,
          label: 'Confirmar contraseña',
          hint: 'Repite tu contraseña',
          icon: Icons.lock_outline,
          obscureText: !isConfirmPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey[600],
            ),
            onPressed: () => onConfirmPasswordVisibilityChanged(!isConfirmPasswordVisible),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor confirma tu contraseña';
            }
            if (value != passwordController.text) {
              return 'Las contraseñas no coinciden';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: acceptTerms,
              onChanged: (value) => onAcceptTermsChanged(value ?? false),
              activeColor: Colors.green[600],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: UIConstants.spacingMedium + 2),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: UIConstants.textSizeXSmall + 1,
                      color: Colors.grey[700],
                    ),
                    children: [
                      const TextSpan(text: 'Acepto los '),
                      TextSpan(
                        text: 'términos y condiciones',
                        style: TextStyle(
                          color: Colors.green[600],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construye el formulario de invitado
  Widget _buildGuestForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Información de acceso temporal
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Acceso temporal con PINs de la casa y personal',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Campo de nickname
        _buildElegantTextField(
          controller: nicknameController,
          label: 'Nickname',
          hint: 'Cómo te gustaría que te llamen',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu nickname';
            }
            if (value.length < 2) {
              return 'El nickname debe tener al menos 2 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        // Campo de PIN de la casa
        _buildElegantTextField(
          controller: housePinController,
          label: 'PIN de la casa',
          hint: 'PIN proporcionado por el administrador',
          icon: Icons.home_outlined,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa el PIN de la casa';
            }
            if (value.length < 4) {
              return 'El PIN debe tener al menos 4 dígitos';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        // Campo de PIN personal
        _buildElegantTextField(
          controller: userPinController,
          label: 'Tu PIN personal',
          hint: 'PIN personal para tu acceso',
          icon: Icons.lock_outline,
          keyboardType: TextInputType.number,
          obscureText: !isUserPinVisible,
          suffixIcon: IconButton(
            icon: Icon(
              isUserPinVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey[600],
            ),
            onPressed: () => onUserPinVisibilityChanged(!isUserPinVisible),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu PIN personal';
            }
            if (value.length < 4) {
              return 'El PIN debe tener al menos 4 dígitos';
            }
            return null;
          },
        ),
      ],
    );
  }
}
