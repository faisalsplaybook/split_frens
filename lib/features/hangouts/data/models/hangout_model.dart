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

  HangoutModel({
    required this.id,
    required this.title,
    required this.startDate,
    this.endDate,
    required this.participantIds,
    required this.expenseIds,
  });

  HangoutModel copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? participantIds,
    List<String>? expenseIds,
  }) {
    return HangoutModel(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      participantIds: participantIds ?? this.participantIds,
      expenseIds: expenseIds ?? this.expenseIds,
    );
  }
}
