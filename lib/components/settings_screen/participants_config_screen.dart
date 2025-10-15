import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import '../../services/common/snackbar_service.dart';
import '../../services/house/house_member_service.dart';
import '../../models/house_member_models.dart';

/// Pantalla de configuración de participantes de la casa
class ParticipantsConfigScreen extends StatefulWidget {
  const ParticipantsConfigScreen({super.key});

  @override
  State<ParticipantsConfigScreen> createState() => _ParticipantsConfigScreenState();
}

class _ParticipantsConfigScreenState extends State<ParticipantsConfigScreen> {
  List<HouseMemberInfo> _members = [];
  bool _isLoading = true;
  String? _error;
  bool _isAddingGuest = false;
  final TextEditingController _guestNameController = TextEditingController();
  final FocusNode _guestNameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _guestNameController.dispose();
    _guestNameFocus.dispose();
    super.dispose();
  }

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
          'Participantes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: UIConstants.textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isAddingGuest)
            IconButton(
              icon: const Icon(
                Icons.person_add_rounded,
                color: UIConstants.primaryColor,
              ),
              onPressed: _startAddingGuest,
            ),
        ],
      ),
      body: Column(
        children: [
          // Información de la casa
          _buildHouseInfo(),
          
          // Contenido principal
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  /// Construye la información de la casa
  Widget _buildHouseInfo() {
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [UIConstants.primaryColor, UIConstants.primaryColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                ),
                child: const Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: UIConstants.spacingLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Casa de la Universidad',
                      style: TextStyle(
                        fontSize: UIConstants.textSizeLarge,
                        fontWeight: FontWeight.w600,
                        color: UIConstants.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_members.length} miembros activos',
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
          
          // Input para agregar invitado
          if (_isAddingGuest) ...[
            const SizedBox(height: UIConstants.spacingLarge),
            const Divider(),
            const SizedBox(height: UIConstants.spacingLarge),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _guestNameController,
                    focusNode: _guestNameFocus,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del invitado',
                      hintText: 'Ej: María, Carlos, Ana...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: UIConstants.spacingMedium,
                        vertical: UIConstants.spacingSmall,
                      ),
                    ),
                    enabled: !_isLoading,
                    onSubmitted: (_) => _addGuest(),
                  ),
                ),
                const SizedBox(width: UIConstants.spacingMedium),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addGuest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.spacingLarge,
                      vertical: UIConstants.spacingMedium,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
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
                          'Agregar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(width: UIConstants.spacingSmall),
                IconButton(
                  onPressed: _cancelAddingGuest,
                  icon: const Icon(Icons.close_rounded),
                  color: UIConstants.textColor.withOpacity(0.6),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Construye el contenido principal según el estado
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar miembros',
              style: TextStyle(
                fontSize: UIConstants.textSizeLarge,
                fontWeight: FontWeight.w600,
                color: UIConstants.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: UIConstants.textSizeSmall,
                color: UIConstants.textColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMembers,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 64,
              color: UIConstants.textColor.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay miembros en la casa',
              style: TextStyle(
                fontSize: UIConstants.textSizeLarge,
                fontWeight: FontWeight.w600,
                color: UIConstants.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega el primer invitado para comenzar',
              style: TextStyle(
                fontSize: UIConstants.textSizeSmall,
                color: UIConstants.textColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(UIConstants.screenPadding),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];
        return _buildMemberCard(member);
      },
    );
  }

  /// Carga los miembros de la casa desde la API
  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final members = await HouseMemberService.getHouseMembers();
      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Construye una tarjeta de miembro
  Widget _buildMemberCard(HouseMemberInfo member) {
    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingMedium),
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
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getAvatarColor(member).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _getAvatarColor(member).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                member.nickname[0].toUpperCase(),
                style: TextStyle(
                  fontSize: UIConstants.textSizeLarge,
                  fontWeight: FontWeight.w600,
                  color: _getAvatarColor(member),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: UIConstants.spacingLarge),
          
          // Información del participante
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.nickname,
                      style: const TextStyle(
                        fontSize: UIConstants.textSizeMedium,
                        fontWeight: FontWeight.w500,
                        color: UIConstants.textColor,
                      ),
                    ),
                    if (member.isCurrentUser) ...[
                      const SizedBox(width: UIConstants.spacingSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: UIConstants.spacingSmall,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Tú',
                          style: TextStyle(
                            fontSize: UIConstants.textSizeXSmall,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Miembro desde ${_formatDate(member.createdAt)}',
                  style: TextStyle(
                    fontSize: UIConstants.textSizeSmall,
                    color: UIConstants.textColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: member.status == 'ACTIVE' ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: UIConstants.spacingSmall),
                    Text(
                      member.status == 'ACTIVE' ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        fontSize: UIConstants.textSizeSmall,
                        color: member.status == 'ACTIVE' ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Indicador de usuario actual
          if (member.isCurrentUser)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingSmall,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Tú',
                style: TextStyle(
                  fontSize: UIConstants.textSizeXSmall,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Obtiene el color del avatar basado en el nombre
  Color _getAvatarColor(HouseMemberInfo member) {
    final colors = [
      Colors.blue,
      Colors.pink,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
    ];
    final index = member.nickname.hashCode % colors.length;
    return colors[index.abs()];
  }

  /// Formatea la fecha de creación
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'hoy';
    } else if (difference.inDays == 1) {
      return 'ayer';
    } else if (difference.inDays < 7) {
      return 'hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'hace $weeks semana${weeks > 1 ? 's' : ''}';
    } else {
      final months = (difference.inDays / 30).floor();
      return 'hace $months mes${months > 1 ? 'es' : ''}';
    }
  }


  /// Inicia el proceso de agregar un invitado
  void _startAddingGuest() {
    setState(() {
      _isAddingGuest = true;
    });
    // Enfocar el campo de texto después de que se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _guestNameFocus.requestFocus();
    });
  }

  /// Cancela el proceso de agregar invitado
  void _cancelAddingGuest() {
    setState(() {
      _isAddingGuest = false;
      _guestNameController.clear();
    });
    _guestNameFocus.unfocus();
  }

  /// Agrega un invitado
  Future<void> _addGuest() async {
    final guestName = _guestNameController.text.trim();
    
    if (guestName.isEmpty) {
      SnackBarService().showError(context, 'Por favor ingresa un nombre');
      return;
    }
    
    if (guestName.length < 2) {
      SnackBarService().showError(context, 'El nombre debe tener al menos 2 caracteres');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await HouseMemberService.createGuest(guestName);
      
      if (mounted) {
        setState(() {
          _isAddingGuest = false;
          _guestNameController.clear();
          _isLoading = false;
        });
        _guestNameFocus.unfocus();
        
        SnackBarService().showSuccess(
          context,
          'Invitado "$guestName" agregado correctamente',
        );
        
        // Mostrar pantalla de credenciales
        _showGuestCredentials(response);
        
        // Recargar la lista
        _loadMembers();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        SnackBarService().showError(
          context,
          'Error al crear invitado: ${e.toString()}',
        );
      }
    }
  }

  /// Muestra la pantalla de credenciales del invitado
  void _showGuestCredentials(CreateGuestResponse response) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _GuestCredentialsScreen(
          guestInfo: response,
          onClose: () {
            Navigator.of(context).pop();
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

/// Pantalla temporal para mostrar las credenciales del invitado
class _GuestCredentialsScreen extends StatefulWidget {
  final CreateGuestResponse guestInfo;
  final VoidCallback onClose;

  const _GuestCredentialsScreen({
    required this.guestInfo,
    required this.onClose,
  });

  @override
  State<_GuestCredentialsScreen> createState() => _GuestCredentialsScreenState();
}

class _GuestCredentialsScreenState extends State<_GuestCredentialsScreen> {
  bool _canClose = false;

  @override
  void initState() {
    super.initState();
    // Permitir cerrar después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _canClose = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_canClose) {
          widget.onClose();
          return true;
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: UIConstants.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: _canClose
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: UIConstants.textColor,
                  ),
                  onPressed: () {
                    widget.onClose();
                  },
                )
              : null,
          title: const Text(
            'Credenciales del Invitado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: UIConstants.textColor,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(UIConstants.screenPadding),
            child: Column(
              children: [
                // Icono de advertencia
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    size: 40,
                    color: Colors.orange,
                  ),
                ),
                
                const SizedBox(height: UIConstants.spacingLarge),
                
                // Título principal
                const Text(
                  '¡IMPORTANTE!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                
                const SizedBox(height: UIConstants.spacingMedium),
                
                // Mensaje de advertencia
                Container(
                  padding: const EdgeInsets.all(UIConstants.spacingLarge),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Esta información solo se mostrará UNA VEZ. Anota estos datos antes de cerrar esta pantalla.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: UIConstants.textSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: UIConstants.textColor,
                    ),
                  ),
                ),
                
                const SizedBox(height: UIConstants.spacingXLarge),
                
                // Tarjeta con las credenciales
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(UIConstants.spacingXLarge),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Nombre del invitado
                      _buildCredentialItem(
                        icon: Icons.person_rounded,
                        label: 'Nombre del Invitado',
                        value: widget.guestInfo.guestName,
                        isHighlighted: true,
                      ),
                      
                      const SizedBox(height: UIConstants.spacingLarge),
                      const Divider(),
                      const SizedBox(height: UIConstants.spacingLarge),
                      
                      // PIN del invitado
                      _buildCredentialItem(
                        icon: Icons.lock_rounded,
                        label: 'PIN Personal',
                        value: widget.guestInfo.pinCode,
                        isHighlighted: true,
                        isSecret: true,
                      ),
                      
                      const SizedBox(height: UIConstants.spacingLarge),
                      const Divider(),
                      const SizedBox(height: UIConstants.spacingLarge),
                      
                      // Código de la casa
                      _buildCredentialItem(
                        icon: Icons.home_rounded,
                        label: 'Código de la Casa',
                        value: widget.guestInfo.houseCode,
                        isHighlighted: false,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: UIConstants.spacingXLarge),
                
                // Instrucciones
                Container(
                  padding: const EdgeInsets.all(UIConstants.spacingLarge),
                  decoration: BoxDecoration(
                    color: UIConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_rounded,
                        color: UIConstants.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(height: UIConstants.spacingSmall),
                      const Text(
                        'Comparte esta información con el invitado',
                        style: TextStyle(
                          fontSize: UIConstants.textSizeMedium,
                          fontWeight: FontWeight.w600,
                          color: UIConstants.textColor,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingSmall),
                      Text(
                        'El invitado necesitará el nombre, PIN y código de casa para acceder a la aplicación.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: UIConstants.textSizeSmall,
                          color: UIConstants.textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: UIConstants.spacingLarge),
                
                // Botón de cerrar (solo disponible después de 3 segundos)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canClose ? () {
                      widget.onClose();
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingLarge),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
                      ),
                    ),
                    child: _canClose
                        ? const Text(
                            'Entendido, cerrar',
                            style: TextStyle(
                              fontSize: UIConstants.textSizeMedium,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: UIConstants.spacingSmall),
                              const Text(
                                'Espera...',
                                style: TextStyle(
                                  fontSize: UIConstants.textSizeMedium,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                
                const SizedBox(height: UIConstants.spacingXLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isHighlighted,
    bool isSecret = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: isHighlighted ? UIConstants.primaryColor : UIConstants.textColor.withOpacity(0.6),
              size: 20,
            ),
            const SizedBox(width: UIConstants.spacingSmall),
            Text(
              label,
              style: TextStyle(
                fontSize: UIConstants.textSizeSmall,
                fontWeight: FontWeight.w500,
                color: UIConstants.textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingSmall),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(UIConstants.spacingMedium),
          decoration: BoxDecoration(
            color: isHighlighted 
                ? UIConstants.primaryColor.withOpacity(0.1)
                : UIConstants.backgroundColor,
            borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
            border: Border.all(
              color: isHighlighted 
                  ? UIConstants.primaryColor.withOpacity(0.3)
                  : UIConstants.textColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? UIConstants.textSizeLarge : UIConstants.textSizeMedium,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
              color: isHighlighted ? UIConstants.primaryColor : UIConstants.textColor,
              letterSpacing: isSecret ? 2.0 : 0.0,
            ),
          ),
        ),
      ],
    );
  }
}
