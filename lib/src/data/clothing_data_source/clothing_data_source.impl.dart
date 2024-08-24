part of "clothing_data_source.dart";

class _ClothingDataSourceImpl extends ClothingDataSource {
  const _ClothingDataSourceImpl(super.clothings) : super._();

  @override
  Future<Clothing> createClothing(Clothing clothing) =>
      clothings.insert(clothing.toMongo()).then((_) => clothing);

  @override
  Future<Clothing> getClothing(ObjectId id) async {
    final Map<String, dynamic>? map = await clothings.findOne(where.id(id));

    if (map == null) {
      throw const ObjectNotFoundException("Clothing");
    }

    return Clothing.fromMap(map);
  }

  @override
  Future<List<Clothing>> getClothingsOfUser(ObjectId userId) async {
    final Stream<Map<String, dynamic>> maps =
        clothings.find(where.eq("userId", userId));

    return maps.map(Clothing.fromMap).toList();
  }

  @override
  Future<void> deleteClothing(ObjectId id, String userId) =>
      clothings.remove(where.id(id).eq("userId", userId));

  @override
  Future<Clothing> updateClothing(
    ObjectId id,
    String userId, {
    String? name,
    String? type,
    String? color,
    String? brand,
  }) async {
    final Map<String, dynamic>? map =
        await clothings.findOne(where.id(id).eq("userId", userId));

    if (map == null) {
      throw const ObjectNotFoundException("Clothing");
    }

    final Clothing clothing = Clothing.fromMap(map);

    final Clothing updatedClothing = clothing.copyWith(
      name: name,
      type: ClothingType.values.firstWhere(
        (ClothingType clothingType) => clothingType.name == type,
        orElse: () => clothing.type,
      ),
      color: color,
      brand: brand,
    );

    await clothings.update(
      where.id(id).eq("userId", userId),
      updatedClothing.toMongo(),
    );

    return updatedClothing;
  }
}
