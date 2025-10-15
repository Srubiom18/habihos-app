/// Transferencia sugerida entre dos miembros
class Transfer {
  final String fromMemberId;
  final String fromMemberName;
  final String toMemberId;
  final String toMemberName;
  final double amount;

  Transfer({
    required this.fromMemberId,
    required this.fromMemberName,
    required this.toMemberId,
    required this.toMemberName,
    required this.amount,
  });

  // Conversión desde JSON (del backend)
  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      fromMemberId: json['fromMemberId'] as String,
      fromMemberName: json['fromMemberName'] as String,
      toMemberId: json['toMemberId'] as String,
      toMemberName: json['toMemberName'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  // Conversión a JSON
  Map<String, dynamic> toJson() {
    return {
      'fromMemberId': fromMemberId,
      'fromMemberName': fromMemberName,
      'toMemberId': toMemberId,
      'toMemberName': toMemberName,
      'amount': amount,
    };
  }

  @override
  String toString() =>
      'Transfer(from: $fromMemberName, to: $toMemberName, amount: €$amount)';
}

