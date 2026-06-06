/// A model representing a person (a friend) in the app.
class PersonModel {
  // We use 'final' because once a PersonModel is created, its fields shouldn't change.
  // To change a person's details, we create a new instance using copyWith.
  final String id;
  final String name;
  final String? avatarUrl; // The '?' means this field is optional (can be null)

  // The constructor requires id and name, but avatarUrl is optional.
  PersonModel({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  /// The copyWith method is a standard Dart pattern.
  /// It allows us to create a copy of this object with some fields changed,
  /// while keeping the rest of the fields exactly the same.
  PersonModel copyWith({
    String? id,
    String? name,
    String? avatarUrl,
  }) {
    return PersonModel(
      // If a new 'id' is provided, use it. Otherwise (??), use the existing 'this.id'
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
