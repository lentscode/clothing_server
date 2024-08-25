library;

import "package:get_it/get_it.dart";
import "package:googleapis/storage/v1.dart";
import "package:googleapis_auth/auth_io.dart";
import "package:mongo_dart/mongo_dart.dart";

import "../../server.dart";

export "credentials/credentials.dart";

/// Service locator.
final GetIt getIt = GetIt.instance;

/// Executes code before server start.
Future<void> config([bool testing = false]) async {
  final ServiceAccountCredentials googleCredentials =
      ServiceAccountCredentials.fromJson(Credentials().googleServiceAccount);

  final Future<Db> dbFuture =
      Db.create(testing ? Credentials().mongoUriTest : Credentials().mongoUri)..then((Db db) => db.open());

  final Future<AutoRefreshingAuthClient> googleClientFuture =
      clientViaServiceAccount(
          googleCredentials, <String>[StorageApi.devstorageReadWriteScope]);

  final (Db db, AutoRefreshingAuthClient googleClient) =
      await (dbFuture, googleClientFuture).wait;

  final StorageApi storageApi = StorageApi(googleClient);

  final Auth auth = Auth(db.collection("users"));
  final ClothingDataSource clothingDataSource =
      ClothingDataSource(db.collection("clothings"));
  final OutfitDataSource outfitDataSource =
      OutfitDataSource(db.collection("outfits"), clothingDataSource);

  final CloudStorage cloudStorage = CloudStorage(storageApi);

  getIt.registerSingleton<Auth>(auth);
  getIt.registerSingleton<ClothingDataSource>(clothingDataSource);
  getIt.registerSingleton<OutfitDataSource>(outfitDataSource);
  getIt.registerSingleton<CloudStorage>(cloudStorage);
}
