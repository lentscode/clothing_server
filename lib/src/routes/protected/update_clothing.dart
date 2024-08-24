part of "../routes.dart";

Future<Response> updateClothing(Request req) async {
  try {
    final User user = req.context["user"] as User;

    final Map<String, dynamic> body = await RequestUtils(req).getBody();

    final String? id = body["id"];
    final String? name = body["name"];
    final String? type = body["type"];
    final String? color = body["color"];
    final String? brand = body["brand"];

    if (id == null) {
      return Response.badRequest(body: "Missing clothing id");
    }

    final Clothing updatedClothing =
        await getIt.get<ClothingDataSource>().updateClothing(
              ObjectId.parse(id),
              user.oid,
              name: name,
              type: type,
              color: color,
              brand: brand,
            );

    return Response.ok(updatedClothing.toJson());
  } on ObjectNotFoundException catch (e) {
    return Response.forbidden(e.toString());
  } catch (e) {
    return Response.internalServerError(body: e.toString());
  }
}
