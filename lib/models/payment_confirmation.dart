/// Modelo para representar la confirmación de pago de un miembro
class PaymentConfirmation {
  final String memberId;
  final String memberName;
  final bool confirmed;
  final DateTime? confirmedAt;

  PaymentConfirmation({
    required this.memberId,
    required this.memberName,
    required this.confirmed,
    this.confirmedAt,
  });

  // Conversión desde JSON (del backend)
  factory PaymentConfirmation.fromJson(Map<String, dynamic> json) {
    return PaymentConfirmation(
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String,
      confirmed: json['confirmed'] as bool,
      confirmedAt: json['confirmedAt'] != null 
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
    );
  }

  // Conversión a JSON
  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'confirmed': confirmed,
      'confirmedAt': confirmedAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'PaymentConfirmation(member: $memberName, confirmed: $confirmed)';
}
