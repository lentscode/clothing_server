import "package:mongo_dart/mongo_dart.dart";
import "package:server/server.dart";
import "package:shared/shared.dart";
import "package:test/test.dart";

import "../utils.dart";

void main() {
  late Db db;
  late List<Clothing> clothings;
  late ObjectId userId;
  late ClothingDataSource clothingDataSource;

  setUp(() async {
    db = await openTestDb(Credentials().mongoUriTest);
    userId = ObjectId();
    clothings = List<Clothing>.generate(
      3,
      (int index) => Clothing.create(
        name: "name$index",
        userId: userId,
        type: ClothingType.shirt,
        color: "white",
        brand: "brand",
      ),
    );

    clothingDataSource = ClothingDataSource(db.collection("clothings"));

    await db.collection("clothings").insertAll(
        clothings.map((Clothing clothing) => clothing.toMongo()).toList());
  });

  tearDown(() async {
    await closeTestDb(db, delete: <String>["outfits", "clothings"]);
  });

  group("OutfitDataSource", () {
    group("createClothing()", () {
      test("Success: should create a clothing in the db", () async {
        final OutfitDataSource dataSource =
            OutfitDataSource(db.collection("outfits"), clothingDataSource);

        final Outfit outfit = Outfit.create(
          clothings: clothings,
          name: "outfit",
          userId: userId,
        );

        final Outfit createdOutfit = await dataSource.createOutfit(outfit);

        expect(createdOutfit.id, isNotNull);
        expect(createdOutfit.name, outfit.name);
        expect(createdOutfit.clothings, outfit.clothings);

        final Map<String, dynamic>? outfitMap =
            await db.collection("outfits").findOne(where.id(createdOutfit.id));

        expect(outfitMap, isNotNull);
      });
    });

    group("getOutfit()", () {
      test("Success: should retrieve a Clothing object from the db", () async {
        final Outfit outfit =
            Outfit.create(clothings: clothings, name: "name", userId: userId);

        await db.collection("outfits").insert(outfit.toMongo());

        final OutfitDataSource dataSource =
            OutfitDataSource(db.collection("outfits"), clothingDataSource);

        final Outfit fetchedOutfit = await dataSource.getOutfit(outfit.id);

        expect(fetchedOutfit.id, outfit.id);
      });

      test(
          "Failure: outfit with id does not exist, should throw ObjectNotFoundException",
          () async {
        final OutfitDataSource dataSource =
            OutfitDataSource(db.collection("outfits"), clothingDataSource);

        expect(() => dataSource.getOutfit(ObjectId()),
            throwsA(isA<ObjectNotFoundException>()));
      });

      test(
          "Failure: clothing inside outfit does not exist, should throw ObjectNotFoundException",
          () async {
        final Outfit outfit = Outfit.create(
          clothings: clothings
            ..add(
              Clothing.create(
                name: "name",
                userId: userId,
                type: ClothingType.shirt,
                color: "white",
              ),
            ),
          name: "name",
          userId: userId,
        );

        await db.collection("outfits").insert(outfit.toMongo());

        final OutfitDataSource dataSource =
            OutfitDataSource(db.collection("outfits"), clothingDataSource);

        expect(
          () => dataSource.getOutfit(outfit.id),
          throwsA(isA<ObjectNotFoundException>()),
        );
      });
    });

    group("getOutfitsOfUser()", () {
      test("Success: should return a list of outfits", () async {
        final Outfit outfit1 =
            Outfit.create(clothings: clothings, name: "1", userId: userId);
        final Outfit outfit2 =
            Outfit.create(clothings: clothings, name: "1", userId: userId);

        await db.collection("outfits").insertAll(
            <Map<String, dynamic>>[outfit1.toMongo(), outfit2.toMongo()]);

        final OutfitDataSource dataSource =
            OutfitDataSource(db.collection("outfits"), clothingDataSource);

        final List<Outfit> outfits = await dataSource.getOutfitsOfUser(userId);

        expect(outfits, hasLength(2));
        expect(outfits.any((Outfit e) => e.id == outfit1.id), true);
        expect(outfits.any((Outfit e) => e.id == outfit2.id), true);
      });
    });
  });
}
