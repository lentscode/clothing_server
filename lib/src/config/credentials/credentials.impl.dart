part of "credentials.dart";

class _CredentialsImpl implements Credentials {
  _CredentialsImpl() : _env = DotEnv(includePlatformEnvironment: true)..load();

  final DotEnv _env;
  @override
  String get mongoUri => _env["MONGO_URI"] ?? "";

  @override
  String get mongoUriTest => _env["MONGO_URI_TEST"] ?? "";
}
