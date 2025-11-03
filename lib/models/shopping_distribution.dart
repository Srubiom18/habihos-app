import 'shopping_item.dart';
import 'expense_summary.dart';
import 'transfer.dart';
import 'payment_confirmation.dart';

/// Modelo para representar una distribución de gastos activa
class ShoppingDistribution {
  final String distributionId;
  final List<ShoppingItem> includedItems;
  final List<ExpenseSummary> expensesSummary;
  final List<Transfer> suggestedTransfers;
  final List<PaymentConfirmation> confirmations;
  final bool allConfirmed;
  final DateTime createdAt;
  final String createdByUserId;

  ShoppingDistribution({
    required this.distributionId,
    required this.includedItems,
    required this.expensesSummary,
    required this.suggestedTransfers,
    required this.confirmations,
    required this.allConfirmed,
    required this.createdAt,
    required this.createdByUserId,
  });

  // Conversión desde JSON (del backend)
  factory ShoppingDistribution.fromJson(Map<String, dynamic> json) {
    return ShoppingDistribution(
      distributionId: json['distributionId'] as String,
      includedItems: (json['includedItems'] as List<dynamic>)
          .map((item) => ShoppingItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      expensesSummary: (json['expensesSummary'] as List<dynamic>)
          .map((summary) => ExpenseSummary.fromJson(summary as Map<String, dynamic>))
          .toList(),
      suggestedTransfers: (json['suggestedTransfers'] as List<dynamic>)
          .map((transfer) => Transfer.fromJson(transfer as Map<String, dynamic>))
          .toList(),
      confirmations: (json['confirmations'] as List<dynamic>)
          .map((confirmation) => PaymentConfirmation.fromJson(confirmation as Map<String, dynamic>))
          .toList(),
      allConfirmed: json['allConfirmed'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdByUserId: json['createdByUserId'] as String,
    );
  }

  // Conversión a JSON
  Map<String, dynamic> toJson() {
    return {
      'distributionId': distributionId,
      'includedItems': includedItems.map((item) => item.toJson()).toList(),
      'expensesSummary': expensesSummary.map((summary) => summary.toJson()).toList(),
      'suggestedTransfers': suggestedTransfers.map((transfer) => transfer.toJson()).toList(),
      'confirmations': confirmations.map((confirmation) => confirmation.toJson()).toList(),
      'allConfirmed': allConfirmed,
      'createdAt': createdAt.toIso8601String(),
      'createdByUserId': createdByUserId,
    };
  }

  // Helpers útiles
  double get totalExpenses => 
      includedItems.where((item) => item.isPurchased).fold(0.0, (sum, item) => sum + (item.price ?? 0.0));

  double get averageExpensePerMember => 
      expensesSummary.isEmpty ? 0.0 : totalExpenses / expensesSummary.length;

  int get confirmedCount => 
      confirmations.where((confirmation) => confirmation.confirmed).length;

  int get totalMembers => confirmations.length;

  @override
  String toString() =>
      'ShoppingDistribution(id: $distributionId, items: ${includedItems.length}, confirmed: $confirmedCount/$totalMembers)';
}
