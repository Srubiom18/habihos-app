import 'package:flutter/material.dart';

class HouseMember {
  final String id;
  final String name;

  HouseMember({
    required this.id,
    required this.name,
  });

  // Conversión desde JSON (del backend)
  factory HouseMember.fromJson(Map<String, dynamic> json) {
    return HouseMember(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  // Conversión a JSON (para enviar al backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Genera un color consistente basado en el ID del miembro
  Color get color {
    return _generateColorFromId(id);
  }

  // Helper estático para generar color desde cualquier lugar
  static Color getColorForId(String id) {
    return _generateColorFromId(id);
  }

  static Color _generateColorFromId(String id) {
    final hash = id.hashCode.abs();
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      Colors.amber,
    ];
    return colors[hash % colors.length];
  }

  @override
  String toString() => 'HouseMember(id: $id, name: $name)';
}

