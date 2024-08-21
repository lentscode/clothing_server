import "package:dotenv/dotenv.dart";

part "credentials.impl.dart";

abstract class Credentials {
  factory Credentials() => _CredentialsImpl();

  String get mongoUri;

  String get mongoUriTest;
}
