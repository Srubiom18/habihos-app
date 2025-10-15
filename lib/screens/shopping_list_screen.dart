import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'product_detail_screen.dart';
import '../models/shopping_list_response.dart';
import '../models/shopping_item.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ShoppingListService.getShoppingList();
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: FloatingActionButton(
          onPressed: _navigateToAddProduct,
          backgroundColor: Colors.orange[600],
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
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
                backgroundColor: Colors.orange[600],
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
            
            const SizedBox(height: 20),
            
            // 2. Lista de productos (pendientes y comprados)
            _buildProductsList(data.items),
            
            // Solo mostrar gráfica y repartición si hay productos comprados
            if (data.purchasedItems.isNotEmpty) ...[
              const SizedBox(height: 20),
              
              // 3. Gráfica circular de gastos por persona
              _buildExpensesPieChart(data),
              
              const SizedBox(height: 20),
              
              // 4. Tabla de repartición de gastos
              _buildExpenseDistributionTable(data),
            ],
            
            const SizedBox(height: 80), // Espacio para el botón flotante
          ],
        ),
      ),
    );
  }

  // 1. Card con gasto total
  Widget _buildTotalExpenseCard(double totalExpenses) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[400]!, Colors.deepOrange[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Gasto Total',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '€${totalExpenses.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 2. Lista de productos (pendientes y comprados)
  Widget _buildProductsList(List items) {
    final pendingItems = items.where((item) => !item.isPurchased).toList();
    final purchasedItems = items.where((item) => item.isPurchased).toList();

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                color: Colors.grey[800],
              ),
            ),
          ),
          
          // Sección: Productos pendientes
          if (pendingItems.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange[50],
              child: Row(
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 18, color: Colors.orange[700]),
                  const SizedBox(width: 8),
              Text(
                    'Por Comprar (${pendingItems.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700],
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
              color: Colors.green[50],
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 18, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Comprados (${purchasedItems.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
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
      decoration: BoxDecoration(
        border: Border(
              top: BorderSide(color: Colors.grey[200]!, width: 1),
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
                  color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Text(
                  '€${item.price?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
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
      return InkWell(
        onTap: () => _navigateToProductDetail(item),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey[400],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                  fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Chip(
                label: const Text(
                  'Pendiente',
                  style: TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.orange[50],
                labelStyle: TextStyle(color: Colors.orange[700]),
                side: BorderSide(color: Colors.orange[200]!),
              ),
            ],
          ),
        ),
      );
    }
  }

  // 3. Gráfica circular de gastos por persona
  Widget _buildExpensesPieChart(ShoppingListResponse data) {
    return Container(
      padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
        borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
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
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              height: 200,
              width: 200,
              child: CustomPaint(
                painter: PieChartPainter(
                  data: data.expensesSummary.map((summary) {
                    return PieChartData(
                      value: summary.totalSpent,
                      color: _getColorForMember(summary.memberId),
                      label: summary.memberName,
                    );
                  }).toList(),
                  total: data.totalExpenses,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Leyenda
          ...data.expensesSummary.map((summary) {
            final percentage = summary.percentageOfTotal(data.totalExpenses);
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getColorForMember(summary.memberId),
                      shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
                    child: Text(
                      summary.memberName,
                  style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                  ),
                ),
                  ),
                  Text(
                    '€${summary.totalSpent.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
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

  // 4. Tabla de repartición de gastos
  Widget _buildExpenseDistributionTable(ShoppingListResponse data) {

    return Container(
      padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          // Información general
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
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
                      '€${data.totalExpenses.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.blue[200],
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
                      '€${data.averageExpensePerMember.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
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
          ...data.expensesSummary.map((summary) {
            final isCurrentUser = summary.memberId == data.currentUserId;
              
              return Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                color: isCurrentUser ? Colors.orange[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrentUser ? Colors.orange[300]! : Colors.grey[200]!,
                  width: isCurrentUser ? 2 : 1,
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
                                  color: Colors.orange[700],
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
                          color: summary.balance >= 0 ? Colors.green[700] : Colors.red[700],
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
          
          // Mostrar transferencias que vienen del backend (solo las que involucran al usuario actual)
          ...data.suggestedTransfers.isEmpty
              ? [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
          children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text(
                          '¡Todo está balanceado!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
              ),
          ),
        ],
      ),
                  ),
                ]
              : data.suggestedTransfers.map((transfer) {
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
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Text(
                            '€${transfer.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                          fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                        ),
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
