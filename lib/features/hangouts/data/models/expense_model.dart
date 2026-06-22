import 'split_type.dart';

/// A model representing a single expense/bill that needs to be split.
class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  
  // The ID of the person who paid the bill initially
  final String paidById;
  
  // How this expense should be split (e.g., equally, by exact amounts)
  final SplitType splitType;

  // A list of person IDs who are involved in this expense
  final List<String> participantIds;

  // Additional fields from Phase 1 PRD
  final String? note;
  final String? currency;
  final double? convertedAmount;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.paidById,
    required this.splitType,
    required this.participantIds,
    this.note,
    this.currency,
    this.convertedAmount,
  });

  ExpenseModel copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? paidById,
    SplitType? splitType,
    List<String>? participantIds,
    String? note,
    String? currency,
    double? convertedAmount,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      paidById: paidById ?? this.paidById,
      splitType: splitType ?? this.splitType,
      participantIds: participantIds ?? this.participantIds,
      note: note ?? this.note,
      currency: currency ?? this.currency,
      convertedAmount: convertedAmount ?? this.convertedAmount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'paidById': paidById,
        'splitType': splitType.name,
        'participantIds': participantIds,
        'note': note,
        'currency': currency,
        'convertedAmount': convertedAmount,
      };

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        paidById: json['paidById'] as String,
        splitType: SplitType.values.byName(json['splitType'] as String),
        participantIds: List<String>.from(json['participantIds'] as List),
        note: json['note'] as String?,
        currency: json['currency'] as String?,
        convertedAmount: (json['convertedAmount'] as num?)?.toDouble(),
      );
}
