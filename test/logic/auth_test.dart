import "package:mongo_dart/mongo_dart.dart";
import "package:server/server.dart";
import "package:shared/shared.dart";
import "package:test/test.dart";

import "../utils.dart";

void main() {
  late Db db;
  const String email = "email@example.com";
  const String password = "password";

  setUp(() async {
    db = await openTestDb(Credentials().mongoUriTest);
  });

  tearDown(() async {
    await closeTestDb(db, delete: <String>["users"]);
  });
  group("Auth", () {
    group("register()", () {
      test("Success: should create a user in the db and return a User",
          () async {
        final Auth auth = Auth(db.collection("users"));

        final User result = await auth.register(email, password);

        expect(result.email, email);
        expect(result.hashPassword == password, false);

        final Map<String, dynamic>? dbCheck =
            await db.collection("users").findOne(where.id(result.id));

        expect(dbCheck, isNotNull);
        expect(dbCheck!["_id"], result.id);
      });

      test(
          "Failure: creating a user with an already taken email should throw a InvalidCredentialsException",
          () async {
        final Auth auth = Auth(db.collection("users"));

        await db.collection("users").insertOne(<String, dynamic>{
          "email": email,
        });

        expect(
          () async => await auth.register(email, password),
          throwsA(isA<InvalidCredentialsException>()),
        );
      });
    });

    group("login()", () {
      test("Success: should create sessionId in Db and return a User object",
          () async {
        final Auth auth = Auth(db.collection("users"));

        await auth.register(email, password);

        final (User result, String cookie) = await auth.login(email, password);

        expect(result.email, email);
        expect(result.sessionId, isNotNull);
        expect(cookie, contains(result.sessionId));

        final Map<String, dynamic>? dbCheck =
            await db.collection("users").findOne(where.id(result.id));

        expect(dbCheck!["sessionId"], result.sessionId);
      });

      test(
          "Failure: user not found, should throw a InvalidCredentialsException",
          () {
        final Auth auth = Auth(db.collection("users"));

        expect(
          () async => await auth.login(email, password),
          throwsA(isA<InvalidCredentialsException>()),
        );
      });

      test(
          "Failure: login with wrong password should throw a InvalidCredentialsException",
          () async {
        final Auth auth = Auth(db.collection("users"));

        await auth.register(email, password);

        expect(
          () async => await auth.login(email, "wrongPassword"),
          throwsA(isA<InvalidCredentialsException>()),
        );
      });
    });

    group("checkSessionId", () {
      test("Success: found user with sessionId, should return the user doc",
          () async {
        final Map<String, dynamic> map = <String, dynamic>{
          "_id": ObjectId(),
          "email": email,
          "sessionId": "sessionId",
          "hashPassword": "hashPassword",
          "salt": "salt",
        };

        await db.collection("users").insertOne(map);

        final Auth auth = Auth(db.collection("users"));

        final User result = await auth.checkSessionId("sessionId");

        expect(result.email, email);
      });

      test(
          "Failure: not found user, should throw an InvalidCredentialsException",
          () async {
        final Auth auth = Auth(db.collection("users"));

        expect(() => auth.checkSessionId("sessionId"),
            throwsA(isA<SessionIdNotValidException>()));
      });

      test(
          "Failure: sessionId expired, should throw a SessionIdNotValidException",
          () async {
        final Map<String, dynamic> map = <String, dynamic>{
          "_id": ObjectId(),
          "email": email,
          "sessionId": "sessionId",
          "hashPassword": "hashPassword",
          "salt": "salt",
          "sessionExpiration": DateTime.now()
              .subtract(const Duration(seconds: 1)),
        };

        await db.collection("users").insertOne(map);

        final Auth auth = Auth(db.collection("users"));

        expect(() => auth.checkSessionId("sessionId"),
            throwsA(isA<SessionIdNotValidException>()));
      });
    });
  });
}
