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

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.paidById,
    required this.splitType,
    required this.participantIds,
  });

  ExpenseModel copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? paidById,
    SplitType? splitType,
    List<String>? participantIds,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      paidById: paidById ?? this.paidById,
      splitType: splitType ?? this.splitType,
      // We don't want to just copy the reference to the list, we want a fresh list 
      // if one is provided, otherwise keep the existing one.
      participantIds: participantIds ?? this.participantIds,
    );
  }
}
