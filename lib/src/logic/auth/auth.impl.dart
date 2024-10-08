part of "auth.dart";

class _AuthImpl extends Auth {
  const _AuthImpl(super.users) : super._();

  @override
  Future<(User user, String cookie)> login(
      String email, String password) async {
    final Map<String, dynamic>? map =
        await users.findOne(where.eq("email", email));

    if (map == null) {
      throw InvalidCredentialsException();
    }

    final User user = User.fromMongo(map);

    final String hashedPassword = _hashPassword(password, user.salt);

    if (user.hashPassword != hashedPassword) {
      throw InvalidCredentialsException();
    }

    final User userUpdated = user.copyWith(
      sessionId: _sessionId(),
      sessionExpiration: DateTime.now().add(const Duration(days: 30)),
    );

    await users.updateOne(
      where.id(user.id),
      modify
          .set("sessionId", userUpdated.sessionId)
          .set("sessionExpiration", userUpdated.sessionExpiration),
    );

    final String cookie = _generateCookie(
      userUpdated.sessionId!,
      DateTime.now().add(const Duration(days: 30)),
    );

    return (userUpdated, cookie);
  }

  @override
  Future<User> register(String email, String password) async {
    final Map<String, dynamic>? userWithEmail =
        await users.findOne(where.eq("email", email));

    if (userWithEmail != null) {
      throw InvalidCredentialsException();
    }

    final String salt = _generateSalt();

    final String hashedPassword = _hashPassword(password, salt);

    final User user = User.create(
      email: email,
      hashPassword: hashedPassword,
      salt: salt,
    );

    await users.insert(user.toMongo());

    return user;
  }

  @override
  Future<User> checkSessionId(String cookie) async {
    final Map<String, dynamic>? map =
        await users.findOne(where.eq("sessionId", cookie));

    if (map == null ||
        (map["sessionExpiration"] != null &&
            map["sessionExpiration"].isBefore(DateTime.now()))) {
      throw SessionIdNotValidException();
    }

    return User.fromMongo(map);
  }

  String _generateSalt([int length = 16]) {
    final Random random = Random.secure();

    final List<int> values =
        List<int>.generate(length, (int i) => random.nextInt(256));
    return base64UrlEncode(values);
  }

  String _hashPassword(String password, String salt) {
    final String saltedPassword = "$salt$password";

    final Uint8List bytes = utf8.encode(saltedPassword);

    final Digest digest = sha256.convert(bytes);

    return digest.toString();
  }

  String _sessionId() => const Uuid().v4();

  String _generateCookie(String sessionId, [DateTime? expires]) {
    String cookie = "sessionId=$sessionId; HttpOnly; SameSite=Strict";

    int seconds;

    if (expires != null) {
      seconds = DateTime.now().difference(expires).inSeconds;
    } else {
      seconds = 0;
    }
    cookie += "; MaxAge=$seconds";

    return cookie;
  }
}
