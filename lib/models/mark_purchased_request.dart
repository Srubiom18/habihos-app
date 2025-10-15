/// Request para marcar un producto como comprado
class MarkPurchasedRequest {
  final String productId;
  final double price;
  final String purchasedById; // ID del usuario que lo compró

  MarkPurchasedRequest({
    required this.productId,
    required this.price,
    required this.purchasedById,
  });

  // Conversión a JSON (para enviar al backend)
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'price': price,
      'purchasedById': purchasedById,
    };
  }

  @override
  String toString() => 
      'MarkPurchasedRequest(productId: $productId, price: €$price, purchasedById: $purchasedById)';
}

