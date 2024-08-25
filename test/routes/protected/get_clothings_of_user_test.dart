import "dart:convert";

import "package:mongo_dart/mongo_dart.dart";
import "package:server/server.dart";
import "package:shared/shared.dart";
import "package:shelf/shelf.dart";
import "package:test/test.dart";

void main() {
  const String url = "http://localhost:8080/protected/clothings";
  late User user;
  late Db db;
  late List<Clothing> clothings;
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
      "GET",
      Uri.parse(url),
      context: <String, Object>{
        "user": user,
      },
    );

    clothings = List.generate(
      5,
      (int index) => Clothing.create(
        name: "name$index",
        userId: user.id,
        type: ClothingType.shirt,
        color: "white",
      ),
    );

    await db
        .collection("clothings")
        .insertAll(clothings.map((Clothing e) => e.toMongo()).toList());
  });

  group("getClothingsOfUser()", () {
    test("Success: should return a list of Clothing", () async {
      final Request req = initialRequest;

      final Response response = await getClothingsOfUser(req);

      expect(response.statusCode, 200);

      final List<dynamic> body = jsonDecode(await response.readAsString());

      expect(body.length, 5);

      for (int i = 0; i < 5; i++) {
        expect(body[i]["name"], "name$i");
      }
    });

    test("Failure: wrong userId should return an empty list", () async {
      final Request req = initialRequest.change(
        context: <String, Object>{
          "user": User.create(
            email: "email@example.com",
            hashPassword: "hashPassword",
            salt: "salt",
            sessionId: "sessionId",
          ),
        },
      );

      final Response response = await getClothingsOfUser(req);

      expect(response.statusCode, 200);

      final List<dynamic> body = jsonDecode(await response.readAsString());

      expect(body.length, 0);
    });
  });
}
