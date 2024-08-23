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

/// Exception thrown when a session ID is not valid.
class SessionIdNotValidException implements Exception {
  @override
  String toString() => "Session ID not valid";
}

/// Exception thrown when a cookie is not given or not found.
class CookieNotFoundException implements Exception {
  @override
  String toString() => "Cookie not found";
}
