import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/shopping_item.dart';

enum ProductDetailMode {
  add,        // Agregar nuevo producto
  purchase,   // Confirmar compra de producto pendiente
  detail,     // Ver detalle de producto comprado
}

class ProductDetailScreen extends StatefulWidget {
  final ShoppingItem? product;
  final ProductDetailMode mode;
  final Function(String productName)? onProductAdded;
  final Function(double price)? onPurchaseConfirmed;

  const ProductDetailScreen({
    super.key,
    this.product,
    required this.mode,
    this.onProductAdded,
    this.onPurchaseConfirmed,
  });

  // Factory constructors para facilitar el uso
  factory ProductDetailScreen.add({
    required Function(String) onProductAdded,
  }) {
    return ProductDetailScreen(
      mode: ProductDetailMode.add,
      onProductAdded: onProductAdded,
    );
  }

  factory ProductDetailScreen.purchase({
    required ShoppingItem product,
    required Function(double) onPurchaseConfirmed,
  }) {
    return ProductDetailScreen(
      product: product,
      mode: ProductDetailMode.purchase,
      onPurchaseConfirmed: onPurchaseConfirmed,
    );
  }

  factory ProductDetailScreen.viewDetail({
    required ShoppingItem product,
  }) {
    return ProductDetailScreen(
      product: product,
      mode: ProductDetailMode.detail,
    );
  }

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _confirmPurchase() {
    if (_formKey.currentState!.validate()) {
      final price = double.tryParse(_priceController.text);
      if (price != null && price > 0) {
        widget.onPurchaseConfirmed?.call(price);
        Navigator.pop(context);
      }
    }
  }

  void _addProduct() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      if (name.isNotEmpty) {
        widget.onProductAdded?.call(name);
        Navigator.pop(context);
      }
    }
  }

  String _getTitle() {
    switch (widget.mode) {
      case ProductDetailMode.add:
        return 'Agregar Producto';
      case ProductDetailMode.purchase:
        return 'Confirmar Compra';
      case ProductDetailMode.detail:
        return 'Detalle del Producto';
    }
  }

  IconData _getIcon() {
    switch (widget.mode) {
      case ProductDetailMode.add:
        return Icons.add_shopping_cart;
      case ProductDetailMode.purchase:
        return Icons.shopping_cart;
      case ProductDetailMode.detail:
        return Icons.check_circle;
    }
  }

  Color _getIconColor() {
    switch (widget.mode) {
      case ProductDetailMode.add:
        return Colors.blue[600]!;
      case ProductDetailMode.purchase:
        return Colors.orange[600]!;
      case ProductDetailMode.detail:
        return Colors.green[600]!;
    }
  }

  Color _getBackgroundColor() {
    switch (widget.mode) {
      case ProductDetailMode.add:
        return Colors.blue[50]!;
      case ProductDetailMode.purchase:
        return Colors.orange[50]!;
      case ProductDetailMode.detail:
        return Colors.green[50]!;
    }
  }

  Color _getBorderColor() {
    switch (widget.mode) {
      case ProductDetailMode.add:
        return Colors.blue[200]!;
      case ProductDetailMode.purchase:
        return Colors.orange[200]!;
      case ProductDetailMode.detail:
        return Colors.green[200]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getTitle(),
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono del producto
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getBorderColor(),
                    width: 3,
                  ),
                ),
                child: Icon(
                  _getIcon(),
                  size: 60,
                  color: _getIconColor(),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Nombre del producto (solo si no es modo agregar)
              if (widget.mode != ProductDetailMode.add) ...[
                Text(
                  widget.product?.name ?? '',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
              ] else ...[
                const SizedBox(height: 20),
              ],
              
              // Contenido según el modo
              if (widget.mode == ProductDetailMode.detail)
                _buildPurchasedDetails()
              else if (widget.mode == ProductDetailMode.purchase)
                _buildPurchaseForm()
              else
                _buildAddProductForm(),
            ],
          ),
        ),
      ),
    );
  }

  // Vista para productos ya comprados
  Widget _buildPurchasedDetails() {
    final product = widget.product!; // Safe because this is only called in detail mode
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Precio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Precio',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Text(
                  '€${product.price?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          const Divider(),
          
          const SizedBox(height: 24),
          
          // Comprado por
          Row(
            children: [
              Text(
                'Comprado por',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              CircleAvatar(
                radius: 20,
                backgroundColor: product.purchasedBy?.color ?? Colors.grey,
                child: Text(
                  product.purchasedBy?.name.substring(0, 1) ?? '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                product.purchasedBy?.name ?? 'Desconocido',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: product.purchasedBy?.color ?? Colors.grey[800],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Estado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Producto Comprado',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Vista para confirmar compra de productos pendientes
  Widget _buildPurchaseForm() {
    return Form(
      key: _formKey,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icono de dinero
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.euro,
                size: 40,
                color: Colors.orange[700],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Texto instructivo
            Text(
              '¿Cuánto costó?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Input de precio
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 32,
                ),
                prefixText: '€ ',
                prefixStyle: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.red[300]!, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un precio';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Ingresa un precio válido';
                }
                return null;
              },
              autofocus: true,
            ),
            
            const SizedBox(height: 32),
            
            // Botón de confirmar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _confirmPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Confirmar Compra',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botón de cancelar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Vista para agregar nuevo producto
  Widget _buildAddProductForm() {
    return Form(
      key: _formKey,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icono de producto
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 40,
                color: Colors.blue[700],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Texto instructivo
            Text(
              '¿Qué producto necesitas?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Input del nombre
            TextFormField(
              controller: _nameController,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Nombre del producto',
                hintStyle: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 20,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.blue[400]!, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.red[300]!, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                if (value.trim().length < 2) {
                  return 'El nombre debe tener al menos 2 caracteres';
                }
                return null;
              },
              autofocus: true,
            ),
            
            const SizedBox(height: 32),
            
            // Botón de agregar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Agregar Producto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botón de cancelar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

