import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';

/// Widget que contiene el formulario de información básica de la casa
class HouseInfoFormWidget extends StatelessWidget {
  final TextEditingController nameController;
  final int selectedMaxParticipants;
  final Function(int) onMaxParticipantsChanged;
  final String? Function(String?)? nameValidator;

  const HouseInfoFormWidget({
    super.key,
    required this.nameController,
    required this.selectedMaxParticipants,
    required this.onMaxParticipantsChanged,
    this.nameValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de nombre de la casa
        _buildHouseNameField(),
        const SizedBox(height: UIConstants.spacingXLarge + 8),
        
        // Selector de máximo participantes
        _buildMaxParticipantsSelector(),
      ],
    );
  }

  /// Construye el campo de nombre de la casa
  Widget _buildHouseNameField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        boxShadow: UIConstants.defaultShadow,
      ),
      child: TextFormField(
        controller: nameController,
        style: const TextStyle(
          fontSize: UIConstants.textSizeMedium,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Nombre de la casa...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: UIConstants.textSizeMedium,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.home_outlined,
            color: Colors.blue[600],
            size: UIConstants.iconSizeMedium + 2,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
            borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingLarge,
            vertical: UIConstants.spacingLarge + 2,
          ),
        ),
        validator: nameValidator,
      ),
    );
  }

  /// Construye el selector de máximo participantes
  Widget _buildMaxParticipantsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Máximo de participantes',
          style: TextStyle(
            fontSize: UIConstants.textSizeMedium,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: UIConstants.spacingMedium + 2),
        Container(
          padding: const EdgeInsets.all(UIConstants.spacingSmall),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
            boxShadow: UIConstants.defaultShadow,
          ),
          child: Row(
            children: List.generate(5, (index) {
              final participantCount = index + 2; // 2, 3, 4, 5, 6
              final isSelected = selectedMaxParticipants == participantCount;
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingSmall),
                  child: GestureDetector(
                    onTap: () => onMaxParticipantsChanged(participantCount),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        vertical: UIConstants.spacingMedium + 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[600] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                        border: Border.all(
                          color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person,
                            color: isSelected ? Colors.white : Colors.grey[600],
                            size: UIConstants.iconSizeMedium,
                          ),
                          const SizedBox(height: UIConstants.spacingSmall),
                          Text(
                            '$participantCount',
                            style: TextStyle(
                              fontSize: UIConstants.textSizeNormal,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
