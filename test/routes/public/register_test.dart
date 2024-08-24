import "dart:convert";

import "package:mongo_dart/mongo_dart.dart";
import "package:server/server.dart";
import "package:shelf/shelf.dart";
import "package:test/test.dart";

import "../../utils.dart";

void main() {
  const String url = "http://localhost:8080/public/register";
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

  group("register()", () {
    test("Success: should return basic user info", () async {
      final Request req = Request(
        "POST",
        Uri.parse(url),
        body: jsonEncode(<String, String>{
          "email": email,
          "password": password,
        }),
      );
      final Response res = await register(req);

      expect(res.statusCode, 200);

      final dynamic body = jsonDecode(await res.readAsString());

      expect(body["email"], email);
      expect(body["_id"], isA<String>());

      final Map<String, dynamic>? doc =
          await db.collection("users").findOne(where.eq("email", email));

      expect(doc, isNotNull);
    });

    test("Failure: missing fields should return a 400 response", () async {
      final Request req = Request(
        "POST",
        Uri.parse(url),
        body: jsonEncode(<String, String>{}),
      );

      final Response res = await register(req);

      expect(res.statusCode, 400);
    });

    test("Failure: email already taken should return a 403 response", () async {
      await db.collection("users").insertOne(<String, dynamic>{
        "_id": ObjectId(),
        "email": email,
      });

      final Request req = Request(
        "POST",
        Uri.parse(url),
        body: jsonEncode(<String, String>{
          "email": email,
          "password": password,
        }),
      );

      final Response res = await register(req);

      expect(res.statusCode, 403);
    });
  });
}
