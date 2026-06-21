/// A model representing a payment made from one person to another to settle a debt.
class SettlementModel {
  final String id;
  // The person sending the money
  final String payerId;
  // The person receiving the money
  final String payeeId;
  final double amount;
  final DateTime date;
  final bool isPaid;

  SettlementModel({
    required this.id,
    required this.payerId,
    required this.payeeId,
    required this.amount,
    required this.date,
    this.isPaid = false,
  });

  SettlementModel copyWith({
    String? id,
    String? payerId,
    String? payeeId,
    double? amount,
    DateTime? date,
    bool? isPaid,
  }) {
    return SettlementModel(
      id: id ?? this.id,
      payerId: payerId ?? this.payerId,
      payeeId: payeeId ?? this.payeeId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
