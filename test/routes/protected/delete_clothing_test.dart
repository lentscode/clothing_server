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
      "DELETE",
      Uri.parse(url),
      context: <String, Object>{
        "user": user,
      },
    );

    clothing = Clothing.create(
      name: "name",
      userId: user.oid,
      type: ClothingType.shirt,
      color: "white",
    );

    await db.collection("clothings").insert(clothing.toMongo());
  });

  tearDown(() async {
    await closeTestDb(db, delete: <String>["clothings", "users"]);
  });

  group("deleteClothing()", () {
    test("Success: should delete clothing and return 200 response", () async {
      final Request req = initialRequest.change(
        body: jsonEncode(<String, String>{
          "id": clothing.oid,
        }),
      );

      final Response res = await deleteClothing(req);

      expect(res.statusCode, 200);

      final Map<String, dynamic>? doc =
          await db.collection("clothings").findOne(
                where.eq("_id", clothing.oid),
              );

      expect(doc, isNull);
    });

    test("Failure: clothing does not belong to user, so nothing happens", () async {
      final Request req = initialRequest.change(
        body: jsonEncode(<String, String>{
          "id": ObjectId().oid,
        }),
      );

      final Response res = await deleteClothing(req);

      expect(res.statusCode, 200);

      final Map<String, dynamic>? doc =
          await db.collection("clothings").findOne(where.id(clothing.id));

      expect(doc, isNotNull);
    });
  });
}
