import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'product_detail_screen.dart';
import 'shopping_history_screen.dart';
import '../models/shopping_list_response.dart';
import '../models/shopping_item.dart';
import '../models/shopping_distribution.dart';
import '../services/shopping_list_service.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  
  ShoppingListResponse? _data;
  bool _isLoading = true;
  String? _error;
  
  // Estados para la repartición de gastos
  bool _isCalculatingDistribution = false;
  bool _isConfirmingPayment = false;
  
  // Estado para verificar si hay historial disponible
  bool _hasHistory = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkHistoryExists();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ShoppingListService.getShoppingList();
      
      // Debug: Imprimir datos recibidos
      print('=== DATOS RECIBIDOS ===');
      print('Total Expenses: ${data.totalExpenses}');
      print('Active Distribution: ${data.activeDistribution != null ? "SÍ" : "NO"}');
      if (data.activeDistribution != null) {
        print('Distribution ID: ${data.activeDistribution!.distributionId}');
        print('Included Items: ${data.activeDistribution!.includedItems.length}');
        print('Total Expenses Distribution: ${data.activeDistribution!.totalExpenses}');
      }
      print('======================');
      
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _checkHistoryExists() async {
    try {
      final history = await ShoppingListService.getShoppingHistory();
      setState(() {
        _hasHistory = history.isNotEmpty;
      });
    } catch (e) {
      // Si hay error al obtener historial, asumimos que no hay historial
      setState(() {
        _hasHistory = false;
      });
    }
  }

  Future<void> _markAsPurchased(String productId, double price) async {
    try {
      final updatedData = await ShoppingListService.markAsPurchased(productId, price);
      setState(() {
        _data = updatedData;
      });
    } catch (e) {
      _showErrorSnackBar('Error al marcar como comprado: $e');
    }
  }

  Future<void> _addNewProduct(String productName) async {
    try {
      final updatedData = await ShoppingListService.addProduct(productName);
      setState(() {
        _data = updatedData;
      });
    } catch (e) {
      _showErrorSnackBar('Error al agregar producto: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Calcula la repartición de gastos llamando a la API
  Future<void> _calculateExpenseDistribution() async {
    if (_data == null) return;
    
    setState(() {
      _isCalculatingDistribution = true;
    });

    try {
      final distributionData = await ShoppingListService.calculateDistribution();
      
      // Debug: Imprimir respuesta del backend
      print('=== RESPUESTA BACKEND ===');
      print('Distribution ID: ${distributionData.distributionId}');
      print('Included Items: ${distributionData.includedItems.length}');
      print('Total Expenses: ${distributionData.totalExpenses}');
      print('Expenses Summary: ${distributionData.expensesSummary.length}');
      print('========================');
      
      setState(() {
        _isCalculatingDistribution = false;
      });
      
      // Recargar datos para obtener la distribución activa
      await _loadData();
      
      _showSuccessSnackBar('Repartición de gastos calculada');
    } catch (e) {
      setState(() {
        _isCalculatingDistribution = false;
      });
      _showErrorSnackBar('Error al calcular repartición: $e');
    }
  }

  /// Confirma que el usuario actual ha realizado su transferencia
  Future<void> _confirmPayment() async {
    if (_data == null) return;
    
    setState(() {
      _isConfirmingPayment = true;
    });

    try {
      await ShoppingListService.confirmPayment();
      
      setState(() {
        _isConfirmingPayment = false;
      });
      
      // Recargar datos para obtener el estado actualizado
      await _loadData();
      
      _showSuccessSnackBar('Pago confirmado correctamente');
    } catch (e) {
      setState(() {
        _isConfirmingPayment = false;
      });
      _showErrorSnackBar('Error al confirmar pago: $e');
    }
  }


  void _navigateToProductDetail(item) {
    if (item.isPurchased) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen.viewDetail(
            product: item,
          ),
        ),
      );
    } else {
      // Verificar si hay distribución activa
      if (_data?.activeDistribution != null) {
        _showErrorSnackBar('No se pueden comprar productos mientras hay una distribución activa. Complete la distribución actual antes de comprar nuevos productos.');
        return;
      }
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen.purchase(
            product: item,
            onPurchaseConfirmed: (price) {
              _markAsPurchased(item.id, price);
            },
          ),
        ),
      );
    }
  }

  void _navigateToAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen.add(
          onProductAdded: (productName) {
            _addNewProduct(productName);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        top: true,
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorView()
                : _data == null || _data!.items.isEmpty
                    ? _buildEmptyView()
                    : _buildContent(),
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar datos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              '¡Lista vacía!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Agrega tu primer producto usando el botón +',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    // Si no hay productos pero sí hay historial, mostrar múltiples botones
    if ((_data == null || _data!.items.isEmpty) && _hasHistory) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Botón de historial
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShoppingHistoryScreen(),
                  ),
                );
              },
              backgroundColor: Colors.grey[700],
              heroTag: "history_button",
              child: const Icon(Icons.history, color: Colors.white),
            ),
            const SizedBox(width: 16),
            // Botón de agregar producto
            FloatingActionButton(
              onPressed: _navigateToAddProduct,
              backgroundColor: Colors.grey[700],
              heroTag: "add_button",
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      );
    }
    
    // Botón normal cuando hay productos o no hay historial
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        backgroundColor: Colors.grey[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    final data = _data!;
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // 1. Card con gasto total
            _buildTotalExpenseCard(data.totalExpenses),
            
            const SizedBox(height: 16),
            
            // Botón para ver historial de compras
            _buildHistoryButton(),
            
            const SizedBox(height: 20),
            
            // 2. Lista de productos (pendientes y comprados)
            _buildProductsList(data.items),
            
            // Mostrar mensaje si hay productos comprados pero no hay gastos nuevos para distribuir
            if (data.purchasedItems.isNotEmpty && data.activeDistribution == null && data.totalExpenses == 0) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.5), width: 3),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Todos los productos comprados han sido saldados. Agrega nuevos productos para crear una nueva distribución.',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Mostrar sección de gastos si hay productos comprados
            if (data.purchasedItems.isNotEmpty) ...[
              const SizedBox(height: 20),
              
              // 3. Gráfica circular de gastos por persona (siempre que haya productos comprados)
              _buildExpensesPieChart(data, data.activeDistribution),
              
              const SizedBox(height: 20),
              
              // 4. Botón para calcular repartición de gastos (solo si no hay distribución activa Y hay gastos nuevos)
              if (data.activeDistribution == null && data.totalExpenses > 0) ...[
                _buildExpenseDistributionButton(data),
              ],
              
              // 5. Mostrar repartición de gastos si hay distribución activa
              if (data.activeDistribution != null) ...[
                const SizedBox(height: 20),
                _buildExpenseDistributionTable(data.activeDistribution!),
              ],
            ],
            
            const SizedBox(height: 80), // Espacio para el botón flotante
          ],
        ),
      ),
    );
  }

  // 1. Card con gasto total
  // Botón para ver historial de compras
  Widget _buildHistoryButton() {
    return ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ShoppingHistoryScreen(),
            ),
          );
        },
        icon: const Icon(Icons.history, size: 20),
        label: const Text('Ver Historial de Compras'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.withOpacity(0.15),
          foregroundColor: Colors.black87,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.withOpacity(0.5), width: 3),
          ),
        ),
    );
  }

  Widget _buildTotalExpenseCard(double totalExpenses) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.15), // Mismo estilo que las cards de limpieza
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Patrón de fondo decorativo
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            
            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con chip y logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Chip simulado
                    Container(
                      width: 40,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[400]!, width: 1),
                      ),
                      child: Center(
                        child: Container(
                          width: 20,
                          height: 15,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    // Logo simulado
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'HABIHOS',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Número de tarjeta simulado
                Text(
                  '••••  ••••  ••••  1234',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Información del titular y gasto
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GASTO TOTAL',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '€${totalExpenses.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey[900],
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'VÁLIDA HASTA',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '∞',
                          style: TextStyle(
                            color: Colors.grey[900],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Lista de productos (pendientes y comprados)
  Widget _buildProductsList(List items) {
    final pendingItems = items.where((item) => !item.isPurchased).toList();
    final purchasedItems = items.where((item) => item.isPurchased).toList();

      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Título principal
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Lista de Compras',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          
          // Sección: Productos pendientes
          if (pendingItems.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.withOpacity(0.15),
              child: Row(
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 18, color: Colors.black87),
                  const SizedBox(width: 8),
              Text(
                    'Por Comprar (${pendingItems.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
              ),
            ],
          ),
        ),
            ...pendingItems.map((item) => _buildProductItem(item)).toList(),
          ],
          
          // Sección: Productos comprados
          if (purchasedItems.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.withOpacity(0.15),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 18, color: Colors.black87),
                  const SizedBox(width: 8),
                  Text(
                    'Comprados (${purchasedItems.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
          ),
        ],
      ),
            ),
            ...purchasedItems.map((item) => _buildProductItem(item)).toList(),
          ],
          
          // Mensaje si no hay productos
          if (pendingItems.isEmpty && purchasedItems.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
      child: Column(
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 50, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text(
                      'No hay productos',
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductItem(ShoppingItem item) {
    if (item.isPurchased) {
      // Producto comprado - mostrar precio y avatar
      return InkWell(
        onTap: () => _navigateToProductDetail(item),
        child: Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 3,
        ),
      ),
      child: Row(
        children: [
              // Avatar de quién lo compró
          CircleAvatar(
                backgroundColor: item.purchasedBy?.color ?? Colors.grey,
            child: Text(
                  item.purchasedBy?.name.substring(0, 1) ?? '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
              // Nombre del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                        fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                  const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                    style: TextStyle(
                      color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        children: [
                          const TextSpan(text: 'Comprado por '),
                          TextSpan(
                            text: item.purchasedBy?.name ?? 'Desconocido',
                  style: TextStyle(
                              color: item.purchasedBy?.color ?? Colors.grey[600],
                              fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
              ),
              // Precio
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.5), width: 3),
                ),
                child: Text(
                  '€${item.price?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Producto pendiente
      final isDistributionActive = _data?.activeDistribution != null;
      
      return InkWell(
        onTap: () => _navigateToProductDetail(item),
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.5),
              width: 3,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.radio_button_unchecked,
                color: isDistributionActive ? Colors.grey[300] : Colors.grey[400],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: isDistributionActive ? Colors.grey[500] : Colors.grey[700],
                      ),
                    ),
                    if (isDistributionActive) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Compras deshabilitadas durante distribución',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Chip(
                label: Text(
                  isDistributionActive ? 'Bloqueado' : 'Pendiente',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: isDistributionActive ? Colors.red[50] : Colors.grey.withOpacity(0.15),
                labelStyle: TextStyle(
                  color: isDistributionActive ? Colors.red[700] : Colors.black87,
                ),
                side: BorderSide(
                  color: isDistributionActive ? Colors.red[200]! : Colors.grey.withOpacity(0.5),
                  width: isDistributionActive ? 1 : 3,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // Método auxiliar para construir los datos de la gráfica
  List<PieChartData> _buildPieChartData(ShoppingListResponse data, ShoppingDistribution? distribution) {
    // Si hay distribución activa, usar los datos de la distribución
    if (distribution != null && distribution.expensesSummary.isNotEmpty) {
      return distribution.expensesSummary.map((summary) {
        return PieChartData(
          value: summary.totalSpent,
          color: _getColorForMember(summary.memberId),
          label: summary.memberName,
        );
      }).toList();
    }
    
    // Si no hay distribución activa, calcular los gastos de todos los productos comprados
    Map<String, double> expensesByMember = {};
    Map<String, String> memberNames = {};
    
    // Inicializar todos los miembros con 0
    for (var member in data.members) {
      expensesByMember[member.id] = 0.0;
      memberNames[member.id] = member.name;
    }
    
    // Sumar gastos de cada miembro
    for (var item in data.purchasedItems) {
      if (item.purchasedBy != null && item.price != null) {
        String memberId = item.purchasedBy!.id;
        expensesByMember[memberId] = (expensesByMember[memberId] ?? 0.0) + item.price!;
      }
    }
    
    // Convertir a PieChartData
    return expensesByMember.entries
        .where((entry) => entry.value > 0)
        .map((entry) {
          return PieChartData(
            value: entry.value,
            color: _getColorForMember(entry.key),
            label: memberNames[entry.key] ?? 'Desconocido',
          );
        }).toList();
  }

  // 3. Gráfica circular de gastos por persona
  Widget _buildExpensesPieChart(ShoppingListResponse data, ShoppingDistribution? distribution) {
    return Container(
      padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.15), // Mismo estilo que las cards de limpieza
        borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.withOpacity(0.5),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución de Gastos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              height: 200,
              width: 200,
              child: CustomPaint(
                painter: PieChartPainter(
                  data: _buildPieChartData(data, distribution),
                  total: data.totalExpenses,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Leyenda
          ..._buildPieChartData(data, distribution).map((pieData) {
            final percentage = (pieData.value / data.totalExpenses * 100);
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: pieData.color,
                      shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
                    child: Text(
                      pieData.label,
                  style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                  ),
                ),
                  ),
                  Text(
                    '€${pieData.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Helper para obtener color consistente por ID de miembro
  Color _getColorForMember(String memberId) {
    final hash = memberId.hashCode.abs();
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

  // 4. Botón para calcular repartición de gastos
  Widget _buildExpenseDistributionButton(ShoppingListResponse data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.15), // Mismo estilo que las cards de limpieza
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Repartición de Gastos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Calcula cómo se deben repartir los gastos entre todos los miembros de la casa.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isCalculatingDistribution ? null : _calculateExpenseDistribution,
              icon: _isCalculatingDistribution 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.calculate),
              label: Text(
                _isCalculatingDistribution 
                    ? 'Calculando...' 
                    : 'Calcular Repartición',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Tabla de repartición de gastos
  Widget _buildExpenseDistributionTable(ShoppingDistribution distribution) {
    // Debug: Imprimir información de la distribución
    print('=== DISTRIBUCIÓN DEBUG ===');
    print('Distribution ID: ${distribution.distributionId}');
    print('Included Items: ${distribution.includedItems.length}');
    print('Total Expenses: ${distribution.totalExpenses}');
    print('Expenses Summary: ${distribution.expensesSummary.length}');
    print('Suggested Transfers: ${distribution.suggestedTransfers.length}');
    print('All Confirmed: ${distribution.allConfirmed}');
    
    for (var item in distribution.includedItems) {
      print('Item: ${item.name} - Price: ${item.price} - Purchased: ${item.isPurchased}');
    }
    
    for (var summary in distribution.expensesSummary) {
      print('Summary: ${summary.memberName} - Total: ${summary.totalSpent}');
    }
    print('========================');

    return Container(
      padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.15), // Mismo estilo que las cards de limpieza
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
          ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(
            'Repartición de Gastos',
                style: TextStyle(
              fontSize: 20,
                  fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Información general
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.5), width: 3),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                      'Total Gastado',
                        style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '€${distribution.totalExpenses.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.withOpacity(0.5),
                  ),
                  Column(
                    children: [
                      Text(
                      'Por Persona',
                        style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '€${distribution.averageExpensePerMember.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                ],
              ),
            ],
          ),
        ),
        
          const SizedBox(height: 20),
          
          // Tabla de balances por persona
          Text(
            'Balance por Persona:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          
          // Lista de todos los miembros con sus balances
          ...distribution.expensesSummary.map((summary) {
            final isCurrentUser = summary.memberId == _data!.currentUserId;
              
              return Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 3,
                ),
              ),
              child: Row(
                      children: [
                        CircleAvatar(
                    radius: 20,
                    backgroundColor: _getColorForMember(summary.memberId),
                          child: Text(
                      summary.memberName.substring(0, 1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                        fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            children: [
                              Text(
                              summary.memberName,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            if (isCurrentUser) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[700],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Tú',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ha gastado: €${summary.totalSpent.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
            children: [
                      Text(
                        summary.balance >= 0
                            ? '+€${summary.balance.toStringAsFixed(2)}'
                            : '-€${(-summary.balance).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                          color: summary.balance >= 0 ? Colors.black87 : Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        summary.balance >= 0 ? 'Le deben' : 'Debe',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          
          const SizedBox(height: 20),
          
          // Sección de transferencias sugeridas
          Text(
            'Transferencias Sugeridas:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          
          // Mostrar transferencias que vienen del backend
          ...distribution.suggestedTransfers.isEmpty
              ? [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.5), width: 3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
          children: [
                        Icon(Icons.check_circle, color: Colors.black87),
                        const SizedBox(width: 8),
                        Text(
                          '¡Todo está balanceado!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
              ),
          ),
        ],
      ),
                  ),
                ]
              : distribution.suggestedTransfers.map((transfer) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
        children: [
                        // Avatar del deudor
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: _getColorForMember(transfer.fromMemberId),
                          child: Text(
                            transfer.fromMemberName.substring(0, 1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Nombre del deudor
                        Text(
                          transfer.fromMemberName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Flecha
                        Icon(Icons.arrow_forward, color: Colors.grey[600], size: 18),
                        const SizedBox(width: 8),
                        // Avatar del acreedor
                    CircleAvatar(
                          radius: 16,
                          backgroundColor: _getColorForMember(transfer.toMemberId),
                      child: Text(
                            transfer.toMemberName.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white,
                              fontWeight: FontWeight.bold,
                          fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Nombre del acreedor
                        Expanded(
                          child: Text(
                            transfer.toMemberName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Monto
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 3),
                          ),
                          child: Text(
                            '€${transfer.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                          fontWeight: FontWeight.bold,
                              color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          
          const SizedBox(height: 24),
          
          // Sección de confirmación de pagos
          _buildPaymentConfirmationSection(distribution),
        ],
      ),
    );
  }

  /// Construye la sección de confirmación de pagos
  Widget _buildPaymentConfirmationSection(ShoppingDistribution distribution) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: Colors.black87, size: 20),
              const SizedBox(width: 8),
              Text(
                'Confirmación de Pagos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Confirma que ya has realizado los pagos correspondientes. Cuando todos los participantes hayan confirmado sus pagos, la lista de compras se reiniciará automáticamente.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _data?.userHasConfirmedPayment ?? false
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.5), width: 3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.black87, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Pago Confirmado',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _isConfirmingPayment ? null : _confirmPayment,
                    icon: _isConfirmingPayment 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.check_circle, size: 20),
                    label: Text(
                      _isConfirmingPayment ? 'Confirmando...' : 'Confirmar Pago',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

}

// Custom Painter para la gráfica circular
class PieChartData {
  final double value;
  final Color color;
  final String label;

  PieChartData({
    required this.value,
    required this.color,
    required this.label,
  });
}

class PieChartPainter extends CustomPainter {
  final List<PieChartData> data;
  final double total;

  PieChartPainter({
    required this.data,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    double startAngle = -math.pi / 2; // Empezar desde arriba

    for (var item in data) {
      if (item.value == 0) continue;

      final sweepAngle = (item.value / total) * 2 * math.pi;
      
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Borde blanco entre secciones
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      startAngle += sweepAngle;
    }

    // Círculo blanco en el centro para efecto "donut" (opcional)
    final centerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, centerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
