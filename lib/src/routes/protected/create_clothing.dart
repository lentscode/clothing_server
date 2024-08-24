part of "../routes.dart";

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

  final Map<String, dynamic> body = await RequestUtils(req).getBody();

  final String? name = body["name"];
  final String? type = body["type"];
  final String? color = body["color"];
  final String? brand = body["brand"];

  if (name == null || type == null || color == null) {
    return Response.badRequest(body: "Missing fields");
  }

  final Clothing clothing = Clothing.create(
    name: name,
    userId: user.oid,
    type: ClothingType.values.firstWhere((ClothingType e) => e.name == type),
    color: color,
    brand: brand,
  );

  await getIt.get<ClothingDataSource>().createClothing(clothing);

  return Response.ok(clothing.toJson());
}
