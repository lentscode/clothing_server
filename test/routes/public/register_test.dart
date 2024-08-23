import "dart:convert";
import "dart:io";

import "package:http/http.dart";
import "package:mongo_dart/mongo_dart.dart";
import "package:server/server.dart";
import "package:test/test.dart";

import "../../utils.dart";

void main() {
  late Process p;
  const String url = "http://localhost:8080/public/register";
  const String email = "email@example.com";
  const String password = "password";
  late Db db;

  setUp(() async {
    p = await Process.start(
      "dart",
      <String>["run", "bin/server.dart", "--test"],
    );
    db = await Db.create(Credentials().mongoUriTest);

    await Future.wait(<Future<dynamic>>[
      p.stdout.first,
      db.open(),
    ]);
  });

  tearDown(() async {
    await closeTestDb(db, delete: <String>["users"]);
    p.kill();
  });

  group("register()", () {
    test("Success: should return basic user info", () async {
      final Response res = await post(
        Uri.parse(url),
        body: jsonEncode(<String, String>{
          "email": email,
          "password": password,
        }),
      );

      expect(res.statusCode, 200);

      final dynamic body = jsonDecode(res.body);

      expect(body["email"], email);
      expect(body["_id"], isA<String>());

      final Map<String, dynamic>? doc =
          await db.collection("users").findOne(where.eq("email", email));

      expect(doc, isNotNull);
    });

    test("Failure: missing fields should return a 400 response", () async {
      final Response res = await post(
        Uri.parse(url),
        body: jsonEncode(<String, String>{}),
      );

      expect(res.statusCode, 400);
    });

    test("Failure: email already taken should return a 403 response", () async {
      await db.collection("users").insertOne(<String, dynamic>{
        "_id": ObjectId(),
        "email": email,
      });

      final Response res = await post(
        Uri.parse(url),
        body: jsonEncode(<String, String>{
          "email": email,
          "password": password,
        }),
      );

      expect(res.statusCode, 403);
    });
  });
}
