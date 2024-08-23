import "dart:convert";
import "dart:io";

import "package:http/http.dart";
import "package:mongo_dart/mongo_dart.dart";
import "package:server/server.dart";
import "package:test/test.dart";

import "../../utils.dart";

void main() {
  late Process p;
  const String url = "http://localhost:8080/public/login";
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

  group("login()", () {
    test("Success: should return a 200 response with user data", () async {
      await db.collection("users").insert(<String, dynamic>{
        "_id": ObjectId(),
        "email": email,
        "hashPassword":
            "13601bda4ea78e55a07b98866d2be6be0744e3866f13c00c811cab608a28f322",
        "salt": "salt",
      });

      final Response res = await post(
        Uri.parse(url),
        body: jsonEncode(<String, String>{
          "email": email,
          "password": password,
        }),
      );

      final dynamic body = jsonDecode(res.body);

      expect(res.statusCode, 200);
      expect(body["_id"], isA<String>());
      expect(body["email"], email);
    });

    test("Failure: missing fields should return a 400 response", () async {
      final Response res = await post(
        Uri.parse(url),
        body: jsonEncode(<String, String>{}),
      );

      expect(res.statusCode, 400);
    });

    test("Failure: user not found should return a 401 response", () async {
      final Response res = await post(
        Uri.parse(url),
        body: jsonEncode(<String, String>{
          "email": email,
          "password": password,
        }),
      );

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

      final Response res = await post(
        Uri.parse(url),
        body: jsonEncode(<String, String>{
          "email": email,
          "password": "wrongPassword",
        }),
      );

      expect(res.statusCode, 401);
    });
  });
}
