import "package:mongo_dart/mongo_dart.dart";
import "package:shared/shared.dart";

import "../../../server.dart";

part "clothing_data_source.impl.dart";

/// A class to work with clothing data in the database.
abstract class ClothingDataSource {
  const ClothingDataSource._(this.clothings);

  /// Returns a new instance of [ClothingDataSource].
  factory ClothingDataSource(DbCollection clothings) = _ClothingDataSourceImpl;

  /// The [DbCollection] of clothings in MongoDB.
  final DbCollection clothings;

  /// Creates a new [Clothing] in the database.
  Future<Clothing> createClothing(Clothing clothing);

  /// Gets a [Clothing] with a given [id].
  ///
  /// Throws an [ObjectNotFoundException] if no clothing with the given [id] was found.
  Future<Clothing> getClothing(ObjectId id);

  /// Gets a list of [Clothing] that have a given [userId].
  Future<List<Clothing>> getClothingsOfUser(ObjectId userId);

  /// Deletes a [Clothing] with a given [id].
  Future<void> deleteClothing(ObjectId id, String userId);
}
