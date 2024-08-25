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
  late Clothing clothing;
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
      "UPDATE",
      Uri.parse(url),
      context: <String, Object>{
        "user": user,
      },
    );

    clothing = Clothing.create(
      name: "name",
      userId: user.id,
      type: ClothingType.shirt,
      color: "white",
    );

    await db.collection("clothings").insert(clothing.toMongo());
  });

  tearDown(() async {
    await closeTestDb(db, delete: <String>["clothings", "users"]);
  });

  group("updateClothing()", () {
    test("Success: should update doc in db and return a 200 response",
        () async {
      final Request req = initialRequest.change(
        body: jsonEncode(<String, String>{
          "id": clothing.oid,
          "name": "newName",
          "type": "shirt",
          "color": "black",
          "brand": "brand",
        }),
      );

      final Response res = await updateClothing(req);

      expect(res.statusCode, 200);

      final dynamic body = jsonDecode(await res.readAsString());

      expect(body["name"], "newName");
      expect(body["type"], "shirt");
      expect(body["color"], "black");
      expect(body["brand"], "brand");

      final Map<String, dynamic>? doc =
          await db.collection("clothings").findOne(where.id(clothing.id));

      expect(doc, isNotNull);
      expect(doc!["name"], "newName");
      expect(doc["type"], "shirt");
      expect(doc["color"], "black");
      expect(doc["brand"], "brand");
    });

    test("Failure: missing id should return a 400 response", () async {
      final Request req = initialRequest.change(
        body: jsonEncode(<String, String>{
          "name": "newName",
          "type": "shirt",
          "color": "black",
          "brand": "brand",
        }),
      );

      final Response res = await updateClothing(req);

      expect(res.statusCode, 400);
    });

    test("Failure: wrong userId should return a 403 response", () async {
      final Request req = initialRequest.change(
        context: <String, Object?>{
          "user": User.create(
            email: "email@example.com",
            hashPassword: "hashPassword",
            salt: "salt",
            sessionId: "sessionId",
          ),
        },
        body: jsonEncode(<String, String>{
          "id": clothing.oid,
          "name": "newName",
          "type": "shirt",
          "color": "black",
          "brand": "brand",
        }),
      );

      final Response res = await updateClothing(req);

      expect(res.statusCode, 403);
    });
  });
}
