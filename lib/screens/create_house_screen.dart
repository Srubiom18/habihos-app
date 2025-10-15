import 'package:flutter/material.dart';
import '../components/create_house_screen/create_house_screen_components.dart';
import '../services/house/house_creation_service.dart';
import '../constants/ui_constants.dart';

/// Pantalla para crear una nueva casa
class CreateHouseScreen extends StatefulWidget {
  const CreateHouseScreen({super.key});

  @override
  State<CreateHouseScreen> createState() => _CreateHouseScreenState();
}

class _CreateHouseScreenState extends State<CreateHouseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  final List<CleaningAreaForm> _cleaningAreas = [];
  bool _isLoading = false;
  int _selectedMaxParticipants = 4; // Valor por defecto

  @override
  void initState() {
    super.initState();
    _addCleaningArea();
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var area in _cleaningAreas) {
      area.nameController.dispose();
      area.descriptionController.dispose();
    }
    super.dispose();
  }

  /// Agrega una nueva área de limpieza
  void _addCleaningArea() {
    setState(() {
      _cleaningAreas.add(CleaningAreaForm());
    });
  }

  /// Elimina un área de limpieza
  void _removeCleaningArea(int index) {
    if (_cleaningAreas.length > 1) {
      setState(() {
        _cleaningAreas[index].nameController.dispose();
        _cleaningAreas[index].descriptionController.dispose();
        _cleaningAreas.removeAt(index);
      });
    }
  }

  /// Maneja el cambio de máximo participantes
  void _onMaxParticipantsChanged(int value) {
    setState(() {
      _selectedMaxParticipants = value;
    });
  }

  /// Crea una nueva casa
  Future<void> _createHouse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final houseCreationService = HouseCreationService();
      final success = await houseCreationService.createHouse(
        context,
        _nameController.text.trim(),
        _selectedMaxParticipants,
        _cleaningAreas,
      );

      if (success && mounted) {
        // Navegar al MainScreen (que incluye la navegación) solo si la creación fue exitosa
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Crear Nueva Casa'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UIConstants.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información básica de la casa
              HouseInfoFormWidget(
                nameController: _nameController,
                selectedMaxParticipants: _selectedMaxParticipants,
                onMaxParticipantsChanged: _onMaxParticipantsChanged,
                nameValidator: HouseCreationService().validateHouseName,
              ),
              const SizedBox(height: UIConstants.spacingXLarge + 8),

              // Áreas de limpieza
              CleaningAreasSectionWidget(
                cleaningAreas: _cleaningAreas,
                onAddArea: _addCleaningArea,
                onRemoveArea: _removeCleaningArea,
              ),
              const SizedBox(height: UIConstants.spacingXLarge + 8),

              // Botón de crear casa
              CreateHouseButtonWidget(
                isLoading: _isLoading,
                onPressed: _createHouse,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
