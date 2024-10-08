part of "../../routes.dart";

/// Creates a clothing.
///
/// It needs the following fields:
/// - name (name of the clothing, **required**)
/// - type (type of the clothing, **required**)
/// - color (color of the clothing, **required**)
/// - brand (brand of the clothing)
///
/// If the fields are not provided, it will return a 400 status code.
Future<Response> createClothing(Request req) async {
  final User user = req.context["user"] as User;

  final (Map<String, dynamic> data, File? image) =
      await RequestUtils(req).parseFormData();

  if (data["name"] == null || data["type"] == null || data["color"] == null) {
    return Response.badRequest(body: "Missing required fields");
  }

  String? imageUrl;
  String? objectLink;

  if (image != null) {
    (imageUrl, objectLink) =
        await getIt.get<CloudStorage>().uploadImage(image, user, "clothings");
  }

  final Clothing clothing = Clothing.create(
    name: data["name"],
    userId: user.id,
    type: ClothingType.values
        .firstWhere((ClothingType e) => e.name == data["type"]),
    color: data["color"],
    brand: data["brand"],
    imageUrl: imageUrl,
    imageExpiration: DateTime.now().add(const Duration(days: 7)),
    objectLink: objectLink,
  );

  getIt.get<ClothingDataSource>().createClothing(clothing);

  return Response.ok(clothing.toJson());
}
