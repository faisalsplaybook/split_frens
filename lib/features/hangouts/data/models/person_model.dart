/// A model representing a person (a friend) in the app.
class PersonModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? contactInfo;

  PersonModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.contactInfo,
  });

  PersonModel copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? contactInfo,
  }) {
    return PersonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarUrl': avatarUrl,
    'contactInfo': contactInfo,
  };

  factory PersonModel.fromJson(Map<String, dynamic> json) => PersonModel(
    id: json['id'] as String,
    name: json['name'] as String,
    avatarUrl: json['avatarUrl'] as String?,
    contactInfo: json['contactInfo'] as String?,
  );
}
