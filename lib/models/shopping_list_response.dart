import 'shopping_item.dart';
import 'house_member.dart';
import 'expense_summary.dart';
import 'transfer.dart';

/// Respuesta completa del backend para la pantalla de lista de compras
/// Contiene toda la información necesaria para mostrar:
/// - Lista de productos
/// - Miembros de la casa
/// - Resumen de gastos
/// - Transferencias sugeridas
class ShoppingListResponse {
  final List<ShoppingItem> items;
  final List<HouseMember> members;
  final double totalExpenses;
  final double averageExpensePerMember;
  final List<ExpenseSummary> expensesSummary;
  final List<Transfer> suggestedTransfers;
  final String currentUserId; // ID del usuario que está viendo la pantalla

  ShoppingListResponse({
    required this.items,
    required this.members,
    required this.totalExpenses,
    required this.averageExpensePerMember,
    required this.expensesSummary,
    required this.suggestedTransfers,
    required this.currentUserId,
  });

  // Conversión desde JSON (del backend)
  factory ShoppingListResponse.fromJson(Map<String, dynamic> json) {
    return ShoppingListResponse(
      items: (json['items'] as List<dynamic>)
          .map((item) => ShoppingItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      members: (json['members'] as List<dynamic>)
          .map((member) => HouseMember.fromJson(member as Map<String, dynamic>))
          .toList(),
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      averageExpensePerMember: (json['averageExpensePerMember'] as num).toDouble(),
      expensesSummary: (json['expensesSummary'] as List<dynamic>)
          .map((summary) => ExpenseSummary.fromJson(summary as Map<String, dynamic>))
          .toList(),
      suggestedTransfers: (json['suggestedTransfers'] as List<dynamic>)
          .map((transfer) => Transfer.fromJson(transfer as Map<String, dynamic>))
          .toList(),
      currentUserId: json['currentUserId'] as String,
    );
  }

  // Conversión a JSON
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'members': members.map((member) => member.toJson()).toList(),
      'totalExpenses': totalExpenses,
      'averageExpensePerMember': averageExpensePerMember,
      'expensesSummary': expensesSummary.map((summary) => summary.toJson()).toList(),
      'suggestedTransfers': suggestedTransfers.map((transfer) => transfer.toJson()).toList(),
      'currentUserId': currentUserId,
    };
  }

  // Helpers útiles
  List<ShoppingItem> get pendingItems => 
      items.where((item) => !item.isPurchased).toList();

  List<ShoppingItem> get purchasedItems => 
      items.where((item) => item.isPurchased).toList();

  HouseMember? getMemberById(String id) {
    try {
      return members.firstWhere((member) => member.id == id);
    } catch (e) {
      return null;
    }
  }

  ExpenseSummary? getExpenseSummaryForMember(String memberId) {
    try {
      return expensesSummary.firstWhere((summary) => summary.memberId == memberId);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() =>
      'ShoppingListResponse(items: ${items.length}, members: ${members.length}, total: €$totalExpenses)';
}

