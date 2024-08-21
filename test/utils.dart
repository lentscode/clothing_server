import "package:mongo_dart/mongo_dart.dart";

Future<Db> openTestDb(String uri) async {
  final Db db = await Db.create(uri);
  await db.open();
  return db;
}

Future<void> closeTestDb(Db db, {List<String> delete = const <String>[]}) async {
  await Future.wait(
    <Future<bool>>[for (String collection in delete) db.collection(collection).drop()],
  );

  await db.close();
}
