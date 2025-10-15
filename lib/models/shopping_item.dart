import 'house_member.dart';

class ShoppingItem {
  final String id;
  final String name;
  final bool isPurchased;
  final double? price;
  final HouseMember? purchasedBy;
  final DateTime? purchasedAt; // Fecha de compra
  final DateTime createdAt; // Fecha de creación

  ShoppingItem({
    required this.id,
    required this.name,
    this.isPurchased = false,
    this.price,
    this.purchasedBy,
    this.purchasedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Conversión desde JSON (del backend)
  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      isPurchased: json['isPurchased'] as bool? ?? false,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      purchasedBy: json['purchasedBy'] != null
          ? HouseMember.fromJson(json['purchasedBy'] as Map<String, dynamic>)
          : null,
      purchasedAt: json['purchasedAt'] != null
          ? DateTime.parse(json['purchasedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  // Conversión a JSON (para enviar al backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isPurchased': isPurchased,
      'price': price,
      'purchasedBy': purchasedBy?.toJson(),
      'purchasedAt': purchasedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Helper para crear una copia con cambios
  ShoppingItem copyWith({
    String? id,
    String? name,
    bool? isPurchased,
    double? price,
    HouseMember? purchasedBy,
    DateTime? purchasedAt,
    DateTime? createdAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isPurchased: isPurchased ?? this.isPurchased,
      price: price ?? this.price,
      purchasedBy: purchasedBy ?? this.purchasedBy,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'ShoppingItem(id: $id, name: $name, isPurchased: $isPurchased)';
}

