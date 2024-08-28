part of "credentials.dart";

class _CredentialsImpl implements Credentials {
  _CredentialsImpl() : _env = DotEnv(includePlatformEnvironment: true)..load();

  final DotEnv _env;
  @override
  String get mongoUri => _env["MONGO_URI"] ?? "";

  @override
  String get mongoUriTest => _env["MONGO_URI_TEST"] ?? "";

  @override
  Map<String, String> get googleServiceAccount => <String, String>{
        "type": "service_account",
        "project_id": _env["GOOGLE_PROJECT_ID"] ?? "",
        "private_key_id": _env["GOOGLE_PRIVATE_KEY_ID"] ?? "",
        "private_key":
            (_env["GOOGLE_PRIVATE_KEY"] ?? "").replaceAll(r"\n", "\n"),
        "client_email": _env["GOOGLE_CLIENT_EMAIL"] ?? "",
        "client_id": _env["GOOGLE_CLIENT_ID"] ?? "",
        "auth_uri": _env["GOOGLE_AUTH_URI"] ?? "",
        "token_uri": _env["GOOGLE_TOKEN_URI"] ?? "",
        "auth_provider_x509_cert_url":
            _env["GOOGLE_AUTH_PROVIDER_X509_CERT_URL"] ?? "",
        "client_x509_cert_url": _env["GOOGLE_CLIENT_X509_CERT_URL"] ?? "",
        "universe_domain": _env["GOOGLE_UNIVERSE_DOMAIN"] ?? "",
      };
}
