import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import '../../services/common/snackbar_service.dart';

/// Pantalla de configuración de suscripción de la casa
class SubscriptionConfigScreen extends StatefulWidget {
  const SubscriptionConfigScreen({super.key});

  @override
  State<SubscriptionConfigScreen> createState() => _SubscriptionConfigScreenState();
}

class _SubscriptionConfigScreenState extends State<SubscriptionConfigScreen> {
  // Información simulada de la suscripción (en el futuro vendrá de la API)
  final SubscriptionInfo _subscriptionInfo = const SubscriptionInfo(
    planName: 'Plan Premium',
    price: 9.99,
    currency: 'USD',
    billingCycle: 'Mensual',
    nextBillingDate: '2024-02-15',
    isActive: true,
    features: [
      'Hasta 8 miembros',
      'Chat ilimitado',
      'Gestión de tareas avanzada',
      'Respaldos automáticos',
      'Soporte prioritario',
    ],
  );

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: UIConstants.textColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Suscripción',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: UIConstants.textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado actual de la suscripción
            _buildSubscriptionStatus(),
            
            const SizedBox(height: UIConstants.spacingLarge),
            
            // Información del plan
            _buildPlanInfo(),
            
            const SizedBox(height: UIConstants.spacingLarge),
            
            // Características del plan
            _buildPlanFeatures(),
            
            const SizedBox(height: UIConstants.spacingLarge),
            
            // Historial de facturación
            _buildBillingHistory(),
            
            const SizedBox(height: UIConstants.spacingLarge),
            
            // Opciones de suscripción
            _buildSubscriptionOptions(),
            
            const SizedBox(height: UIConstants.spacingXLarge),
          ],
        ),
      ),
    );
  }

  /// Construye el estado actual de la suscripción
  Widget _buildSubscriptionStatus() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UIConstants.primaryColor,
            UIConstants.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: UIConstants.spacingLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _subscriptionInfo.planName,
                      style: const TextStyle(
                        fontSize: UIConstants.textSizeLarge,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Próxima facturación: ${_subscriptionInfo.nextBillingDate}',
                      style: TextStyle(
                        fontSize: UIConstants.textSizeSmall,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.spacingMedium,
                  vertical: UIConstants.spacingSmall,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _subscriptionInfo.isActive ? 'ACTIVA' : 'INACTIVA',
                  style: const TextStyle(
                    fontSize: UIConstants.textSizeXSmall,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye la información del plan
  Widget _buildPlanInfo() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del Plan',
            style: TextStyle(
              fontSize: UIConstants.textSizeLarge,
              fontWeight: FontWeight.w600,
              color: UIConstants.textColor,
            ),
          ),
          const SizedBox(height: UIConstants.spacingLarge),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Precio',
                      style: TextStyle(
                        fontSize: UIConstants.textSizeSmall,
                        color: UIConstants.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${_subscriptionInfo.price.toStringAsFixed(2)} ${_subscriptionInfo.currency}',
                      style: const TextStyle(
                        fontSize: UIConstants.textSizeXLarge,
                        fontWeight: FontWeight.w700,
                        color: UIConstants.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ciclo de Facturación',
                      style: TextStyle(
                        fontSize: UIConstants.textSizeSmall,
                        color: UIConstants.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subscriptionInfo.billingCycle,
                      style: const TextStyle(
                        fontSize: UIConstants.textSizeMedium,
                        fontWeight: FontWeight.w600,
                        color: UIConstants.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye las características del plan
  Widget _buildPlanFeatures() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Características Incluidas',
            style: TextStyle(
              fontSize: UIConstants.textSizeLarge,
              fontWeight: FontWeight.w600,
              color: UIConstants.textColor,
            ),
          ),
          const SizedBox(height: UIConstants.spacingLarge),
          ..._subscriptionInfo.features.map((feature) => _buildFeatureItem(feature)),
        ],
      ),
    );
  }

  /// Construye un elemento de característica
  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingMedium),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.green,
              size: 16,
            ),
          ),
          const SizedBox(width: UIConstants.spacingLarge),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(
                fontSize: UIConstants.textSizeMedium,
                color: UIConstants.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el historial de facturación
  Widget _buildBillingHistory() {
    final billingHistory = [
      const BillingRecord(date: '2024-01-15', amount: 9.99, status: 'Pagado'),
      const BillingRecord(date: '2023-12-15', amount: 9.99, status: 'Pagado'),
      const BillingRecord(date: '2023-11-15', amount: 9.99, status: 'Pagado'),
    ];

    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historial de Facturación',
            style: TextStyle(
              fontSize: UIConstants.textSizeLarge,
              fontWeight: FontWeight.w600,
              color: UIConstants.textColor,
            ),
          ),
          const SizedBox(height: UIConstants.spacingLarge),
          ...billingHistory.map((record) => _buildBillingRecord(record)),
        ],
      ),
    );
  }

  /// Construye un registro de facturación
  Widget _buildBillingRecord(BillingRecord record) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingMedium),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: UIConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
            ),
            child: const Icon(
              Icons.receipt_rounded,
              color: UIConstants.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: UIConstants.spacingLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Factura - ${record.date}',
                  style: const TextStyle(
                    fontSize: UIConstants.textSizeMedium,
                    fontWeight: FontWeight.w500,
                    color: UIConstants.textColor,
                  ),
                ),
                Text(
                  '\$${record.amount.toStringAsFixed(2)} ${_subscriptionInfo.currency}',
                  style: TextStyle(
                    fontSize: UIConstants.textSizeSmall,
                    color: UIConstants.textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.spacingSmall,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              record.status,
              style: const TextStyle(
                fontSize: UIConstants.textSizeXSmall,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye las opciones de suscripción
  Widget _buildSubscriptionOptions() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Opciones de Suscripción',
            style: TextStyle(
              fontSize: UIConstants.textSizeLarge,
              fontWeight: FontWeight.w600,
              color: UIConstants.textColor,
            ),
          ),
          const SizedBox(height: UIConstants.spacingLarge),
          
          // Cambiar plan
          _buildOptionItem(
            icon: Icons.upgrade_rounded,
            title: 'Cambiar Plan',
            subtitle: 'Actualizar a un plan superior',
            onTap: _showUpgradeDialog,
          ),
          
          const Divider(),
          
          // Pausar suscripción
          _buildOptionItem(
            icon: Icons.pause_circle_outline_rounded,
            title: 'Pausar Suscripción',
            subtitle: 'Pausar temporalmente tu suscripción',
            onTap: _showPauseDialog,
          ),
          
          const Divider(),
          
          // Cancelar suscripción
          _buildOptionItem(
            icon: Icons.cancel_outlined,
            title: 'Cancelar Suscripción',
            subtitle: 'Cancelar permanentemente tu suscripción',
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: _showCancelDialog,
          ),
        ],
      ),
    );
  }

  /// Construye un elemento de opción
  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingMedium),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? UIConstants.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
              ),
              child: Icon(
                icon,
                color: iconColor ?? UIConstants.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: UIConstants.spacingLarge),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: UIConstants.textSizeMedium,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? UIConstants.textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: UIConstants.textSizeSmall,
                      color: UIConstants.textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: UIConstants.textColor.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra el diálogo de actualización de plan
  void _showUpgradeDialog() {
    SnackBarService().showInfo(context, 'Función de actualización próximamente disponible');
  }

  /// Muestra el diálogo de pausar suscripción
  void _showPauseDialog() {
    SnackBarService().showInfo(context, 'Función de pausa próximamente disponible');
  }

  /// Muestra el diálogo de cancelar suscripción
  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Suscripción'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de que quieres cancelar tu suscripción?'),
            SizedBox(height: 16),
            Text('Al cancelar:'),
            SizedBox(height: 8),
            Text('• Perderás acceso a todas las funciones premium'),
            Text('• Los datos se conservarán por 30 días'),
            Text('• Podrás reactivar en cualquier momento'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No, mantener suscripción'),
          ),
          ElevatedButton(
            onPressed: () => _cancelSubscription(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  /// Cancela la suscripción
  Future<void> _cancelSubscription() async {
    setState(() => _isLoading = true);

    try {
      // Simular llamada a la API
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pop();
        SnackBarService().showSuccess(
          context,
          'Suscripción cancelada correctamente. Los datos se conservarán por 30 días.',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarService().showError(
          context,
          'Error al cancelar suscripción: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Modelo de datos para información de suscripción
class SubscriptionInfo {
  final String planName;
  final double price;
  final String currency;
  final String billingCycle;
  final String nextBillingDate;
  final bool isActive;
  final List<String> features;

  const SubscriptionInfo({
    required this.planName,
    required this.price,
    required this.currency,
    required this.billingCycle,
    required this.nextBillingDate,
    required this.isActive,
    required this.features,
  });
}

/// Modelo de datos para registro de facturación
class BillingRecord {
  final String date;
  final double amount;
  final String status;

  const BillingRecord({
    required this.date,
    required this.amount,
    required this.status,
  });
}
