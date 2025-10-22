import 'shopping_item.dart';
import 'house_member.dart';
import 'expense_summary.dart';
import 'transfer.dart';
import 'shopping_distribution.dart';

/// Respuesta completa del backend para la pantalla de lista de compras
/// Contiene toda la información necesaria para mostrar:
/// - Lista de productos (solo NO saldados)
/// - Miembros de la casa
/// - Distribución activa (si existe)
/// - Estado de confirmación del usuario
class ShoppingListResponse {
  final List<ShoppingItem> items;
  final List<HouseMember> members;
  final double totalExpenses;
  final double averageExpensePerMember;
  final ShoppingDistribution? activeDistribution;
  final bool userHasConfirmedPayment;
  final String currentUserId; // ID del usuario que está viendo la pantalla

  ShoppingListResponse({
    required this.items,
    required this.members,
    required this.totalExpenses,
    required this.averageExpensePerMember,
    required this.activeDistribution,
    required this.userHasConfirmedPayment,
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
      activeDistribution: json['activeDistribution'] != null 
          ? ShoppingDistribution.fromJson(json['activeDistribution'] as Map<String, dynamic>)
          : null,
      userHasConfirmedPayment: json['userHasConfirmedPayment'] as bool,
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
      'activeDistribution': activeDistribution?.toJson(),
      'userHasConfirmedPayment': userHasConfirmedPayment,
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
    if (activeDistribution == null) return null;
    try {
      return activeDistribution!.expensesSummary.firstWhere((summary) => summary.memberId == memberId);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() =>
      'ShoppingListResponse(items: ${items.length}, members: ${members.length}, total: €$totalExpenses)';
}

