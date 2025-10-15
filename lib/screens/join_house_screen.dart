import 'package:flutter/material.dart';
import '../services/auth/auth_logic_service.dart';
import '../constants/ui_constants.dart';

/// Pantalla para unirse a una casa existente usando código
class JoinHouseScreen extends StatefulWidget {
  const JoinHouseScreen({super.key});

  @override
  State<JoinHouseScreen> createState() => _JoinHouseScreenState();
}

class _JoinHouseScreenState extends State<JoinHouseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _houseCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _houseCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: UIConstants.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Unirse a Casa',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Icono principal
                Icon(
                  Icons.home_work,
                  size: 80,
                  color: Colors.blue[600],
                ),
                
                const SizedBox(height: 24),
                
                // Título
                Text(
                  'Unirse a Casa Existente',
                  style: TextStyle(
                    fontSize: UIConstants.textSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Subtítulo
                Text(
                  'Ingresa el código de la casa a la que quieres unirte',
                  style: TextStyle(
                    fontSize: UIConstants.textSizeMedium,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Campo de código
                TextFormField(
                  controller: _houseCodeController,
                  decoration: InputDecoration(
                    labelText: 'Código de la casa',
                    hintText: 'Ej: ABC123',
                    prefixIcon: const Icon(Icons.vpn_key),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                      borderSide: BorderSide(color: Colors.blue[600]!),
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 6,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa un código de casa';
                    }
                    if (value.trim().length < 3) {
                      return 'El código debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                
                const SizedBox(height: 40),
                
                // Botón de unirse
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleJoinHouse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Unirse a la Casa',
                            style: TextStyle(
                              fontSize: UIConstants.textSizeMedium,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Botón de cancelar
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: UIConstants.textSizeMedium,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Información adicional
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pide el código de la casa al administrador o a un miembro existente.',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: UIConstants.textSizeSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Maneja el proceso de unirse a la casa
  Future<void> _handleJoinHouse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final houseCode = _houseCodeController.text.trim();
      final authLogicService = AuthLogicService();
      await authLogicService.performJoinHouse(context, houseCode);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
