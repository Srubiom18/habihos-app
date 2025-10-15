import 'package:flutter/material.dart';
import '../../../constants/ui_constants.dart';
import '../../../models/house_member_models.dart';
import '../controllers/zonas_comunes_controller.dart';

/// Diálogo para seleccionar un usuario para asignar a una zona
class UserSelectionDialog extends StatefulWidget {
  final String areaId;
  final ZonasComunesController controller;
  final Function(String memberId) onUserSelected;

  const UserSelectionDialog({
    super.key,
    required this.areaId,
    required this.controller,
    required this.onUserSelected,
  });

  @override
  State<UserSelectionDialog> createState() => _UserSelectionDialogState();
}

class _UserSelectionDialogState extends State<UserSelectionDialog> {
  List<HouseMemberInfo> _availableMembers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAvailableMembers();
  }

  /// Carga los miembros disponibles
  Future<void> _loadAvailableMembers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final members = await widget.controller.getAvailableMembers();
      
      setState(() {
        _availableMembers = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.person_add,
            color: UIConstants.primaryColor,
            size: 24,
          ),
          const SizedBox(width: UIConstants.spacingSmall),
          const Text('Asignar Usuario'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  /// Construye el contenido del diálogo
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.withOpacity(0.6),
            ),
            const SizedBox(height: UIConstants.spacingMedium),
            Text(
              'Error al cargar usuarios',
              style: TextStyle(
                fontSize: UIConstants.textSizeMedium,
                fontWeight: FontWeight.w600,
                color: UIConstants.textColor,
              ),
            ),
            const SizedBox(height: UIConstants.spacingSmall),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: UIConstants.textSizeSmall,
                color: UIConstants.textColor.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.spacingLarge),
            ElevatedButton.icon(
              onPressed: _loadAvailableMembers,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_availableMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: Colors.grey.withOpacity(0.6),
            ),
            const SizedBox(height: UIConstants.spacingMedium),
            Text(
              'No hay usuarios disponibles',
              style: TextStyle(
                fontSize: UIConstants.textSizeMedium,
                fontWeight: FontWeight.w600,
                color: UIConstants.textColor,
              ),
            ),
            const SizedBox(height: UIConstants.spacingSmall),
            Text(
              'No se encontraron miembros en la casa',
              style: TextStyle(
                fontSize: UIConstants.textSizeSmall,
                color: UIConstants.textColor.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _availableMembers.length,
      itemBuilder: (context, index) {
        final member = _availableMembers[index];
        return _buildMemberCard(member);
      },
    );
  }

  /// Construye una card para un miembro
  Widget _buildMemberCard(HouseMemberInfo member) {
    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSmall),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: UIConstants.primaryColor,
            child: Text(
              _generateInitials(member.nickname),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            member.nickname,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: UIConstants.textColor,
            ),
          ),
          subtitle: Text(
            'Miembro de la casa',
            style: TextStyle(
              color: UIConstants.textColor.withOpacity(0.6),
            ),
          ),
          trailing: ElevatedButton.icon(
            onPressed: () {
              widget.onUserSelected(member.id);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Asignar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: UIConstants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Genera las iniciales del nombre
  String _generateInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '?';
    
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
  }
}
