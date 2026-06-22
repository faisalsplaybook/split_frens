/// A model representing a group event or a trip (e.g., "Weekend trip to Goa").
class HangoutModel {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime? endDate; // Optional, might be a one-day hangout
  
  // Everyone part of this hangout
  final List<String> participantIds;
  
  // All the expenses added to this hangout
  final List<String> expenseIds;

  // The IDs of settlements that have been marked as paid
  final List<String> paidSettlementIds;

  HangoutModel({
    required this.id,
    required this.title,
    required this.startDate,
    this.endDate,
    required this.participantIds,
    required this.expenseIds,
    this.paidSettlementIds = const [],
  });

  HangoutModel copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? participantIds,
    List<String>? expenseIds,
    List<String>? paidSettlementIds,
  }) {
    return HangoutModel(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      participantIds: participantIds ?? this.participantIds,
      expenseIds: expenseIds ?? this.expenseIds,
      paidSettlementIds: paidSettlementIds ?? this.paidSettlementIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'participantIds': participantIds,
        'expenseIds': expenseIds,
        'paidSettlementIds': paidSettlementIds,
      };

  factory HangoutModel.fromJson(Map<String, dynamic> json) => HangoutModel(
        id: json['id'] as String,
        title: json['title'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'] as String)
            : null,
        participantIds: List<String>.from(json['participantIds'] as List),
        expenseIds: List<String>.from(json['expenseIds'] as List),
        paidSettlementIds: List<String>.from(
            json['paidSettlementIds'] as List? ?? []),
      );
}
