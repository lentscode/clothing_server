library;

import "package:get_it/get_it.dart";
import "package:mongo_dart/mongo_dart.dart";

import "../../clothing.dart";
import "../logic/auth/auth.dart";

final GetIt getIt = GetIt.instance;

Future<void> config() async {
  final Db db = await Db.create("");
  await db.open();

  final Auth auth = Auth(db.collection("users"));
  final ClothingDataSource clothingDataSource = ClothingDataSource(db.collection("clothings"));
  final OutfitDataSource outfitDataSource = OutfitDataSource(db.collection("outfits"));

  getIt.registerSingleton<Auth>(auth);
  getIt.registerSingleton<ClothingDataSource>(clothingDataSource);
  getIt.registerSingleton<OutfitDataSource>(outfitDataSource);
}
