import "package:mongo_dart/mongo_dart.dart";
import "package:server/server.dart";
import "package:server/src/config/credentials/credentials.dart";
import "package:shared/shared.dart";
import "package:test/test.dart";

import "../utils.dart";

void main() {
  late Db db;
  late ObjectId id;
  late ObjectId userId;

  setUp(() async {
    db = await openTestDb(Credentials().mongoUriTest);
    id = ObjectId();
    userId = ObjectId();

    await db.collection("clothings").insert(<String, Object>{
      "_id": id,
      "name": "T-Shirt",
      "type": "shirt",
      "userId": userId,
    });
  });

  tearDown(() async {
    await closeTestDb(db, delete: <String>["clothings"]);
  });

  group("ClothingDataSource", () {
    group("createClothing()", () {
      test("Success: should create a Clothing object in DB", () async {
        final ClothingDataSource clothingDataSource = ClothingDataSource(db.collection("clothings"));
        final ObjectId id = ObjectId();

        final Clothing clothing = Clothing(
          id: id,
          name: "name",
          userId: userId,
          type: ClothingType.shirt,
        );

        final Clothing newClothing = await clothingDataSource.createClothing(clothing);

        expect(newClothing.id, clothing.id);

        final Map<String, dynamic>? map = await db.collection("clothings").findOne(where.id(id));

        expect(map, isNotNull);
        expect(map!["_id"], id);
      });
    });
    group("getClothing()", () {
      test("Success: should return a Clothing object", () async {
        final ClothingDataSource clothingDataSource = ClothingDataSource(db.collection("clothings"));

        final Clothing clothing = await clothingDataSource.getClothing(id);

        expect(clothing.name, "T-Shirt");
      });

      test("Failure: should throw a ObjectNotFoundException", () async {
        final ClothingDataSource clothingDataSource = ClothingDataSource(db.collection("clothings"));

        expect(() async => await clothingDataSource.getClothing(ObjectId()), throwsA(isA<ObjectNotFoundException>()));
      });
    });
    group("getClothingsOfUser()", () {
      test("Success: should return a list of Clothing", () async {
        final ClothingDataSource clothingDataSource = ClothingDataSource(db.collection("clothings"));

        db.collection("clothings").insert(<String, Object>{
          "_id": ObjectId(),
          "name": "T-Shirt2",
          "type": "shirt",
          "userId": userId,
        });

        final List<Clothing> clothings = await clothingDataSource.getClothingsOfUser(userId);

        expect(clothings.length, 2);
      });
    });
  });
}
