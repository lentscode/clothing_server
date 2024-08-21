library;

class InvalidCredentialsException implements Exception {
  @override
  String toString() => "Invalid credentials";
}

class UserWithEmailAlreadyExistingException implements Exception {
  @override
  String toString() => "User with email already exists";
}

class ObjectNotFoundException implements Exception {
  const ObjectNotFoundException(this.type);

  final String type;
  @override
  String toString() => "$type not found";
}
