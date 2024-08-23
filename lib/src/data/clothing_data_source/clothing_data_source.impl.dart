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
  Future<void> deleteClothing(ObjectId id, String userId) => clothings.remove(where.id(id).eq("userId", userId));
}
