import "dart:convert";

import "package:mongo_dart/mongo_dart.dart";
import "package:server/server.dart";
import "package:shelf/shelf.dart";
import "package:test/test.dart";

import "../../utils.dart";

void main() {
  const String url = "http://localhost:8080/public/login";
  const String email = "email@example.com";
  const String password = "password";
  late Db db;

  setUpAll(() async {
    await config(true);
  });

  setUp(() async {
    db = await Db.create(Credentials().mongoUriTest);

    await db.open();
  });

  tearDown(() async {
    await closeTestDb(db, delete: <String>["users"]);
  });

  group("login()", () {
    test("Success: should return a 200 response with user data", () async {
      await db.collection("users").insert(<String, dynamic>{
        "_id": ObjectId(),
        "email": email,
        "hashPassword":
            "13601bda4ea78e55a07b98866d2be6be0744e3866f13c00c811cab608a28f322",
        "salt": "salt",
      });

      final Request req = Request(
        "POST",
        Uri.parse(url),
        body: jsonEncode(<String, String>{
          "email": email,
          "password": password,
        }),
      );

      final Response res = await login(req);
      expect(res.statusCode, 200);

      final dynamic body = jsonDecode(await res.readAsString());

      expect(body["_id"], isA<String>());
      expect(body["email"], email);
    });

    test("Failure: missing fields should return a 400 response", () async {
      final Request req = Request(
        "POST",
        Uri.parse(url),
        body: jsonEncode(<String, String>{}),
      );

      final Response res = await login(req);

      expect(res.statusCode, 400);
    });

    test("Failure: user not found should return a 401 response", () async {
      final Request req = Request(
        "POST",
        Uri.parse(url),
        body: jsonEncode(<String, String>{
          "email": email,
          "password": password,
        }),
      );

      final Response res = await login(req);

      expect(res.statusCode, 401);
    });

    test("Failure: wrong password should return a 401 response", () async {
      await db.collection("users").insert(<String, dynamic>{
        "_id": ObjectId(),
        "email": email,
        "hashPassword":
            "13601bda4ea78e55a07b98866d2be6be0744e3866f13c00c811cab608a28f322",
        "salt": "salt",
      });

      final Request req = Request(
        "POST",
        Uri.parse(url),
        body: jsonEncode(<String, String>{
          "email": email,
          "password": "wrongPassword",
        }),
      );

      final Response res = await login(req);

      expect(res.statusCode, 401);
    });
  });
}
