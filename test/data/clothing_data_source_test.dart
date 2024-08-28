import "package:mongo_dart/mongo_dart.dart";
import "package:server/server.dart";
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
      "userId": userId.oid,
      "color": "white",
      "lastUpdate": DateTime.now(),
    });
  });

  tearDown(() async {
    await closeTestDb(db, delete: <String>["clothings"]);
  });

  group("ClothingDataSource", () {
    group("createClothing()", () {
      test("Success: should create a Clothing object in DB", () async {
        final ClothingDataSource clothingDataSource =
            ClothingDataSource(db.collection("clothings"));
        final ObjectId id = ObjectId();

        final Clothing clothing = Clothing(
          id: id,
          name: "name",
          userId: userId,
          type: ClothingType.shirt,
          color: "white",
          lastUpdate: DateTime.now(),
        );

        final Clothing newClothing =
            await clothingDataSource.createClothing(clothing);

        expect(newClothing.id, clothing.id);

        final Map<String, dynamic>? map =
            await db.collection("clothings").findOne(where.id(id));

        expect(map, isNotNull);
        expect(map!["_id"], id);
      });
    });
    group("getClothing()", () {
      test("Success: should return a Clothing object", () async {
        final ClothingDataSource clothingDataSource =
            ClothingDataSource(db.collection("clothings"));

        final Clothing clothing = await clothingDataSource.getClothing(id);

        expect(clothing.name, "T-Shirt");
      });

      test("Failure: should throw a ObjectNotFoundException", () async {
        final ClothingDataSource clothingDataSource =
            ClothingDataSource(db.collection("clothings"));

        expect(() async => await clothingDataSource.getClothing(ObjectId()),
            throwsA(isA<ObjectNotFoundException>()));
      });
    });
    group("getClothingsOfUser()", () {
      test("Success: should return a list of Clothing", () async {
        final ClothingDataSource clothingDataSource =
            ClothingDataSource(db.collection("clothings"));

        db.collection("clothings").insert(<String, Object>{
          "_id": ObjectId(),
          "name": "T-Shirt2",
          "type": "shirt",
          "userId": userId.oid,
          "color": "white",
          "lastUpdate": DateTime.now(),
        });

        final List<Clothing> clothings =
            await clothingDataSource.getClothingsOfUser(userId.oid);

        expect(clothings.length, 2);
      });
    });

    group("deleteClothing()", () {
      test("Success: should delete clothing from MongoDB", () async {
        final ClothingDataSource clothingDataSource =
            ClothingDataSource(db.collection("clothings"));

        await clothingDataSource.deleteClothing(id, userId.oid);

        final Map<String, dynamic>? map =
            await db.collection("clothings").findOne(where.id(id));

        expect(map, isNull);
      });

      test("Failure: wrong userId should not delete document", () async {
        final ClothingDataSource clothingDataSource =
            ClothingDataSource(db.collection("clothings"));

        await clothingDataSource.deleteClothing(id, ObjectId().oid);

        final Map<String, dynamic>? map =
            await db.collection("clothings").findOne(where.id(id));

        expect(map, isNotNull);
      });
    });

    group("updateClothing()", () {
      test("Success: should update doc in DB and return updated object",
          () async {
        final ClothingDataSource clothingDataSource =
            ClothingDataSource(db.collection("clothings"));

        await clothingDataSource.updateClothing(
          id,
          userId.oid,
          name: "newName",
          color: "black",
          brand: "nike",
        );

        final Map<String, dynamic>? map =
            await db.collection("clothings").findOne(where.id(id));

        expect(map!["name"], "newName");
        expect(map["color"], "black");
        expect(map["brand"], "nike");
      });

      test(
          "Failure: clothing does not belongs to user, should throw a ObjectNotFoundException",
          () async {
        final ClothingDataSource clothingDataSource =
            ClothingDataSource(db.collection("clothings"));

        expect(
          () => clothingDataSource.updateClothing(
            id,
            "wrongUserId",
            name: "newName",
            color: "black",
            brand: "nike",
          ),
          throwsA(isA<ObjectNotFoundException>()),
        );
      });
    });
  });
}
