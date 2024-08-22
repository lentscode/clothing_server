library;

/// Exception that could be thrown during login or registration.
class InvalidCredentialsException implements Exception {
  @override
  String toString() => "Invalid credentials";
}

/// Exception thrown when a document in MongoDB is not found.
class ObjectNotFoundException implements Exception {
  /// Returns an instance of [ObjectNotFoundException].
  const ObjectNotFoundException(this.type);

  /// The type of object not found.
  final String type;

  @override
  String toString() => "$type not found";
}
