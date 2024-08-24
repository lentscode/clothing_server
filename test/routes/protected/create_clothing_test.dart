import "dart:convert";

import "package:mongo_dart/mongo_dart.dart";
import "package:server/server.dart";
import "package:shared/shared.dart";
import "package:shelf/shelf.dart";
import "package:test/test.dart";

import "../../utils.dart";

void main() {
  const String url = "http://localhost:8080/protected/clothings";
  late User user;
  late Db db;
  late Request initialRequest;

  setUpAll(() async {
    await config(true);
  });

  setUp(() async {
    db = await Db.create(Credentials().mongoUriTest);

    await db.open();

    user = User.create(
      email: "email@example.com",
      hashPassword: "hashPassword",
      salt: "salt",
      sessionId: "sessionId",
    );

    initialRequest = Request(
      "POST",
      Uri.parse(url),
      context: <String, Object>{
        "user": user,
      },
    );

    await db.collection("users").insert(user.toMapComplete());
  });

  tearDown(() async {
    await closeTestDb(db, delete: <String>["clothings", "users"]);
  });

  group("createClothing()", () {
    test("Success: should create a clothing in the DB and return data about it",
        () async {
      final Request req = initialRequest.change(
        body: jsonEncode(<String, String>{
          "name": "name",
          "type": "shirt",
          "color": "color",
          "brand": "brand",
        }),
      );

      final Response res = await createClothing(req);

      final dynamic body = jsonDecode(await res.readAsString());

      expect(res.statusCode, 200);
      expect(body["name"], "name");
      expect(body["type"], "shirt");
      expect(body["color"], "color");
      expect(body["brand"], "brand");
      expect(body["_id"], isA<String>());
    });

    test("Failure: missing fields should return 400 response", () async {
      final Request req = initialRequest.change(
        body: jsonEncode(<String, String>{}),
      );

      final Response res = await createClothing(req);

      expect(res.statusCode, 400);
    });
  });
}
