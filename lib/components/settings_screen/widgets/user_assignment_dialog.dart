import 'package:flutter/material.dart';
import '../../../constants/ui_constants.dart';
import '../../../models/api_models.dart';
import '../../../models/house_member_models.dart';
import '../../../services/house/house_member_service.dart';
import '../../../services/cleaning_assignment_service.dart';
import '../../../services/common/snackbar_service.dart';

/// Diálogo para seleccionar y asignar un usuario a una zona de limpieza
class UserAssignmentDialog extends StatefulWidget {
  final CleaningAreaResponse cleaningArea;
  final VoidCallback? onAssignmentSuccess;

  const UserAssignmentDialog({
    super.key,
    required this.cleaningArea,
    this.onAssignmentSuccess,
  });

  @override
  State<UserAssignmentDialog> createState() => _UserAssignmentDialogState();
}

class _UserAssignmentDialogState extends State<UserAssignmentDialog> {
  final CleaningAssignmentService _assignmentService = CleaningAssignmentService();
  final SnackBarService _snackBarService = SnackBarService();

  List<HouseMemberInfo> _availableMembers = [];
  bool _isLoading = true;
  bool _isAssigning = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableMembers();
  }

  /// Carga los miembros disponibles para asignar a la zona
  Future<void> _loadAvailableMembers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final members = await HouseMemberService.getHouseMembers();
      
      // Debug: imprimir información de los miembros
      print('=== DEBUG: Miembros cargados ===');
      for (var member in members) {
        print('Miembro: ${member.nickname}, ID: ${member.id}, Status: ${member.status}');
      }
      
      setState(() {
        _availableMembers = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        _snackBarService.showError(
          context,
          'Error al cargar miembros: ${e.toString()}',
        );
      }
    }
  }

  /// Asigna un miembro a la zona de limpieza
  Future<void> _assignMember(HouseMemberInfo member) async {
    try {
      setState(() {
        _isAssigning = true;
      });

      await _assignmentService.assignUserToCleaningArea(
        memberId: member.id,
        cleaningAreaId: widget.cleaningArea.id,
      );

      if (mounted) {
        _snackBarService.showSuccess(
          context,
          '${member.nickname} asignado a ${widget.cleaningArea.name}',
        );
        
        // Cerrar el diálogo y notificar éxito
        Navigator.of(context).pop();
        widget.onAssignmentSuccess?.call();
      }
    } catch (e) {
      // Debug: imprimir error detallado
      print('=== DEBUG: Error en asignación ===');
      print('Error: $e');
      print('Tipo de error: ${e.runtimeType}');
      
      if (mounted) {
        _snackBarService.showError(
          context,
          'Error al asignar usuario: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAssigning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(UIConstants.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: UIConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                  ),
                  child: Icon(
                    Icons.person_add_rounded,
                    color: UIConstants.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: UIConstants.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asignar Usuario',
                        style: TextStyle(
                          fontSize: UIConstants.textSizeLarge,
                          fontWeight: FontWeight.w600,
                          color: UIConstants.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Selecciona un miembro para ${widget.cleaningArea.name}',
                        style: TextStyle(
                          fontSize: UIConstants.textSizeSmall,
                          color: UIConstants.textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: UIConstants.textColor.withOpacity(0.6),
                ),
              ],
            ),
            
            const SizedBox(height: UIConstants.spacingLarge),
            
            // Contenido
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(UIConstants.spacingLarge),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_availableMembers.isEmpty)
              _buildEmptyState()
            else
              _buildMembersList(),
          ],
        ),
      ),
    );
  }

  /// Construye el estado vacío cuando no hay miembros disponibles
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      child: Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 64,
            color: UIConstants.textColor.withOpacity(0.3),
          ),
          const SizedBox(height: UIConstants.spacingMedium),
          Text(
            'No hay miembros disponibles',
            style: TextStyle(
              fontSize: UIConstants.textSizeMedium,
              fontWeight: FontWeight.w600,
              color: UIConstants.textColor,
            ),
          ),
          const SizedBox(height: UIConstants.spacingSmall),
          Text(
            'Todos los miembros ya están asignados a esta zona o no hay miembros en la casa.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: UIConstants.textSizeSmall,
              color: UIConstants.textColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la lista de miembros disponibles
  Widget _buildMembersList() {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _availableMembers.length,
        itemBuilder: (context, index) {
          final member = _availableMembers[index];
          return _buildMemberCard(member);
        },
      ),
    );
  }

  /// Construye una tarjeta de miembro
  Widget _buildMemberCard(HouseMemberInfo member) {
    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        border: Border.all(
          color: UIConstants.primaryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingMedium,
          vertical: UIConstants.spacingSmall,
        ),
        leading: CircleAvatar(
          backgroundColor: UIConstants.primaryColor.withOpacity(0.1),
          child: Text(
            member.nickname.isNotEmpty ? member.nickname[0].toUpperCase() : '?',
            style: TextStyle(
              color: UIConstants.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          member.nickname,
          style: const TextStyle(
            fontSize: UIConstants.textSizeMedium,
            fontWeight: FontWeight.w600,
            color: UIConstants.textColor,
          ),
        ),
        subtitle: Text(
          'Estado: ${member.status}',
          style: TextStyle(
            fontSize: UIConstants.textSizeSmall,
            color: UIConstants.textColor.withOpacity(0.6),
          ),
        ),
        trailing: _isAssigning
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                onPressed: () => _assignMember(member),
                icon: Icon(
                  Icons.add_rounded,
                  color: UIConstants.primaryColor,
                ),
                tooltip: 'Asignar a ${widget.cleaningArea.name}',
              ),
        onTap: _isAssigning ? null : () => _assignMember(member),
      ),
    );
  }
}
