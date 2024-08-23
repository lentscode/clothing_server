library;

import "package:get_it/get_it.dart";
import "package:mongo_dart/mongo_dart.dart";

import "../../server.dart";

export "credentials/credentials.dart";

/// Service locator.
final GetIt getIt = GetIt.instance;

/// Executes code before server start.
Future<void> config() async {
  final Db db = await Db.create(Credentials().mongoUri);
  await db.open();

  final Auth auth = Auth(db.collection("users"));
  final ClothingDataSource clothingDataSource = ClothingDataSource(db.collection("clothings"));
  final OutfitDataSource outfitDataSource = OutfitDataSource(db.collection("outfits"));

  getIt.registerSingleton<Auth>(auth);
  getIt.registerSingleton<ClothingDataSource>(clothingDataSource);
  getIt.registerSingleton<OutfitDataSource>(outfitDataSource);
}
