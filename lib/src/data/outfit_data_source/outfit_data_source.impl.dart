part of "outfit_data_source.dart";

class _OutfitDataSourceImpl extends OutfitDataSource {
  const _OutfitDataSourceImpl(super.outfits, super.clothingDataSource)
      : super._();

  @override
  Future<Outfit> createOutfit(Outfit outfit) =>
      outfits.insert(outfit.toMongo()).then((_) => outfit);

  @override
  Future<Outfit> getOutfit(ObjectId id) async {
    final Map<String, dynamic>? map = await outfits.findOne(where.id(id));

    if (map == null) {
      throw const ObjectNotFoundException("Outfit");
    }

    final List<dynamic> clothingsIds = map["clothings"];

    final List<Clothing> clothings = await _getClothingsOfOutfit(clothingsIds);

    map["clothings"] = clothings;

    return Outfit.fromMap(map);
  }

  @override
  Future<List<Outfit>> getOutfitsOfUser(ObjectId userId) async {
    final Stream<Map<String, dynamic>> maps =
        outfits.find(where.eq("userId", userId.oid));

    List<Map<String, dynamic>> mapsList = await maps.toList();

    for (final Map<String, dynamic> map in mapsList) {
      final List<dynamic> clothingsIds = map["clothings"];

      final List<Clothing> clothings =
          await _getClothingsOfOutfit(clothingsIds);

      map["clothings"] = clothings;
    }

    return mapsList.map(Outfit.fromMap).toList();
  }

  Future<List<Clothing>> _getClothingsOfOutfit(
    List<dynamic> clothingsIds,
  ) async =>
      Future.wait(
        clothingsIds.map(
            (dynamic id) => clothingDataSource.getClothing(ObjectId.parse(id))),
      );
}
