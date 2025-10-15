import 'package:flutter/material.dart';
import '../../../services/cleaning_area_service.dart';
import '../../../services/common/snackbar_service.dart';
import '../../../services/common/zones_update_notifier_service.dart';
import '../../../models/api_models.dart';

/// Diálogo para agregar una nueva zona común
class AddZonaComunDialog extends StatefulWidget {
  final VoidCallback onZonaComunAdded;

  const AddZonaComunDialog({
    super.key,
    required this.onZonaComunAdded,
  });

  @override
  State<AddZonaComunDialog> createState() => _AddZonaComunDialogState();
}

class _AddZonaComunDialogState extends State<AddZonaComunDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.orange,
    Colors.teal,
    Colors.purple,
    Colors.green,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Zona Común'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la zona',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Color de la zona:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableColors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _selectedColor == color ? color : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: _selectedColor == color
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addZonaComun,
          child: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Agregar'),
        ),
      ],
    );
  }

  Future<void> _addZonaComun() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final request = CreateCleaningAreaRequest(
          name: _nombreController.text,
          description: _descripcionController.text,
          color: '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
        );

        await CleaningAreaService.createCleaningArea(request);
        
        if (mounted) {
          Navigator.of(context).pop();
          
          // Notificar que se creó una nueva zona
          ZonesUpdateNotifierService().notifyZonesChanged();
          
          widget.onZonaComunAdded();
        }
      } catch (e) {
        if (mounted) {
          SnackBarService().showError(
            context,
            'Error al agregar zona: ${e.toString()}',
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
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}

/// Diálogo para editar una zona común existente
class EditZonaComunDialog extends StatefulWidget {
  final CleaningAreaResponse zonaComun;
  final VoidCallback onZonaComunUpdated;

  const EditZonaComunDialog({
    super.key,
    required this.zonaComun,
    required this.onZonaComunUpdated,
  });

  @override
  State<EditZonaComunDialog> createState() => _EditZonaComunDialogState();
}

class _EditZonaComunDialogState extends State<EditZonaComunDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.orange,
    Colors.teal,
    Colors.purple,
    Colors.green,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.zonaComun.name;
    _descripcionController.text = widget.zonaComun.description;
    _selectedColor = _parseColor(widget.zonaComun.color);
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Zona Común'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la zona',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Color de la zona:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableColors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _selectedColor == color ? color : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: _selectedColor == color
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateZonaComun,
          child: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Actualizar'),
        ),
      ],
    );
  }

  Future<void> _updateZonaComun() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final request = CreateCleaningAreaRequest(
          name: _nombreController.text,
          description: _descripcionController.text,
          color: '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
        );

        await CleaningAreaService.updateCleaningArea(widget.zonaComun.id.toString(), request);
        
        if (mounted) {
          Navigator.of(context).pop();
          
          // Notificar que se actualizó una zona
          ZonesUpdateNotifierService().notifyZonesChanged();
          
          widget.onZonaComunUpdated();
        }
      } catch (e) {
        if (mounted) {
          SnackBarService().showError(
            context,
            'Error al actualizar zona: ${e.toString()}',
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
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}

/// Diálogo de confirmación para eliminar una zona común
class DeleteZonaComunDialog extends StatelessWidget {
  final CleaningAreaResponse zonaComun;
  final VoidCallback onConfirm;

  const DeleteZonaComunDialog({
    super.key,
    required this.zonaComun,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Eliminar Zona Común'),
      content: Text('¿Estás seguro de que quieres eliminar la zona "${zonaComun.name}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
