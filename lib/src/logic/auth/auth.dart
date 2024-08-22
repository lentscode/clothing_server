import "dart:convert";
import "dart:math";
import "dart:typed_data";

import "package:crypto/crypto.dart";
import "package:mongo_dart/mongo_dart.dart";
import "package:shared/shared.dart";
import "package:uuid/uuid.dart";

import "../../../server.dart";

part "auth.impl.dart";

abstract class Auth {
  const Auth._(this.users);

  factory Auth(DbCollection users) = _AuthImpl;

  final DbCollection users;

  Future<User> register(String email, String password);
  Future<User> login(String email, String password);
}
