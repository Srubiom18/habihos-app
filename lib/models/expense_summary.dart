/// Resumen de gastos por miembro
class ExpenseSummary {
  final String memberId;
  final String memberName;
  final double totalSpent; // Total gastado por este miembro
  final double balance; // Balance vs promedio (positivo = le deben, negativo = debe)
  final int itemsPurchased; // Cantidad de productos comprados

  ExpenseSummary({
    required this.memberId,
    required this.memberName,
    required this.totalSpent,
    required this.balance,
    required this.itemsPurchased,
  });

  // Conversión desde JSON (del backend)
  factory ExpenseSummary.fromJson(Map<String, dynamic> json) {
    return ExpenseSummary(
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String,
      totalSpent: (json['totalSpent'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      itemsPurchased: json['itemsPurchased'] as int,
    );
  }

  // Conversión a JSON
  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'totalSpent': totalSpent,
      'balance': balance,
      'itemsPurchased': itemsPurchased,
    };
  }

  // Helper: indica si le deben dinero
  bool get hasCredit => balance > 0;

  // Helper: indica si debe dinero
  bool get hasDebt => balance < 0;

  // Helper: porcentaje del total
  double percentageOfTotal(double total) {
    return total > 0 ? (totalSpent / total) * 100 : 0;
  }

  @override
  String toString() =>
      'ExpenseSummary(memberId: $memberId, memberName: $memberName, balance: $balance)';
}

