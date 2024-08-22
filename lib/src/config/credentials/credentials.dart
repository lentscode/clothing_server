import "package:dotenv/dotenv.dart";

part "credentials.impl.dart";

/// A class that contains API keys, etc.
abstract class Credentials {
  /// Returns an instance of [Credentials].
  factory Credentials() => _CredentialsImpl();

  /// Returns the API key to MongoDB.
  String get mongoUri;

  /// Returns the API key to MongoDB test.
  String get mongoUriTest;
}
