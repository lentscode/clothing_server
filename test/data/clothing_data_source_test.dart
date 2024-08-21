import "package:mongo_dart/mongo_dart.dart";
import "package:server/server.dart";
import "package:server/src/config/credentials/credentials.dart";
import "package:shared/shared.dart";
import "package:test/test.dart";

import "../utils.dart";

void main() {
  late Db db;
  late ObjectId id;

  setUp(() async {
    db = await openTestDb(Credentials().mongoUriTest);
    id = ObjectId();

    await db.collection("clothings").insert(<String, Object>{
      "_id": id,
      "name": "T-Shirt",
      "type": "shirt",
      "userId": "userId",
    });
  });

  tearDown(() async {
    await db.close();
  });

  group("ClothingDataSource", () {
    group("getClothing()", () {
      test("Success: should return a Clothing object", () async {
        final ClothingDataSource clothingDataSource = ClothingDataSource(db.collection("clothings"));

        final Clothing clothing = await clothingDataSource.getClothing(id);

        expect(clothing.name, equals("T-Shirt"));
      });
    });
  });
}
