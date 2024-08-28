part of "../../routes.dart";

Future<Response> getClothingsOfUser(Request req) async {
  try {
    final User user = req.context["user"] as User;

    final List<Clothing> clothings =
        await getIt.get<ClothingDataSource>().getClothingsOfUser(user.id.oid);

    return Response.ok(clothings.toJson());
  } catch (e, s) {
    getIt.get<Logger>().e(e, stackTrace: s);
    return Response.internalServerError(body: e.toString());
  }
}
