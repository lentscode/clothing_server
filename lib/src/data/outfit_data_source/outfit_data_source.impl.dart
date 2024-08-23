part of "outfit_data_source.dart";

class _OutfitDataSourceImpl extends OutfitDataSource {
  const _OutfitDataSourceImpl(super.outfits) : super._();

  @override
  Future<Outfit> createOutfit(Outfit outfit) =>
      outfits.insert(outfit.toMap()).then((_) => outfit);

  @override
  Future<Outfit> getOutfit(ObjectId id) async {
    final Map<String, dynamic>? map = await outfits.findOne(where.id(id));

    if (map == null) {
      throw const ObjectNotFoundException("Outfit");
    }

    return Outfit.fromMap(map);
  }

  @override
  Future<List<Outfit>> getOutfitsOfUser(ObjectId userId) {
    final Stream<Map<String, dynamic>> maps =
        outfits.find(where.eq("userId", userId));

    return maps.map(Outfit.fromMap).toList();
  }
}
