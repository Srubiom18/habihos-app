import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import 'auth_type_selector_widget.dart';
import 'auth_text_field_widget.dart';

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
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  switch (selectedAuthType) {
                    AuthType.login => _buildLoginForm(),
                    AuthType.register => _buildRegisterForm(),
                    AuthType.guest => _buildGuestForm(),
                  },
                ],
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
      children: [
        AuthTextFieldWidget(
          controller: emailController,
          label: 'Correo electrónico',
          hint: 'tu@email.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          authType: selectedAuthType,
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
        const SizedBox(height: UIConstants.spacingLarge),
        AuthTextFieldWidget(
          controller: passwordController,
          label: 'Contraseña',
          hint: 'Tu contraseña',
          icon: Icons.lock_outline,
          obscureText: !isPasswordVisible,
          authType: selectedAuthType,
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
        const SizedBox(height: UIConstants.spacingMedium + 2),
        Row(
          children: [
            Checkbox(
              value: rememberMe,
              onChanged: (value) => onRememberMeChanged(value ?? false),
              activeColor: Colors.blue[600],
            ),
            const Text('Recordarme', style: TextStyle(fontSize: UIConstants.textSizeNormal)),
            const Spacer(),
            TextButton(
              onPressed: onForgotPassword,
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontSize: UIConstants.textSizeXSmall + 1,
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
      children: [
        AuthTextFieldWidget(
          controller: nameController,
          label: 'Nombre completo',
          hint: 'Tu nombre completo',
          icon: Icons.person_outline,
          authType: selectedAuthType,
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
        const SizedBox(height: UIConstants.spacingLarge),
        AuthTextFieldWidget(
          controller: emailController,
          label: 'Correo electrónico',
          hint: 'tu@email.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          authType: selectedAuthType,
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
        const SizedBox(height: UIConstants.spacingLarge),
        AuthTextFieldWidget(
          controller: passwordController,
          label: 'Contraseña',
          hint: 'Mínimo 6 caracteres',
          icon: Icons.lock_outline,
          obscureText: !isPasswordVisible,
          authType: selectedAuthType,
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
        const SizedBox(height: UIConstants.spacingLarge),
        AuthTextFieldWidget(
          controller: confirmPasswordController,
          label: 'Confirmar contraseña',
          hint: 'Repite tu contraseña',
          icon: Icons.lock_outline,
          obscureText: !isConfirmPasswordVisible,
          authType: selectedAuthType,
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
        const SizedBox(height: UIConstants.spacingMedium + 2),
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
      children: [
        Container(
          padding: const EdgeInsets.all(UIConstants.spacingMedium + 2),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius + 2),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange[700], size: UIConstants.iconSizeXSmall + 4),
              const SizedBox(width: UIConstants.spacingMedium),
              Expanded(
                child: Text(
                  'Acceso temporal con PINs de la casa y personal',
                  style: TextStyle(
                    fontSize: UIConstants.textSizeXSmall,
                    color: Colors.orange[600],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: UIConstants.spacingLarge),
        AuthTextFieldWidget(
          controller: nicknameController,
          label: 'Nickname',
          hint: 'Cómo te gustaría que te llamen',
          icon: Icons.person_outline,
          authType: selectedAuthType,
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
        const SizedBox(height: UIConstants.spacingLarge),
        AuthTextFieldWidget(
          controller: housePinController,
          label: 'PIN de la casa',
          hint: 'PIN proporcionado por el administrador',
          icon: Icons.home_outlined,
          keyboardType: TextInputType.number,
          authType: selectedAuthType,
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
        const SizedBox(height: UIConstants.spacingLarge),
        AuthTextFieldWidget(
          controller: userPinController,
          label: 'Tu PIN personal',
          hint: 'PIN personal para tu acceso',
          icon: Icons.lock_outline,
          keyboardType: TextInputType.number,
          obscureText: !isUserPinVisible,
          authType: selectedAuthType,
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
