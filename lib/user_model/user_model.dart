/// Represents a data model for storing user-generated notes or items.
/// Each item has:
/// - An optional `id` (used for database operations)
/// - A required `title` (short description)
/// - A required `description` (detailed content)
class UserModel {
  /// Unique identifier for the item (nullable for new items before database insertion).
  final int? id;

  /// The title/heading of the item.
  final String title;

  /// Detailed description/content of the item.
  final String description;

  /// Constructor for creating a UserModel instance.
  /// - `id`: Optional, used when updating existing items.
  /// - `title`: Required, cannot be empty.
  /// - `description`: Required, cannot be empty.
  UserModel({this.id, required this.title, required this.description});

  /// Converts the UserModel object to a Map (key-value pairs).
  /// Used for database operations (insert/update).
  /// - Includes `id` only if it exists (for updates).
  /// - Returns a Map with `title` and `description` always.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,  // Only include ID if it exists
      'title': title,             // Always include title
      'description': description, // Always include description
    };
  }

  /// Creates a UserModel object from a Map (typically from database queries).
  /// - `map`: A key-value map where:
  ///   - `id` is an integer or null.
  ///   - `title` is a string.
  ///   - `description` is a string.
  /// - Uses type casting (`as`) for safety.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,           // Cast to nullable int
      title: map['title'] as String,    // Cast to String
      description: map['description'] as String,  // Cast to String
    );
  }
}