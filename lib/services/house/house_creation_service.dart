import 'package:flutter/material.dart';
import '../../models/api_models.dart';
import '../../services/house_service.dart';
import '../../services/common/snackbar_service.dart';
import '../../components/create_house_screen/cleaning_area_form_widget.dart';

/// Servicio que maneja la lógica de creación de casas
class HouseCreationService {
  static final HouseCreationService _instance = HouseCreationService._internal();
  factory HouseCreationService() => _instance;
  HouseCreationService._internal();

  /// Crea una nueva casa con la información proporcionada
  Future<bool> createHouse(
    BuildContext context,
    String houseName,
    int maxParticipants,
    List<CleaningAreaForm> cleaningAreas,
  ) async {
    try {
      final cleaningAreasRequest = cleaningAreas
          .where((area) => area.nameController.text.trim().isNotEmpty)
          .map((area) => CleaningAreaRequest(
                name: area.nameController.text.trim(),
                description: area.descriptionController.text.trim().isEmpty
                    ? null
                    : area.descriptionController.text.trim(),
              ))
          .toList();

      if (cleaningAreasRequest.isEmpty) {
        SnackBarService().showError(
          context,
          'Debes agregar al menos una área de limpieza',
        );
        return false;
      }

      final request = CreateHouseRequest(
        name: houseName,
        maxParticipants: maxParticipants,
        cleaningAreas: cleaningAreasRequest,
      );

      await HouseService.createHouse(request);

      if (context.mounted) {
        SnackBarService().showSuccess(
          context,
          '¡Casa creada exitosamente!',
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        SnackBarService().showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
      return false;
    }
  }

  /// Valida el nombre de la casa
  String? validateHouseName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre de la casa es obligatorio';
    }
    if (value.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    return null;
  }

  /// Valida el número máximo de participantes
  String? validateMaxParticipants(int value) {
    if (value < 2) {
      return 'Debe haber al menos 2 participantes';
    }
    if (value > 6) {
      return 'No puede haber más de 6 participantes';
    }
    return null;
  }
}
