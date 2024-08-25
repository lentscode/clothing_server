import "package:mongo_dart/mongo_dart.dart";
import "package:shared/shared.dart";

import "../../../server.dart";

part "outfit_data_source.impl.dart";

/// A class to work with outfit data in the database.
abstract class OutfitDataSource {
  const OutfitDataSource._(this.outfits, this.clothingDataSource);

  /// Returns a new instance of [OutfitDataSource].
  factory OutfitDataSource(DbCollection outfits, ClothingDataSource clothingDataSource) = _OutfitDataSourceImpl;

  /// The [DbCollection] of outfits in MongoDB.
  final DbCollection outfits;

  final ClothingDataSource clothingDataSource;

  /// Creates a new [Outfit] in the database.
  Future<Outfit> createOutfit(Outfit outfit);

  /// Gets an [Outfit] with a given [id].
  ///
  /// Throws an [ObjectNotFoundException] if no outfit with the given [id] was found.
  Future<Outfit> getOutfit(ObjectId id);

  /// Gets a list of [Outfit] that have a given [userId].
  Future<List<Outfit>> getOutfitsOfUser(ObjectId userId);
}
