/// Request para agregar un nuevo producto a la lista de compras
class AddProductRequest {
  final String name;
  final String? apartmentId; // ID del apartamento/casa compartida

  AddProductRequest({
    required this.name,
    this.apartmentId,
  });

  // Conversión a JSON (para enviar al backend)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (apartmentId != null) 'apartmentId': apartmentId,
    };
  }

  @override
  String toString() => 'AddProductRequest(name: $name)';
}

