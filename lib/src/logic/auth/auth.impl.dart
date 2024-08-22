part of "auth.dart";

class _AuthImpl extends Auth {
  const _AuthImpl(super.users) : super._();

  @override
  Future<User> login(String email, String password) async {
    final Map<String, dynamic>? map = await users.findOne(where.eq("email", email));

    if (map == null) {
      throw InvalidCredentialsException();
    }

    final User user = User.fromMap(map);

    final String hashedPassword = _hashPassword(password, user.salt);

    if (user.hashPassword != hashedPassword) {
      throw InvalidCredentialsException();
    }

    user.sessionId = _sessionId();

    await users.updateOne(where.id(user.id), modify.set("sessionId", user.sessionId));

    return user;
  }

  @override
  Future<User> register(String email, String password) async {
    final Map<String, dynamic>? userWithEmail = await users.findOne(where.eq("email", email));

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

    await users.insert(user.toMapComplete());

    return user;
  }

  String _generateSalt([int length = 16]) {
    final Random random = Random.secure();

    final List<int> values = List<int>.generate(length, (int i) => random.nextInt(256));
    return base64UrlEncode(values);
  }

  String _hashPassword(String password, String salt) {
    final String saltedPassword = "$salt$password";

    final Uint8List bytes = utf8.encode(saltedPassword);

    final Digest digest = sha256.convert(bytes);

    return digest.toString();
  }

  String _sessionId() => const Uuid().v4();
}
