import "dart:convert";
import "dart:math";
import "dart:typed_data";

import "package:crypto/crypto.dart";
import "package:mongo_dart/mongo_dart.dart";
import "package:shared/shared.dart";
import "package:uuid/uuid.dart";

import "../../../server.dart";

part "auth.impl.dart";

/// A class that contains logic for authentication and authorization.
abstract class Auth {
  const Auth._(this.users);

  /// Returns an instance of [Auth].
  factory Auth(DbCollection users) = _AuthImpl;

  /// The collection of users in MongoDB.
  final DbCollection users;

  /// Registers a user.
  ///
  /// It also returns a [User] object with user info.
  Future<User> register(String email, String password);

  /// Logs in a user.
  ///
  /// It also returns a [User] object with user info.
  Future<(User user, String cookie)> login(String email, String password);

  Future<User> checkSessionId(String cookie);
}
